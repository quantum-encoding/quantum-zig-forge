package backtesting

import (
	"encoding/json"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
	// "github.com/olekukonko/tablewriter" // Temporarily disabled
)

// BacktestConfig holds configuration for a single backtest
type BacktestConfig struct {
	Strategy   string                 `json:"strategy"`
	Symbol     string                 `json:"symbol"`
	Parameters map[string]interface{} `json:"parameters"`
	StartDate  string                 `json:"start_date"`
	EndDate    string                 `json:"end_date"`
}

// BacktestResult stores comprehensive metrics from a backtest
type BacktestResult struct {
	Strategy        string                   `json:"strategy"`
	Symbol          string                   `json:"symbol"`
	Parameters      map[string]interface{}   `json:"parameters"`
	Metrics         *BacktestResults `json:"metrics"`
	MonthlyReturns  []float64                `json:"monthly_returns"`
	RollingMetrics  map[string][]float64     `json:"rolling_metrics"`
	TradeStatistics map[string]interface{}   `json:"trade_statistics"`
	RiskMetrics     map[string]float64       `json:"risk_metrics"`
	Timestamp       string                   `json:"timestamp"`
}

// BacktestSuite manages comprehensive backtesting
type BacktestSuite struct {
	dataClient     *marketdata.Client
	results        []BacktestResult
	outputDir      string
	verbose        bool
	compareMode    bool
	benchmarkSymbol string
}

func NewBacktestSuite(apiKey, apiSecret, outputDir string) *BacktestSuite {
	return &BacktestSuite{
		dataClient: marketdata.NewClient(marketdata.ClientOpts{
			APIKey:    apiKey,
			APISecret: apiSecret,
		}),
		outputDir:       outputDir,
		benchmarkSymbol: "SPY",
		verbose:         true,
	}
}

// LoadOptimizedParameters loads parameters from optimization output
func (bs *BacktestSuite) LoadOptimizedParameters(paramsDir string) ([]BacktestConfig, error) {
	var configs []BacktestConfig
	
	files, err := ioutil.ReadDir(paramsDir)
	if err != nil {
		return nil, err
	}
	
	for _, file := range files {
		if !strings.HasSuffix(file.Name(), ".json") || 
		   strings.Contains(file.Name(), "summary") {
			continue
		}
		
		// Parse filename: strategy_symbol.json
		parts := strings.Split(strings.TrimSuffix(file.Name(), ".json"), "_")
		if len(parts) < 2 {
			continue
		}
		
		strategy := parts[0]
		symbol := parts[1]
		
		// Read parameter file
		data, err := ioutil.ReadFile(filepath.Join(paramsDir, file.Name()))
		if err != nil {
			log.Printf("Failed to read %s: %v", file.Name(), err)
			continue
		}
		
		var params map[string]interface{}
		if err := json.Unmarshal(data, &params); err != nil {
			log.Printf("Failed to parse %s: %v", file.Name(), err)
			continue
		}
		
		// Extract parameters from the optimization result
		if paramMap, ok := params["parameters"].(map[string]interface{}); ok {
			configs = append(configs, BacktestConfig{
				Strategy:   strategy,
				Symbol:     symbol,
				Parameters: paramMap,
				StartDate:  "2022-01-01", // Test on recent data
				EndDate:    "2024-01-01",
			})
		}
	}
	
	return configs, nil
}

