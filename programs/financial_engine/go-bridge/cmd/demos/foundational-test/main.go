package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"time"
	"zig-hft-bridge/backtesting"

	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
)

// FoundationalStrategiesTest runs comprehensive backtests on all core strategies
type FoundationalStrategiesTest struct {
	dataClient *marketdata.Client
	symbols    []string
	startDate  time.Time
	endDate    time.Time
	outputDir  string
}

// NewFoundationalStrategiesTest creates a new test suite
func NewFoundationalStrategiesTest() *FoundationalStrategiesTest {
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	if apiKey == "" || apiSecret == "" {
		log.Fatal("API credentials required. Set APCA_API_KEY_ID and APCA_API_SECRET_KEY environment variables")
	}
	
	// Test end date (2 years of data for robust backtesting)
	endDate := time.Now().AddDate(0, -1, 0)   // 1 month ago to avoid incomplete data
	startDate := endDate.AddDate(-2, 0, 0)    // 2 years of historical data
	
	return &FoundationalStrategiesTest{
		dataClient: marketdata.NewClient(marketdata.ClientOpts{
			APIKey:    apiKey,
			APISecret: apiSecret,
		}),
		symbols:   []string{"SPY", "AAPL", "GOOGL", "MSFT", "TSLA"}, // Mix of ETF and tech stocks
		startDate: startDate,
		endDate:   endDate,
		outputDir: "foundational_backtest_results",
	}
}

// TestStrategy runs a comprehensive test on a single strategy
func (ft *FoundationalStrategiesTest) TestStrategy(strategyName, symbol string, params map[string]interface{}) (*backtesting.BacktestResults, error) {
	log.Printf("Testing %s strategy on %s", strategyName, symbol)
	
	// Create strategy instance
	strategy, err := backtesting.CreateBacktestStrategy(strategyName, symbol)
	if err != nil {
		return nil, fmt.Errorf("failed to create strategy: %w", err)
	}
	
	// Set parameters if provided
	if len(params) > 0 {
		if paramSetter, ok := strategy.(interface{ SetParameters(map[string]interface{}) error }); ok {
			if err := paramSetter.SetParameters(params); err != nil {
				return nil, fmt.Errorf("failed to set parameters: %w", err)
			}
		}
	}
	
	// Create backtester with realistic settings
	bt := backtesting.NewBacktester(strategy, symbol, ft.startDate, ft.endDate)
	
	// Configure portfolio with realistic parameters
	bt.Portfolio = backtesting.NewPortfolio(100000) // $100k starting capital
	bt.Portfolio.MaxPositionSize = 0.10              // Max 10% per position
	bt.Portfolio.MaxPositions = 5                    // Max 5 concurrent positions
	bt.Portfolio.Slippage = 0.001                   // 0.1% slippage (realistic for liquid stocks)
	bt.Portfolio.Commission = 0.005                  // $0.005 per share (realistic commission)
	
	// Load historical data
	if err := bt.LoadData(ft.dataClient); err != nil {
		return nil, fmt.Errorf("failed to load data: %w", err)
	}
	
	if len(bt.Bars) == 0 {
		return nil, fmt.Errorf("no historical data found for %s", symbol)
	}
	
	log.Printf("Loaded %d bars for %s from %s to %s", 
		len(bt.Bars), symbol, ft.startDate.Format("2006-01-02"), ft.endDate.Format("2006-01-02"))
	
	// Run backtest
	if err := bt.Run(); err != nil {
		return nil, fmt.Errorf("backtest failed: %w", err)
	}
	
	log.Printf("Backtest completed for %s/%s - Trades: %d, Return: %.2f%%, Sharpe: %.2f", 
		strategyName, symbol, 
		bt.Results.TotalTrades,
		bt.Results.TotalReturn,
		bt.Results.SharpeRatio)
	
	return bt.Results, nil
}

