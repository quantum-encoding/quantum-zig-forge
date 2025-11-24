package backtesting

import (
	"encoding/json"
	"fmt"
	"log"
	"math"
	"math/rand"
	"os"
	"runtime"
	"sort"
	"sync"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
)

// OptimizableStrategy interface for strategies that support parameter optimization
type OptimizableStrategy interface {
	BacktestStrategy
	SetParameters(params map[string]interface{}) error
	GetParameterRanges() map[string]ParameterRange
	Clone() OptimizableStrategy
}

// ParameterRange defines the range of values for a parameter
type ParameterRange struct {
	Name     string
	Type     string      // "int", "float", "bool"
	Min      interface{}
	Max      interface{}
	Step     interface{}
	Current  interface{}
}

// OptimizationResult holds results from parameter optimization
type OptimizationResult struct {
	Parameters       map[string]interface{}
	Metrics          *BacktestResults
	Score            float64 // Objective function score
	InSampleScore    float64
	OutOfSampleScore float64
	OverfitRatio     float64 // Out/In sample ratio
}

// Optimizer performs parameter optimization for trading strategies
type Optimizer struct {
	Strategy         OptimizableStrategy
	Symbol           string
	StartDate        time.Time
	EndDate          time.Time
	TimeFrame        marketdata.TimeFrame
	ObjectiveFunc    string // "sharpe", "profit_factor", "calmar", "return"
	OptimizationMode string // "grid", "random", "genetic", "bayesian"
	
	// Walk-forward settings
	UseWalkForward   bool
	TrainPeriodDays  int
	TestPeriodDays   int
	StepDays         int
	
	// Parallel execution
	MaxWorkers       int
	
	// Data
	Bars             []Bar
	DataClient       *marketdata.Client
	
	// Results tracking
	Results          []OptimizationResult
	BestResult       *OptimizationResult
	IterationCount   int
	StartTime        time.Time
	
	// Logging
	Logger           *log.Logger
	Verbose          bool
	
	mu               sync.Mutex
	wg               sync.WaitGroup
}

// NewOptimizer creates a new parameter optimizer
func NewOptimizer(strategy OptimizableStrategy, symbol string, start, end time.Time) *Optimizer {
	return &Optimizer{
		Strategy:         strategy,
		Symbol:           symbol,
		StartDate:        start,
		EndDate:          end,
		TimeFrame:        marketdata.OneDay,
		ObjectiveFunc:    "sharpe",
		OptimizationMode: "grid",
		UseWalkForward:   false,
		TrainPeriodDays:  252, // 1 year default
		TestPeriodDays:   63,  // 3 months default
		StepDays:         21,  // Monthly steps
		MaxWorkers:       runtime.NumCPU(),
		Results:          []OptimizationResult{},
		Logger:           log.New(log.Writer(), "[OPTIMIZER] ", log.LstdFlags),
		Verbose:          false,
	}
}

// LoadData fetches historical data for optimization
func (o *Optimizer) LoadData(dataClient *marketdata.Client) error {
	o.DataClient = dataClient
	
	barsReq := marketdata.GetBarsRequest{
		TimeFrame: o.TimeFrame,
		Start:     o.StartDate,
		End:       o.EndDate,
		PageLimit: 10000,
	}

	bars, err := dataClient.GetBars(o.Symbol, barsReq)
	if err != nil {
		return fmt.Errorf("failed to load data: %w", err)
	}

	o.Bars = []Bar{}
	for _, bar := range bars {
		o.Bars = append(o.Bars, Bar{
			Time:   bar.Timestamp,
			Open:   bar.Open,
			High:   bar.High,
			Low:    bar.Low,
			Close:  bar.Close,
			Volume: float64(bar.Volume),
		})
	}

	o.Logger.Printf("Loaded %d bars for optimization", len(o.Bars))
	return nil
}