// RunBacktest executes a single backtest with comprehensive metrics
func (bs *BacktestSuite) RunBacktest(config BacktestConfig) (*BacktestResult, error) {
	// Parse dates
	start, err := time.Parse("2006-01-02", config.StartDate)
	if err != nil {
		return nil, fmt.Errorf("invalid start date: %v", err)
	}
	end, err := time.Parse("2006-01-02", config.EndDate)
	if err != nil {
		return nil, fmt.Errorf("invalid end date: %v", err)
	}
	
	// Create strategy instance
	strategy, err := bs.createStrategy(config.Strategy, config.Symbol, config.Parameters)
	if err != nil {
		return nil, err
	}
	
	// Create backtester
	bt := NewBacktester(strategy, config.Symbol, start, end) // Create with proper args
	bt.Portfolio = NewPortfolio(100000) // Set $100k initial capital
	
	// Load market data
	if bs.verbose {
		log.Printf("Loading data for %s from %s to %s", 
			config.Symbol, config.StartDate, config.EndDate)
	}
	
	if err := bt.LoadData(bs.dataClient); err != nil {
		return nil, fmt.Errorf("failed to load data: %v", err)
	}
	
	// Run backtest
	if bs.verbose {
		log.Printf("Running backtest for %s/%s", config.Strategy, config.Symbol)
	}
	
	err = bt.Run()
	if err != nil {
		return nil, fmt.Errorf("backtest failed: %v", err)
	}
	
	// Calculate additional metrics
	result := &BacktestResult{
		Strategy:   config.Strategy,
		Symbol:     config.Symbol,
		Parameters: config.Parameters,
		Metrics:    bt.Results, // Use the Results field from backtester
		Timestamp:  time.Now().Format(time.RFC3339),
	}
	
	// Extract monthly returns (placeholder)
	result.MonthlyReturns = make([]float64, 0)
	
	// Calculate rolling metrics (placeholder - will implement later)
	result.RollingMetrics = map[string][]float64{
		"rolling_sharpe":    make([]float64, 0),
		"rolling_max_dd":    make([]float64, 0),
		"rolling_win_rate":  make([]float64, 0),
	}
	
	// Trade statistics
	result.TradeStatistics = map[string]interface{}{
		"total_trades":       bt.Results.TotalTrades,
		"winning_trades":     0, // Will calculate from portfolio data
		"losing_trades":      0, // Will calculate from portfolio data
		"avg_win":            bt.Results.AverageWin,
		"avg_loss":           bt.Results.AverageLoss,
		"largest_win":        bt.Results.LargestWin,
		"largest_loss":       bt.Results.LargestLoss,
		"avg_trade_duration": bt.Results.AverageHoldTime,
		"profit_factor":      bt.Results.ProfitFactor,
		"expectancy":         bt.Results.ExpectedValue,
		"consecutive_wins":   bt.Results.MaxConsecutiveWins,
		"consecutive_losses": bt.Results.MaxConsecutiveLosses,
	}
	
	// Risk metrics
	result.RiskMetrics = map[string]float64{
		"sharpe_ratio":       bt.Results.SharpeRatio,
		"sortino_ratio":      bt.Results.SortinoRatio,
		"calmar_ratio":       bt.Results.CalmarRatio,
		"ulcer_index":        0.0, // Not implemented in BacktestResults
		"max_drawdown_pct":   bt.Results.MaxDrawdownPct,
		"max_drawdown_days":  0.0, // Not implemented in BacktestResults
		"var_95":             0.0, // Not implemented in BacktestResults
		"cvar_95":            0.0, // Not implemented in BacktestResults
		"downside_deviation": 0.0, // Not implemented in BacktestResults
		"beta":               0.0, // Not implemented in BacktestResults
		"alpha":              0.0, // Not implemented in BacktestResults
		"treynor_ratio":      0.0, // Not implemented in BacktestResults
	}
	
	return result, nil
}

// createStrategy creates a strategy instance with parameters
func (bs *BacktestSuite) createStrategy(name, symbol string, params map[string]interface{}) (BacktestStrategy, error) {
	strategy, err := CreateBacktestStrategy(name, symbol)
	if err != nil {
		return nil, err
	}
	
	// Set parameters if the strategy supports it
	if paramSetter, ok := strategy.(interface{ SetParameters(map[string]interface{}) error }); ok {
		if err := paramSetter.SetParameters(params); err != nil {
			return nil, err
		}
	}
	
	return strategy, nil
}