// RunComprehensiveTests runs all foundational strategies across all symbols
func (ft *FoundationalStrategiesTest) RunComprehensiveTests() error {
	// Create output directory
	if err := os.MkdirAll(ft.outputDir, 0755); err != nil {
		return fmt.Errorf("failed to create output directory: %w", err)
	}
	
	// Define strategies and their default parameters
	strategies := map[string]map[string]interface{}{
		"rsi": {
			"rsi_period":      14,
			"oversold_level":  30.0,
			"overbought_level": 70.0,
			"stop_loss_pct":   0.05,
			"take_profit_pct": 0.10,
		},
		"ma": {
			"short_period":    10,
			"long_period":     20,
			"stop_loss_pct":   0.05,
			"take_profit_pct": 0.10,
		},
		"bb": {
			"period":          20,
			"num_std_dev":     2.0,
			"stop_loss_pct":   0.05,
			"take_profit_pct": 0.10,
		},
		"macd": {
			"fast_period":     12,
			"slow_period":     26,
			"signal_period":   9,
			"stop_loss_pct":   0.05,
			"take_profit_pct": 0.10,
		},
		"vwap": {
			"vwap_period":     20,
			"deviation_pct":   0.02,
			"stop_loss_pct":   0.05,
			"take_profit_pct": 0.10,
		},
	}
	
	// Track all results for comparison
	var allResults []map[string]interface{}
	
	fmt.Println("═══════════════════════════════════════════════════════════════")
	fmt.Println("           THE GREAT SYNAPSE - FOUNDATIONAL VALIDATION")
	fmt.Println("═══════════════════════════════════════════════════════════════")
	fmt.Printf("Testing %d strategies across %d symbols\n", len(strategies), len(ft.symbols))
	fmt.Printf("Period: %s to %s\n", ft.startDate.Format("2006-01-02"), ft.endDate.Format("2006-01-02"))
	fmt.Println("═══════════════════════════════════════════════════════════════")
	
	// Test each strategy on each symbol
	for strategyName, params := range strategies {
		for _, symbol := range ft.symbols {
			results, err := ft.TestStrategy(strategyName, symbol, params)
			if err != nil {
				log.Printf("ERROR: %s/%s failed: %v", strategyName, symbol, err)
				continue
			}
			
			// Store results for comparison
			result := map[string]interface{}{
				"strategy":         strategyName,
				"symbol":          symbol,
				"parameters":      params,
				"total_return":    results.TotalReturn,
				"sharpe_ratio":    results.SharpeRatio,
				"max_drawdown":    results.MaxDrawdownPct,
				"total_trades":    results.TotalTrades,
				"win_rate":        results.WinRate,
				"profit_factor":   results.ProfitFactor,
				"sortino_ratio":   results.SortinoRatio,
				"calmar_ratio":    results.CalmarRatio,
				"largest_win":     results.LargestWin,
				"largest_loss":    results.LargestLoss,
				"avg_trade":       results.AverageTrade,
				"avg_win":         results.AverageWin,
				"avg_loss":        results.AverageLoss,
				"hold_time":       results.AverageHoldTime.String(),
				"test_date":       time.Now().Format(time.RFC3339),
			}
			allResults = append(allResults, result)
			
			// Save individual result
			filename := fmt.Sprintf("%s/%s_%s_results.json", ft.outputDir, strategyName, symbol)
			if err := ft.saveResult(result, filename); err != nil {
				log.Printf("Failed to save %s: %v", filename, err)
			}
		}
	}
	
	// Generate comprehensive analysis
	if err := ft.generateAnalysis(allResults); err != nil {
		return fmt.Errorf("failed to generate analysis: %w", err)
	}
	
	// Print summary
	ft.printSummary(allResults)
	
	return nil
}

// saveResult saves individual test results to JSON
func (ft *FoundationalStrategiesTest) saveResult(result map[string]interface{}, filename string) error {
	data, err := json.MarshalIndent(result, "", "  ")
	if err != nil {
		return err
	}
	return os.WriteFile(filename, data, 0644)
}