// Optimize runs the parameter optimization
func (o *Optimizer) Optimize() (*OptimizationResult, error) {
	o.StartTime = time.Now()
	o.Logger.Printf("Starting %s optimization for %s", o.OptimizationMode, o.Symbol)
	
	if len(o.Bars) == 0 {
		return nil, fmt.Errorf("no data loaded")
	}
	
	var result *OptimizationResult
	var err error
	
	switch o.OptimizationMode {
	case "grid":
		result, err = o.gridSearch()
	case "random":
		result, err = o.randomSearch(100) // 100 iterations default
	case "genetic":
		result, err = o.geneticAlgorithm(50, 20) // 50 generations, 20 population
	case "bayesian":
		result, err = o.bayesianOptimization(50) // 50 iterations
	default:
		return nil, fmt.Errorf("unknown optimization mode: %s", o.OptimizationMode)
	}
	
	if err != nil {
		return nil, err
	}
	
	// Validate with walk-forward if enabled
	if o.UseWalkForward && result != nil {
		o.Logger.Println("Running walk-forward validation...")
		wfScore := o.walkForwardValidation(result.Parameters)
		result.OutOfSampleScore = wfScore
		result.OverfitRatio = wfScore / result.InSampleScore
		
		if result.OverfitRatio < 0.8 {
			o.Logger.Printf("WARNING: Potential overfitting detected (ratio: %.2f)", result.OverfitRatio)
		}
	}
	
	duration := time.Since(o.StartTime)
	o.Logger.Printf("Optimization complete in %v. Best score: %.4f", duration, result.Score)
	
	return result, nil
}

// gridSearch performs exhaustive grid search over parameter space
func (o *Optimizer) gridSearch() (*OptimizationResult, error) {
	paramRanges := o.Strategy.GetParameterRanges()
	
	// Generate all parameter combinations
	combinations := o.generateGridCombinations(paramRanges)
	o.Logger.Printf("Grid search: testing %d parameter combinations", len(combinations))
	
	// Create work channel
	workChan := make(chan map[string]interface{}, len(combinations))
	resultChan := make(chan OptimizationResult, len(combinations))
	
	// Start workers
	for i := 0; i < o.MaxWorkers; i++ {
		o.wg.Add(1)
		go o.optimizationWorker(workChan, resultChan)
	}
	
	// Queue work
	for _, params := range combinations {
		workChan <- params
	}
	close(workChan)
	
	// Wait for completion
	o.wg.Wait()
	close(resultChan)
	
	// Collect results
	for result := range resultChan {
		o.mu.Lock()
		o.Results = append(o.Results, result)
		if o.BestResult == nil || result.Score > o.BestResult.Score {
			o.BestResult = &result
		}
		o.mu.Unlock()
	}
	
	return o.BestResult, nil
}

// randomSearch performs random parameter search
func (o *Optimizer) randomSearch(iterations int) (*OptimizationResult, error) {
	paramRanges := o.Strategy.GetParameterRanges()
	
	workChan := make(chan map[string]interface{}, iterations)
	resultChan := make(chan OptimizationResult, iterations)
	
	// Start workers
	for i := 0; i < o.MaxWorkers; i++ {
		o.wg.Add(1)
		go o.optimizationWorker(workChan, resultChan)
	}
	
	// Generate random parameter sets
	for i := 0; i < iterations; i++ {
		params := o.generateRandomParameters(paramRanges)
		workChan <- params
	}
	close(workChan)
	
	// Wait for completion
	o.wg.Wait()
	close(resultChan)
	
	// Collect results
	for result := range resultChan {
		o.mu.Lock()
		o.Results = append(o.Results, result)
		if o.BestResult == nil || result.Score > o.BestResult.Score {
			o.BestResult = &result
		}
		o.mu.Unlock()
	}
	
	return o.BestResult, nil
}

