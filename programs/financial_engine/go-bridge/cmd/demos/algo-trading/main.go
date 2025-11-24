package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"zig-hft-bridge/strategies"
)

func main() {
	// Command line flags
	var (
		strategyType = flag.String("strategy", "both", "Strategy to run: ma, rsi, or both")
		symbol       = flag.String("symbol", "SPY", "Trading symbol")
		maShort      = flag.Int("ma-short", 50, "Short MA window")
		maLong       = flag.Int("ma-long", 200, "Long MA window")
		rsiPeriod    = flag.Int("rsi-period", 14, "RSI period")
		paperMode    = flag.Bool("paper", true, "Use paper trading")
	)
	flag.Parse()

	// Setup logging
	logFile, err := os.OpenFile("algo_trading.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		log.Fatal("Failed to open log file:", err)
	}
	defer logFile.Close()
	log.SetOutput(logFile)

	// Validate environment
	if os.Getenv("APCA_API_KEY_ID") == "" || os.Getenv("APCA_API_SECRET_KEY") == "" {
		fmt.Println("Please set APCA_API_KEY_ID and APCA_API_SECRET_KEY environment variables")
		fmt.Println("Example:")
		fmt.Println("  export APCA_API_KEY_ID=your_key_id")
		fmt.Println("  export APCA_API_SECRET_KEY=your_secret_key")
		fmt.Println("  export APCA_API_BASE_URL=https://paper-api.alpaca.markets")
		os.Exit(1)
	}

	// Set paper trading URL if not set
	if *paperMode && os.Getenv("APCA_API_BASE_URL") == "" {
		os.Setenv("APCA_API_BASE_URL", "https://paper-api.alpaca.markets")
	}

	// Create strategy runner
	runner := strategies.NewStrategyRunner()

	// Add strategies based on command line flags
	switch *strategyType {
	case "ma":
		maStrategy := strategies.NewMovingAverageCrossoverStrategy(*symbol, *maShort, *maLong)
		runner.AddStrategy(maStrategy)
		fmt.Printf("Running Moving Average Crossover strategy for %s (MA %d/%d)\n", *symbol, *maShort, *maLong)

	case "rsi":
		rsiStrategy := strategies.NewRSIMeanReversionStrategy(*symbol, *rsiPeriod)
		runner.AddStrategy(rsiStrategy)
		fmt.Printf("Running RSI Mean Reversion strategy for %s (Period: %d)\n", *symbol, *rsiPeriod)

	case "both":
		maStrategy := strategies.NewMovingAverageCrossoverStrategy(*symbol, *maShort, *maLong)
		rsiStrategy := strategies.NewRSIMeanReversionStrategy(*symbol, *rsiPeriod)
		runner.AddStrategy(maStrategy)
		runner.AddStrategy(rsiStrategy)
		fmt.Printf("Running both strategies for %s\n", *symbol)

	default:
		fmt.Printf("Unknown strategy: %s\n", *strategyType)
		fmt.Println("Available strategies: ma, rsi, both")
		os.Exit(1)
	}

	// Initialize strategies
	if err := runner.Initialize(); err != nil {
		log.Fatal("Failed to initialize strategies:", err)
	}

	fmt.Println("Strategies initialized successfully")
	fmt.Println("Starting algo trading... (Press Ctrl+C to stop)")
	fmt.Println("Check algo_trading.log for detailed output")

	// Run strategies
	if err := runner.Run(); err != nil {
		log.Fatal("Failed to run strategies:", err)
	}

	fmt.Println("Algo trading stopped")
}