// generateAnalysis creates comprehensive performance analysis reports
func (ft *FoundationalStrategiesTest) generateAnalysis(results []map[string]interface{}) error {
	// Performance ranking report
	if err := ft.generateRankingReport(results); err != nil {
		return err
	}
	
	// Risk analysis report
	if err := ft.generateRiskReport(results); err != nil {
		return err
	}
	
	// Strategy-specific analysis
	if err := ft.generateStrategyReport(results); err != nil {
		return err
	}
	
	// Symbol-specific analysis
	if err := ft.generateSymbolReport(results); err != nil {
		return err
	}
	
	return nil
}

// generateRankingReport creates performance ranking analysis
func (ft *FoundationalStrategiesTest) generateRankingReport(results []map[string]interface{}) error {
	report := fmt.Sprintf(`# The Great Synapse - Performance Rankings

Generated: %s
Period: %s to %s
Total Tests: %d

## Top Performers by Sharpe Ratio

`, time.Now().Format(time.RFC3339), ft.startDate.Format("2006-01-02"), ft.endDate.Format("2006-01-02"), len(results))
	
	// Sort by Sharpe Ratio
	sortedResults := make([]map[string]interface{}, len(results))
	copy(sortedResults, results)
	
	for i := 0; i < len(sortedResults)-1; i++ {
		for j := i + 1; j < len(sortedResults); j++ {
			sharpeI := sortedResults[i]["sharpe_ratio"].(float64)
			sharpeJ := sortedResults[j]["sharpe_ratio"].(float64)
			if sharpeJ > sharpeI {
				sortedResults[i], sortedResults[j] = sortedResults[j], sortedResults[i]
			}
		}
	}
	
	report += "| Rank | Strategy | Symbol | Sharpe | Return% | MaxDD% | Trades | Win% | Profit Factor |\n"
	report += "|------|----------|--------|--------|---------|--------|--------|------|---------------|\n"
	
	for i, result := range sortedResults {
		if i >= 10 { // Top 10
			break
		}
		report += fmt.Sprintf("| %d | %s | %s | %.2f | %.2f | %.2f | %d | %.1f | %.2f |\n",
			i+1,
			result["strategy"].(string),
			result["symbol"].(string),
			result["sharpe_ratio"].(float64),
			result["total_return"].(float64),
			result["max_drawdown"].(float64),
			result["total_trades"].(int),
			result["win_rate"].(float64)*100,
			result["profit_factor"].(float64))
	}
	
	// Add analysis by strategy
	report += "\n## Strategy Performance Summary\n\n"
	strategyStats := make(map[string][]float64)
	for _, result := range results {
		strategy := result["strategy"].(string)
		sharpe := result["sharpe_ratio"].(float64)
		strategyStats[strategy] = append(strategyStats[strategy], sharpe)
	}
	
	for strategy, sharpes := range strategyStats {
		avg := 0.0
		for _, s := range sharpes {
			avg += s
		}
		avg /= float64(len(sharpes))
		
		report += fmt.Sprintf("- **%s**: Average Sharpe %.2f across %d tests\n", strategy, avg, len(sharpes))
	}
	
	filename := fmt.Sprintf("%s/performance_rankings.md", ft.outputDir)
	return os.WriteFile(filename, []byte(report), 0644)
}