// RunBatchBacktests runs all backtests and generates comparative analysis
func (bs *BacktestSuite) RunBatchBacktests(configs []BacktestConfig) error {
	log.Printf("Running %d backtests", len(configs))
	
	for i, config := range configs {
		log.Printf("Backtest %d/%d: %s/%s", i+1, len(configs), 
			config.Strategy, config.Symbol)
		
		result, err := bs.RunBacktest(config)
		if err != nil {
			log.Printf("Failed: %v", err)
			continue
		}
		
		bs.results = append(bs.results, *result)
		
		// Save individual result
		if err := bs.saveResult(result); err != nil {
			log.Printf("Failed to save result: %v", err)
		}
		
		// Brief pause to avoid rate limits
		time.Sleep(time.Second)
	}
	
	// Generate comparison report
	if len(bs.results) > 0 {
		bs.generateComparisonReport()
		bs.generatePerformanceSummary()
		bs.generateRiskReport()
	}
	
	return nil
}

// saveResult saves individual backtest result
func (bs *BacktestSuite) saveResult(result *BacktestResult) error {
	filename := fmt.Sprintf("%s_%s_backtest.json", result.Strategy, result.Symbol)
	filepath := filepath.Join(bs.outputDir, filename)
	
	data, err := json.MarshalIndent(result, "", "  ")
	if err != nil {
		return err
	}
	
	return ioutil.WriteFile(filepath, data, 0644)
}

// generateComparisonReport creates comparative analysis
func (bs *BacktestSuite) generateComparisonReport() {
	// Sort results by Sharpe ratio
	sort.Slice(bs.results, func(i, j int) bool {
		return bs.results[i].Metrics.SharpeRatio > bs.results[j].Metrics.SharpeRatio
	})
	
	// Create comparison table (temporarily disabled)
	// table := tablewriter.NewWriter(os.Stdout)
	// table.SetHeader([]string{
	// 	"Strategy", "Symbol", "Return %", "Sharpe", "Max DD %", 
	// 	"Win Rate", "Trades", "Profit Factor",
	// })
	
	var markdownTable strings.Builder
	markdownTable.WriteString("# Backtest Results Comparison\n\n")
	markdownTable.WriteString("| Strategy | Symbol | Return % | Sharpe | Max DD % | Win Rate | Trades | Profit Factor |\n")
	markdownTable.WriteString("|----------|--------|----------|--------|----------|----------|--------|---------------|\n")
	
	for _, result := range bs.results {
		// Removed row creation as table is disabled
		
		markdownTable.WriteString(fmt.Sprintf("| %s | %s | %.2f | %.2f | %.2f | %.2f%% | %d | %.2f |\n",
			result.Strategy, result.Symbol,
			result.Metrics.TotalReturn,
			result.Metrics.SharpeRatio,
			result.Metrics.MaxDrawdownPct,
			result.Metrics.WinRate*100,
			result.Metrics.TotalTrades,
			result.Metrics.ProfitFactor))
	}
	
	// Save comparison report
	reportPath := filepath.Join(bs.outputDir, "comparison_report.md")
	ioutil.WriteFile(reportPath, []byte(markdownTable.String()), 0644)
	
	// Print to console
	fmt.Println("\n═══════════════════════════════════════════════════════════════")
	fmt.Println("                    BACKTEST COMPARISON")
	fmt.Println("═══════════════════════════════════════════════════════════════")
	// table.Render() // Temporarily disabled - will use markdown output
}