// geneticAlgorithm implements genetic algorithm optimization
func (o *Optimizer) geneticAlgorithm(generations, populationSize int) (*OptimizationResult, error) {
	paramRanges := o.Strategy.GetParameterRanges()
	
	// Initialize population
	population := make([]OptimizationResult, populationSize)
	for i := 0; i < populationSize; i++ {
		params := o.generateRandomParameters(paramRanges)
		score := o.evaluateParameters(params)
		population[i] = OptimizationResult{
			Parameters: params,
			Score:      score,
		}
	}
	
	// Evolution loop
	for gen := 0; gen < generations; gen++ {
		// Sort by fitness
		sort.Slice(population, func(i, j int) bool {
			return population[i].Score > population[j].Score
		})
		
		// Keep best (elitism)
		newPopulation := []OptimizationResult{population[0]}
		
		// Crossover and mutation
		for i := 1; i < populationSize; i++ {
			// Select parents (tournament selection)
			parent1 := o.tournamentSelect(population, 3)
			parent2 := o.tournamentSelect(population, 3)
			
			// Crossover
			childParams := o.crossover(parent1.Parameters, parent2.Parameters)
			
			// Mutation
			if math.Mod(float64(i), 10) == 0 { // 10% mutation rate
				childParams = o.mutate(childParams, paramRanges)
			}
			
			// Evaluate fitness
			score := o.evaluateParameters(childParams)
			newPopulation = append(newPopulation, OptimizationResult{
				Parameters: childParams,
				Score:      score,
			})
		}
		
		population = newPopulation
		
		// Track best
		if population[0].Score > o.BestResult.Score {
			o.BestResult = &population[0]
		}
		
		if gen%10 == 0 {
			o.Logger.Printf("Generation %d: Best score = %.4f", gen, population[0].Score)
		}
	}
	
	// Final evaluation with full metrics
	bestParams := population[0].Parameters
	finalResult := o.evaluateParametersFull(bestParams)
	
	return &finalResult, nil
}

// bayesianOptimization implements Gaussian Process-based optimization
func (o *Optimizer) bayesianOptimization(iterations int) (*OptimizationResult, error) {
	// Simplified Bayesian optimization using acquisition function
	// In production, use a proper GP library
	
	paramRanges := o.Strategy.GetParameterRanges()
	
	// Initial random sampling
	initialSamples := 10
	observations := make([]OptimizationResult, 0, iterations)
	
	for i := 0; i < initialSamples; i++ {
		params := o.generateRandomParameters(paramRanges)
		score := o.evaluateParameters(params)
		observations = append(observations, OptimizationResult{
			Parameters: params,
			Score:      score,
		})
	}
	
	// Bayesian optimization loop
	for i := initialSamples; i < iterations; i++ {
		// Find next point to evaluate using Expected Improvement
		nextParams := o.selectNextPoint(observations, paramRanges)
		
		// Evaluate
		score := o.evaluateParameters(nextParams)
		result := OptimizationResult{
			Parameters: nextParams,
			Score:      score,
		}
		observations = append(observations, result)
		
		// Update best
		if o.BestResult == nil || score > o.BestResult.Score {
			o.BestResult = &result
		}
		
		if i%10 == 0 {
			o.Logger.Printf("Iteration %d: Best score = %.4f", i, o.BestResult.Score)
		}
	}
	
	// Final evaluation with full metrics
	finalResult := o.evaluateParametersFull(o.BestResult.Parameters)
	
	return &finalResult, nil
}

// optimizationWorker processes parameter sets in parallel
func (o *Optimizer) optimizationWorker(workChan <-chan map[string]interface{}, resultChan chan<- OptimizationResult) {
	defer o.wg.Done()
	
	for params := range workChan {
		result := o.evaluateParametersFull(params)
		resultChan <- result
		
		o.mu.Lock()
		o.IterationCount++
		if o.Verbose && o.IterationCount%10 == 0 {
			o.Logger.Printf("Completed %d iterations", o.IterationCount)
		}
		o.mu.Unlock()
	}
}