// generateRiskReport creates risk analysis
func (ft *FoundationalStrategiesTest) generateRiskReport(results []map[string]interface{}) error {
	report := fmt.Sprintf(`# Risk Analysis Report

Generated: %s

## Maximum Drawdown Analysis

`, time.Now().Format(time.RFC3339))
	
	// Sort by max drawdown (ascending - lower is better)
	sortedResults := make([]map[string]interface{}, len(results))
	copy(sortedResults, results)
	
	for i := 0; i < len(sortedResults)-1; i++ {
		for j := i + 1; j < len(sortedResults); j++ {
			ddI := sortedResults[i]["max_drawdown"].(float64)
			ddJ := sortedResults[j]["max_drawdown"].(float64)
			if ddJ < ddI {
				sortedResults[i], sortedResults[j] = sortedResults[j], sortedResults[i]
			}
		}
	}
	
	report += "| Rank | Strategy | Symbol | MaxDD% | Sharpe | Sortino | Calmar |\n"
	report += "|------|----------|--------|--------|--------|---------|--------|\n"
	
	for i, result := range sortedResults {
		if i >= 10 { // Top 10 lowest drawdowns
			break
		}
		report += fmt.Sprintf("| %d | %s | %s | %.2f | %.2f | %.2f | %.2f |\n",
			i+1,
			result["strategy"].(string),
			result["symbol"].(string),
			result["max_drawdown"].(float64),
			result["sharpe_ratio"].(float64),
			result["sortino_ratio"].(float64),
			result["calmar_ratio"].(float64))
	}
	
	filename := fmt.Sprintf("%s/risk_analysis.md", ft.outputDir)
	return os.WriteFile(filename, []byte(report), 0644)
}

// generateStrategyReport creates strategy-specific analysis
func (ft *FoundationalStrategiesTest) generateStrategyReport(results []map[string]interface{}) error {
	report := fmt.Sprintf(`# Strategy-Specific Analysis

Generated: %s

`, time.Now().Format(time.RFC3339))
	
	// Group by strategy
	strategyGroups := make(map[string][]map[string]interface{})
	for _, result := range results {
		strategy := result["strategy"].(string)
		strategyGroups[strategy] = append(strategyGroups[strategy], result)
	}
	
	for strategy, strategyResults := range strategyGroups {
		report += fmt.Sprintf("## %s Strategy\n\n", strategy)
		
		// Calculate statistics
		totalReturn := 0.0
		sharpe := 0.0
		maxDD := 0.0
		trades := 0
		winRate := 0.0
		
		for _, result := range strategyResults {
			totalReturn += result["total_return"].(float64)
			sharpe += result["sharpe_ratio"].(float64)
			maxDD += result["max_drawdown"].(float64)
			trades += result["total_trades"].(int)
			winRate += result["win_rate"].(float64)
		}
		
		count := float64(len(strategyResults))
		report += fmt.Sprintf("- Tests: %d\n", len(strategyResults))
		report += fmt.Sprintf("- Average Return: %.2f%%\n", totalReturn/count)
		report += fmt.Sprintf("- Average Sharpe: %.2f\n", sharpe/count)
		report += fmt.Sprintf("- Average MaxDD: %.2f%%\n", maxDD/count)
		report += fmt.Sprintf("- Total Trades: %d\n", trades)
		report += fmt.Sprintf("- Average Win Rate: %.1f%%\n", (winRate/count)*100)
		report += "\n"
		
		// Best and worst performance for this strategy
		best := strategyResults[0]
		worst := strategyResults[0]
		
		for _, result := range strategyResults {
			if result["sharpe_ratio"].(float64) > best["sharpe_ratio"].(float64) {
				best = result
			}
			if result["sharpe_ratio"].(float64) < worst["sharpe_ratio"].(float64) {
				worst = result
			}
		}
		
		report += fmt.Sprintf("- Best Performance: %s (Sharpe: %.2f)\n", best["symbol"].(string), best["sharpe_ratio"].(float64))
		report += fmt.Sprintf("- Worst Performance: %s (Sharpe: %.2f)\n\n", worst["symbol"].(string), worst["sharpe_ratio"].(float64))
	}
	
	filename := fmt.Sprintf("%s/strategy_analysis.md", ft.outputDir)
	return os.WriteFile(filename, []byte(report), 0644)
}