// generatePerformanceSummary creates performance analytics
func (bs *BacktestSuite) generatePerformanceSummary() {
	report := "# Performance Summary Report\n\n"
	report += fmt.Sprintf("Generated: %s\n\n", time.Now().Format(time.RFC3339))
	
	// Top performers by different metrics
	report += "## Top Performers\n\n"
	
	// By Sharpe Ratio
	report += "### By Sharpe Ratio\n"
	sort.Slice(bs.results, func(i, j int) bool {
		return bs.results[i].Metrics.SharpeRatio > bs.results[j].Metrics.SharpeRatio
	})
	for i := 0; i < min(5, len(bs.results)); i++ {
		r := bs.results[i]
		report += fmt.Sprintf("%d. %s/%s: %.2f\n", i+1, r.Strategy, r.Symbol, r.Metrics.SharpeRatio)
	}
	
	// By Total Return
	report += "\n### By Total Return\n"
	sort.Slice(bs.results, func(i, j int) bool {
		return bs.results[i].Metrics.TotalReturn > bs.results[j].Metrics.TotalReturn
	})
	for i := 0; i < min(5, len(bs.results)); i++ {
		r := bs.results[i]
		report += fmt.Sprintf("%d. %s/%s: %.2f%%\n", i+1, r.Strategy, r.Symbol, r.Metrics.TotalReturn)
	}
	
	// By Profit Factor
	report += "\n### By Profit Factor\n"
	sort.Slice(bs.results, func(i, j int) bool {
		return bs.results[i].Metrics.ProfitFactor > bs.results[j].Metrics.ProfitFactor
	})
	for i := 0; i < min(5, len(bs.results)); i++ {
		r := bs.results[i]
		report += fmt.Sprintf("%d. %s/%s: %.2f\n", i+1, r.Strategy, r.Symbol, r.Metrics.ProfitFactor)
	}
	
	// Strategy-specific analysis
	report += "\n## Strategy Analysis\n\n"
	strategyGroups := make(map[string][]BacktestResult)
	for _, r := range bs.results {
		strategyGroups[r.Strategy] = append(strategyGroups[r.Strategy], r)
	}
	
	for strategy, results := range strategyGroups {
		report += fmt.Sprintf("### %s Strategy\n", strings.ToUpper(strategy))
		report += fmt.Sprintf("- Tested on %d symbols\n", len(results))
		
		avgSharpe := 0.0
		avgReturn := 0.0
		for _, r := range results {
			avgSharpe += r.Metrics.SharpeRatio
			avgReturn += r.Metrics.TotalReturn
		}
		avgSharpe /= float64(len(results))
		avgReturn /= float64(len(results))
		
		report += fmt.Sprintf("- Average Sharpe: %.2f\n", avgSharpe)
		report += fmt.Sprintf("- Average Return: %.2f%%\n", avgReturn)
		report += "\n"
	}
	
	// Save report
	reportPath := filepath.Join(bs.outputDir, "performance_summary.md")
	ioutil.WriteFile(reportPath, []byte(report), 0644)
}

// generateRiskReport creates risk analysis report
func (bs *BacktestSuite) generateRiskReport() {
	report := "# Risk Analysis Report\n\n"
	report += fmt.Sprintf("Generated: %s\n\n", time.Now().Format(time.RFC3339))
	
	// Risk scoring
	report += "## Risk Scores\n\n"
	report += "Risk scores (lower is better):\n\n"
	
	type RiskScore struct {
		Strategy string
		Symbol   string
		Score    float64
	}
	
	var scores []RiskScore
	for _, r := range bs.results {
		// Simple risk score: combination of max drawdown, downside deviation, and ulcer index
		score := r.Metrics.MaxDrawdownPct + 
			r.RiskMetrics["downside_deviation"]*10 + 
			r.RiskMetrics["ulcer_index"]*5
		
		scores = append(scores, RiskScore{
			Strategy: r.Strategy,
			Symbol:   r.Symbol,
			Score:    score,
		})
	}
	
	sort.Slice(scores, func(i, j int) bool {
		return scores[i].Score < scores[j].Score
	})
	
	for i := 0; i < min(10, len(scores)); i++ {
		s := scores[i]
		report += fmt.Sprintf("%d. %s/%s: %.2f\n", i+1, s.Strategy, s.Symbol, s.Score)
	}
	
	// Save report
	reportPath := filepath.Join(bs.outputDir, "risk_report.md")
	ioutil.WriteFile(reportPath, []byte(report), 0644)
}