// evaluateParameters runs a backtest with given parameters and returns score
func (o *Optimizer) evaluateParameters(params map[string]interface{}) float64 {
	// Clone strategy to avoid concurrent modification
	strategy := o.Strategy.Clone()
	
	// Set parameters
	if err := strategy.SetParameters(params); err != nil {
		return -math.MaxFloat64
	}
	
	// Create backtester
	backtester := &Backtester{
		Portfolio: NewPortfolio(100000),
		Strategy:  strategy,
		Symbol:    o.Symbol,
		StartDate: o.StartDate,
		EndDate:   o.EndDate,
		TimeFrame: o.TimeFrame,
		Bars:      o.Bars,
	}
	
	// Run backtest
	if err := backtester.Run(); err != nil {
		return -math.MaxFloat64
	}
	
	// Calculate objective score
	return o.calculateObjectiveScore(backtester.Results)
}

// evaluateParametersFull runs full backtest and returns complete results
func (o *Optimizer) evaluateParametersFull(params map[string]interface{}) OptimizationResult {
	strategy := o.Strategy.Clone()
	strategy.SetParameters(params)
	
	backtester := &Backtester{
		Portfolio: NewPortfolio(100000),
		Strategy:  strategy,
		Symbol:    o.Symbol,
		StartDate: o.StartDate,
		EndDate:   o.EndDate,
		TimeFrame: o.TimeFrame,
		Bars:      o.Bars,
	}
	
	if err := backtester.Run(); err != nil {
		return OptimizationResult{
			Parameters: params,
			Score:      -math.MaxFloat64,
		}
	}
	
	score := o.calculateObjectiveScore(backtester.Results)
	
	return OptimizationResult{
		Parameters:    params,
		Metrics:       backtester.Results,
		Score:         score,
		InSampleScore: score,
	}
}

// calculateObjectiveScore computes the optimization objective
func (o *Optimizer) calculateObjectiveScore(results *BacktestResults) float64 {
	if results == nil {
		return -math.MaxFloat64
	}
	
	switch o.ObjectiveFunc {
	case "sharpe":
		return results.SharpeRatio
	case "profit_factor":
		if math.IsInf(results.ProfitFactor, 1) {
			return 10.0 // Cap at 10 for infinite
		}
		return results.ProfitFactor
	case "calmar":
		return results.CalmarRatio
	case "return":
		return results.TotalReturn
	case "sortino":
		return results.SortinoRatio
	case "custom":
		// Custom scoring function combining multiple metrics
		score := 0.0
		score += results.SharpeRatio * 0.3
		score += math.Min(results.ProfitFactor, 5.0) * 0.2
		score += (results.WinRate / 100.0) * 0.2
		score += (1.0 - results.MaxDrawdownPct/100.0) * 0.3
		return score
	default:
		return results.SharpeRatio
	}
}

// walkForwardValidation performs walk-forward analysis
func (o *Optimizer) walkForwardValidation(params map[string]interface{}) float64 {
	scores := []float64{}
	
	// Calculate windows
	totalDays := int(o.EndDate.Sub(o.StartDate).Hours() / 24)
	windows := o.calculateWalkForwardWindows(totalDays)
	
	for _, window := range windows {
		// Run out-of-sample test
		strategy := o.Strategy.Clone()
		strategy.SetParameters(params)
		
		// Get data subset
		testBars := o.getBarSubset(window.TestStart, window.TestEnd)
		
		backtester := &Backtester{
			Portfolio: NewPortfolio(100000),
			Strategy:  strategy,
			Symbol:    o.Symbol,
			StartDate: window.TestStart,
			EndDate:   window.TestEnd,
			TimeFrame: o.TimeFrame,
			Bars:      testBars,
		}
		
		if err := backtester.Run(); err == nil && backtester.Results != nil {
			score := o.calculateObjectiveScore(backtester.Results)
			if !math.IsNaN(score) && !math.IsInf(score, 0) {
				scores = append(scores, score)
			}
		}
	}
	
	// Return average out-of-sample score
	if len(scores) == 0 {
		return 0
	}
	
	avg := 0.0
	for _, s := range scores {
		avg += s
	}
	return avg / float64(len(scores))
}