// generateSymbolReport creates symbol-specific analysis
func (ft *FoundationalStrategiesTest) generateSymbolReport(results []map[string]interface{}) error {
	report := fmt.Sprintf(`# Symbol-Specific Analysis

Generated: %s

`, time.Now().Format(time.RFC3339))
	
	// Group by symbol
	symbolGroups := make(map[string][]map[string]interface{})
	for _, result := range results {
		symbol := result["symbol"].(string)
		symbolGroups[symbol] = append(symbolGroups[symbol], result)
	}
	
	for symbol, symbolResults := range symbolGroups {
		report += fmt.Sprintf("## %s Analysis\n\n", symbol)
		
		// Find best strategy for this symbol
		best := symbolResults[0]
		for _, result := range symbolResults {
			if result["sharpe_ratio"].(float64) > best["sharpe_ratio"].(float64) {
				best = result
			}
		}
		
		report += fmt.Sprintf("- Best Strategy: %s (Sharpe: %.2f, Return: %.2f%%)\n", 
			best["strategy"].(string), best["sharpe_ratio"].(float64), best["total_return"].(float64))
		
		// Calculate average performance across all strategies
		totalReturn := 0.0
		sharpe := 0.0
		for _, result := range symbolResults {
			totalReturn += result["total_return"].(float64)
			sharpe += result["sharpe_ratio"].(float64)
		}
		
		count := float64(len(symbolResults))
		report += fmt.Sprintf("- Average Return across strategies: %.2f%%\n", totalReturn/count)
		report += fmt.Sprintf("- Average Sharpe across strategies: %.2f\n\n", sharpe/count)
	}
	
	filename := fmt.Sprintf("%s/symbol_analysis.md", ft.outputDir)
	return os.WriteFile(filename, []byte(report), 0644)
}

// printSummary prints a concise summary to console
func (ft *FoundationalStrategiesTest) printSummary(results []map[string]interface{}) {
	fmt.Println("\n═══════════════════════════════════════════════════════════════")
	fmt.Println("                    VALIDATION SUMMARY")
	fmt.Println("═══════════════════════════════════════════════════════════════")
	
	// Find overall best performers
	bestSharpe := results[0]
	bestReturn := results[0]
	
	for _, result := range results {
		if result["sharpe_ratio"].(float64) > bestSharpe["sharpe_ratio"].(float64) {
			bestSharpe = result
		}
		if result["total_return"].(float64) > bestReturn["total_return"].(float64) {
			bestReturn = result
		}
	}
	
	fmt.Printf("Best Sharpe Ratio: %s/%s (%.2f)\n", 
		bestSharpe["strategy"].(string), bestSharpe["symbol"].(string), bestSharpe["sharpe_ratio"].(float64))
	fmt.Printf("Best Total Return: %s/%s (%.2f%%)\n",
		bestReturn["strategy"].(string), bestReturn["symbol"].(string), bestReturn["total_return"].(float64))
	
	// Calculate overall statistics
	totalTests := len(results)
	profitableTests := 0
	totalTrades := 0
	
	for _, result := range results {
		if result["total_return"].(float64) > 0 {
			profitableTests++
		}
		totalTrades += result["total_trades"].(int)
	}
	
	fmt.Printf("Total Tests: %d\n", totalTests)
	fmt.Printf("Profitable Tests: %d (%.1f%%)\n", profitableTests, float64(profitableTests)/float64(totalTests)*100)
	fmt.Printf("Total Trades Executed: %d\n", totalTrades)
	
	fmt.Printf("\nResults saved to: %s/\n", ft.outputDir)
	fmt.Println("═══════════════════════════════════════════════════════════════")
}

func main() {
	// Create and run the foundational strategies test
	test := NewFoundationalStrategiesTest()
	
	if err := test.RunComprehensiveTests(); err != nil {
		log.Fatalf("Test suite failed: %v", err)
	}
	
	fmt.Println("Foundational strategies validation completed successfully!")
}