// Using min function from optimizer.go

// RunBacktestCLI is the main entry point for the backtest CLI
func RunBacktestCLI() {
	// Command line flags
	var (
		paramsDir  = flag.String("params", "", "Directory with optimized parameters")
		outputDir  = flag.String("output", "backtest_results", "Output directory")
		configFile = flag.String("config", "", "Custom backtest configuration file")
		apiKey     = flag.String("api-key", "", "Alpaca API key")
		apiSecret  = flag.String("api-secret", "", "Alpaca API secret")
		verbose    = flag.Bool("verbose", true, "Verbose output")
	)
	flag.Parse()
	
	// Setup logging
	logFile, err := os.OpenFile("backtests.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		log.Fatal("Failed to open log file:", err)
	}
	defer logFile.Close()
	log.SetOutput(logFile)
	
	// Get API credentials
	if *apiKey == "" {
		*apiKey = os.Getenv("APCA_API_KEY_ID")
	}
	if *apiSecret == "" {
		*apiSecret = os.Getenv("APCA_API_SECRET_KEY")
	}
	
	if *apiKey == "" || *apiSecret == "" {
		log.Fatal("API credentials required")
	}
	
	// Create output directory
	if err := os.MkdirAll(*outputDir, 0755); err != nil {
		log.Fatal("Failed to create output directory:", err)
	}
	
	// Create backtest suite
	suite := NewBacktestSuite(*apiKey, *apiSecret, *outputDir)
	suite.verbose = *verbose
	
	// Load configurations
	var configs []BacktestConfig
	
	if *paramsDir != "" {
		// Load from optimized parameters
		configs, err = suite.LoadOptimizedParameters(*paramsDir)
		if err != nil {
			log.Fatal("Failed to load parameters:", err)
		}
	} else if *configFile != "" {
		// Load from config file
		data, err := ioutil.ReadFile(*configFile)
		if err != nil {
			log.Fatal("Failed to read config file:", err)
		}
		if err := json.Unmarshal(data, &configs); err != nil {
			log.Fatal("Failed to parse config file:", err)
		}
	} else {
		// Default test configurations
		configs = []BacktestConfig{
			{Strategy: "rsi", Symbol: "SPY", StartDate: "2022-01-01", EndDate: "2024-01-01"},
			{Strategy: "ma", Symbol: "SPY", StartDate: "2022-01-01", EndDate: "2024-01-01"},
			{Strategy: "bb", Symbol: "SPY", StartDate: "2022-01-01", EndDate: "2024-01-01"},
			{Strategy: "macd", Symbol: "SPY", StartDate: "2022-01-01", EndDate: "2024-01-01"},
		}
	}
	
	// Run backtests
	fmt.Println("═══════════════════════════════════════════════════════════════")
	fmt.Println("       THE GREAT SYNAPSE - COMPREHENSIVE BACKTESTING")
	fmt.Println("═══════════════════════════════════════════════════════════════")
	fmt.Printf("Running %d backtests\n", len(configs))
	fmt.Printf("Output directory: %s\n\n", *outputDir)
	
	if err := suite.RunBatchBacktests(configs); err != nil {
		log.Fatal("Batch backtests failed:", err)
	}
	
	fmt.Println("\n═══════════════════════════════════════════════════════════════")
	fmt.Println("                    BACKTESTING COMPLETE")
	fmt.Println("═══════════════════════════════════════════════════════════════")
	fmt.Printf("Results saved to: %s\n", *outputDir)
	fmt.Printf("Comparison report: %s/comparison_report.md\n", *outputDir)
	fmt.Printf("Performance summary: %s/performance_summary.md\n", *outputDir)
	fmt.Printf("Risk report: %s/risk_report.md\n", *outputDir)
}