// WalkForwardWindow represents a train/test period
type WalkForwardWindow struct {
	TrainStart time.Time
	TrainEnd   time.Time
	TestStart  time.Time
	TestEnd    time.Time
}

// calculateWalkForwardWindows generates train/test windows
func (o *Optimizer) calculateWalkForwardWindows(totalDays int) []WalkForwardWindow {
	windows := []WalkForwardWindow{}
	
	currentStart := o.StartDate
	for {
		trainEnd := currentStart.AddDate(0, 0, o.TrainPeriodDays)
		testStart := trainEnd
		testEnd := testStart.AddDate(0, 0, o.TestPeriodDays)
		
		if testEnd.After(o.EndDate) {
			break
		}
		
		windows = append(windows, WalkForwardWindow{
			TrainStart: currentStart,
			TrainEnd:   trainEnd,
			TestStart:  testStart,
			TestEnd:    testEnd,
		})
		
		// Step forward
		currentStart = currentStart.AddDate(0, 0, o.StepDays)
	}
	
	return windows
}

// getBarSubset returns bars within date range
func (o *Optimizer) getBarSubset(start, end time.Time) []Bar {
	subset := []Bar{}
	for _, bar := range o.Bars {
		if bar.Time.After(start) && bar.Time.Before(end) {
			subset = append(subset, bar)
		}
	}
	return subset
}

// generateGridCombinations generates all parameter combinations for grid search
func (o *Optimizer) generateGridCombinations(ranges map[string]ParameterRange) []map[string]interface{} {
	// Convert ranges to slices of values
	paramValues := make(map[string][]interface{})
	for name, r := range ranges {
		values := o.generateParameterValues(r)
		paramValues[name] = values
	}
	
	// Generate cartesian product
	combinations := []map[string]interface{}{}
	o.cartesianProduct(paramValues, make(map[string]interface{}), &combinations)
	
	return combinations
}

// cartesianProduct recursively generates parameter combinations
func (o *Optimizer) cartesianProduct(paramValues map[string][]interface{}, current map[string]interface{}, result *[]map[string]interface{}) {
	if len(current) == len(paramValues) {
		// Make a copy
		combo := make(map[string]interface{})
		for k, v := range current {
			combo[k] = v
		}
		*result = append(*result, combo)
		return
	}
	
	// Find next parameter to process
	for name, values := range paramValues {
		if _, exists := current[name]; !exists {
			for _, value := range values {
				current[name] = value
				o.cartesianProduct(paramValues, current, result)
				delete(current, name)
			}
			break
		}
	}
}

// generateParameterValues generates discrete values for a parameter range
func (o *Optimizer) generateParameterValues(r ParameterRange) []interface{} {
	values := []interface{}{}
	
	switch r.Type {
	case "int":
		min := r.Min.(int)
		max := r.Max.(int)
		step := r.Step.(int)
		for v := min; v <= max; v += step {
			values = append(values, v)
		}
	case "float":
		min := r.Min.(float64)
		max := r.Max.(float64)
		step := r.Step.(float64)
		for v := min; v <= max; v += step {
			values = append(values, v)
		}
	case "bool":
		values = append(values, true, false)
	}
	
	return values
}

// generateRandomParameters generates random parameter set
func (o *Optimizer) generateRandomParameters(ranges map[string]ParameterRange) map[string]interface{} {
	params := make(map[string]interface{})
	
	for name, r := range ranges {
		switch r.Type {
		case "int":
			min := r.Min.(int)
			max := r.Max.(int)
			params[name] = min + int(math.Floor(rand.Float64()*float64(max-min+1)))
		case "float":
			min := r.Min.(float64)
			max := r.Max.(float64)
			params[name] = min + rand.Float64()*(max-min)
		case "bool":
			params[name] = rand.Float64() > 0.5
		}
	}
	
	return params
}

// tournamentSelect performs tournament selection for genetic algorithm
func (o *Optimizer) tournamentSelect(population []OptimizationResult, size int) OptimizationResult {
	best := population[int(rand.Float64()*float64(len(population)))]
	
	for i := 1; i < size; i++ {
		candidate := population[int(rand.Float64()*float64(len(population)))]
		if candidate.Score > best.Score {
			best = candidate
		}
	}
	
	return best
}

// crossover performs genetic crossover
func (o *Optimizer) crossover(parent1, parent2 map[string]interface{}) map[string]interface{} {
	child := make(map[string]interface{})
	
	for key := range parent1 {
		if rand.Float64() > 0.5 {
			child[key] = parent1[key]
		} else {
			child[key] = parent2[key]
		}
	}
	
	return child
}

// mutate performs genetic mutation
func (o *Optimizer) mutate(params map[string]interface{}, ranges map[string]ParameterRange) map[string]interface{} {
	mutated := make(map[string]interface{})
	for k, v := range params {
		mutated[k] = v
	}
	
	// Mutate one random parameter
	keys := []string{}
	for k := range params {
		keys = append(keys, k)
	}
	
	if len(keys) > 0 {
		keyToMutate := keys[int(rand.Float64()*float64(len(keys)))]
		r := ranges[keyToMutate]
		
		switch r.Type {
		case "int":
			current := mutated[keyToMutate].(int)
			min := r.Min.(int)
			max := r.Max.(int)
			step := r.Step.(int)
			
			// Small perturbation
			delta := step * (1 + int(rand.Float64()*3))
			if rand.Float64() > 0.5 {
				mutated[keyToMutate] = int(math.Min(float64(current+delta), float64(max)))
			} else {
				mutated[keyToMutate] = int(math.Max(float64(current-delta), float64(min)))
			}
		case "float":
			current := mutated[keyToMutate].(float64)
			min := r.Min.(float64)
			max := r.Max.(float64)
			
			// Gaussian mutation
			delta := (max - min) * 0.1 * (rand.Float64()*2 - 1)
			mutated[keyToMutate] = math.Max(min, math.Min(current+delta, max))
		case "bool":
			mutated[keyToMutate] = !mutated[keyToMutate].(bool)
		}
	}
	
	return mutated
}

// selectNextPoint selects next evaluation point for Bayesian optimization
func (o *Optimizer) selectNextPoint(observations []OptimizationResult, ranges map[string]ParameterRange) map[string]interface{} {
	// Simplified: Use upper confidence bound (UCB) acquisition
	// In production, use proper Gaussian Process regression
	
	bestEI := -math.MaxFloat64
	var bestParams map[string]interface{}
	
	// Sample random candidates
	for i := 0; i < 100; i++ {
		candidate := o.generateRandomParameters(ranges)
		
		// Calculate expected improvement (simplified)
		ei := o.calculateExpectedImprovement(candidate, observations)
		
		if ei > bestEI {
			bestEI = ei
			bestParams = candidate
		}
	}
	
	return bestParams
}

// calculateExpectedImprovement calculates acquisition function value
func (o *Optimizer) calculateExpectedImprovement(params map[string]interface{}, observations []OptimizationResult) float64 {
	// Simplified EI calculation
	// In production, use GP to predict mean and variance
	
	if len(observations) == 0 {
		return 1.0
	}
	
	// Find best observed value
	bestScore := -math.MaxFloat64
	for _, obs := range observations {
		if obs.Score > bestScore {
			bestScore = obs.Score
		}
	}
	
	// Calculate distance to nearest observation
	minDist := math.MaxFloat64
	for _, obs := range observations {
		dist := o.parameterDistance(params, obs.Parameters)
		if dist < minDist {
			minDist = dist
		}
	}
	
	// Higher EI for unexplored regions
	exploration := minDist / 10.0
	
	// Simple EI: exploration bonus
	return exploration
}

// parameterDistance calculates normalized distance between parameter sets
func (o *Optimizer) parameterDistance(p1, p2 map[string]interface{}) float64 {
	dist := 0.0
	count := 0
	
	for key, v1 := range p1 {
		if v2, exists := p2[key]; exists {
			switch v1.(type) {
			case int:
				dist += math.Abs(float64(v1.(int) - v2.(int)))
			case float64:
				dist += math.Abs(v1.(float64) - v2.(float64))
			case bool:
				if v1.(bool) != v2.(bool) {
					dist += 1.0
				}
			}
			count++
		}
	}
	
	if count == 0 {
		return math.MaxFloat64
	}
	
	return dist / float64(count)
}

// ExportResults exports optimization results to JSON
func (o *Optimizer) ExportResults(filename string) error {
	// Sort results by score
	sort.Slice(o.Results, func(i, j int) bool {
		return o.Results[i].Score > o.Results[j].Score
	})
	
	// Prepare export data
	exportData := map[string]interface{}{
		"symbol":           o.Symbol,
		"optimization_mode": o.OptimizationMode,
		"objective_function": o.ObjectiveFunc,
		"start_date":       o.StartDate,
		"end_date":         o.EndDate,
		"iterations":       o.IterationCount,
		"duration":         time.Since(o.StartTime).String(),
		"best_result":      o.BestResult,
		"top_10_results":   o.Results[:min(10, len(o.Results))],
	}
	
	// Write to file
	data, err := json.MarshalIndent(exportData, "", "  ")
	if err != nil {
		return err
	}
	
	return os.WriteFile(filename, data, 0644)
}

// min returns minimum of two integers
func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}

// PrintSummary prints optimization summary
func (o *Optimizer) PrintSummary() {
	if o.BestResult == nil {
		fmt.Println("No optimization results available")
		return
	}
	
	fmt.Println("\n=== OPTIMIZATION SUMMARY ===")
	fmt.Printf("Symbol: %s\n", o.Symbol)
	fmt.Printf("Mode: %s\n", o.OptimizationMode)
	fmt.Printf("Objective: %s\n", o.ObjectiveFunc)
	fmt.Printf("Iterations: %d\n", o.IterationCount)
	fmt.Printf("Duration: %v\n", time.Since(o.StartTime))
	
	fmt.Println("\n--- BEST PARAMETERS ---")
	for k, v := range o.BestResult.Parameters {
		fmt.Printf("%s: %v\n", k, v)
	}
	
	if o.BestResult.Metrics != nil {
		fmt.Println("\n--- PERFORMANCE METRICS ---")
		fmt.Printf("Score: %.4f\n", o.BestResult.Score)
		fmt.Printf("Total Return: %.2f%%\n", o.BestResult.Metrics.TotalReturn)
		fmt.Printf("Sharpe Ratio: %.2f\n", o.BestResult.Metrics.SharpeRatio)
		fmt.Printf("Profit Factor: %.2f\n", o.BestResult.Metrics.ProfitFactor)
		fmt.Printf("Win Rate: %.2f%%\n", o.BestResult.Metrics.WinRate)
		fmt.Printf("Max Drawdown: %.2f%%\n", o.BestResult.Metrics.MaxDrawdownPct)
	}
	
	if o.UseWalkForward {
		fmt.Println("\n--- WALK-FORWARD VALIDATION ---")
		fmt.Printf("In-Sample Score: %.4f\n", o.BestResult.InSampleScore)
		fmt.Printf("Out-of-Sample Score: %.4f\n", o.BestResult.OutOfSampleScore)
		fmt.Printf("Overfit Ratio: %.2f\n", o.BestResult.OverfitRatio)
		
		if o.BestResult.OverfitRatio < 0.8 {
			fmt.Println("⚠️  WARNING: Potential overfitting detected")
		} else {
			fmt.Println("✓ Model appears robust")
		}
	}
	
	fmt.Println("\n========================")
}