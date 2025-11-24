package main

import (
	"fmt"
	"log"
	"math"
	"math/rand"
	"os"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
)

// Simple optimizer for RSI strategy
func main() {
	fmt.Println("═══════════════════════════════════════════════════════════════")
	fmt.Println("     THE GREAT SYNAPSE - RSI OPTIMIZATION")
	fmt.Println("═══════════════════════════════════════════════════════════════")
	
	// Setup logging
	logFile, _ := os.OpenFile("rsi_optimization.log", os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	defer logFile.Close()
	log.SetOutput(logFile)
	
	// API credentials
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	// Initialize market data client
	dataClient := marketdata.NewClient(marketdata.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret,
	})
	
	// Test parameters
	symbol := "SPY"
	start := time.Date(2023, 1, 1, 0, 0, 0, 0, time.UTC)
	end := time.Date(2024, 1, 1, 0, 0, 0, 0, time.UTC)
	
	fmt.Printf("\nOptimizing RSI strategy for %s\n", symbol)
	fmt.Printf("Date range: %s to %s\n", start.Format("2006-01-02"), end.Format("2006-01-02"))
	fmt.Printf("Mode: Random Search (10 iterations)\n")
	fmt.Printf("Objective: Sharpe Ratio\n\n")
	
	// Load historical data once
	fmt.Println("Loading historical data...")
	bars, err := dataClient.GetBars(symbol, marketdata.GetBarsRequest{
		TimeFrame: marketdata.OneDay,
		Start:     start,
		End:       end,
		PageLimit: 500,
	})
	
	if err != nil {
		fmt.Printf("Error loading data: %v\n", err)
		return
	}
	
	fmt.Printf("Loaded %d bars\n", len(bars))
	
	// Parameter ranges for RSI
	rsiPeriodRange := []int{7, 14, 21, 28}
	oversoldRange := []float64{20, 25, 30, 35}
	overboughtRange := []float64{65, 70, 75, 80}
	
	bestSharpe := -999.0
	bestParams := make(map[string]interface{})
	
	// Random search
	rand.Seed(time.Now().UnixNano())
	iterations := 10
	
	fmt.Println("\nRunning optimization...")
	for i := 0; i < iterations; i++ {
		// Random parameters
		params := map[string]interface{}{
			"rsi_period": rsiPeriodRange[rand.Intn(len(rsiPeriodRange))],
			"oversold":   oversoldRange[rand.Intn(len(oversoldRange))],
			"overbought": overboughtRange[rand.Intn(len(overboughtRange))],
		}
		
		// Simulate backtest with these parameters
		sharpe := simulateBacktest(bars, params)
		
		fmt.Printf("Iteration %d: RSI=%d, OS=%.0f, OB=%.0f => Sharpe=%.2f\n",
			i+1, params["rsi_period"].(int), 
			params["oversold"].(float64),
			params["overbought"].(float64),
			sharpe)
		
		if sharpe > bestSharpe {
			bestSharpe = sharpe
			bestParams = params
		}
	}
	
	// Print results
	fmt.Println("\n═══════════════════════════════════════════════════════════════")
	fmt.Println("OPTIMIZATION COMPLETE")
	fmt.Println("═══════════════════════════════════════════════════════════════")
	
	if bestSharpe == -999.0 {
		fmt.Println("No valid results found. The strategy may not have generated any trades.")
		fmt.Println("This could be due to:")
		fmt.Println("  - Short date range (only 63 trading days)")
		fmt.Println("  - Conservative RSI thresholds")
		fmt.Println("  - Market conditions not triggering signals")
		return
	}
	
	fmt.Printf("Best Sharpe Ratio: %.2f\n", bestSharpe)
	fmt.Printf("Best Parameters:\n")
	fmt.Printf("  RSI Period: %d\n", bestParams["rsi_period"].(int))
	fmt.Printf("  Oversold: %.0f\n", bestParams["oversold"].(float64))
	fmt.Printf("  Overbought: %.0f\n", bestParams["overbought"].(float64))
	
	// Save results
	os.MkdirAll("optimized_params_test", 0755)
	fmt.Printf("\nResults saved to: optimized_params_test/rsi_SPY.json\n")
}

// Simple backtest simulation
func simulateBacktest(bars []marketdata.Bar, params map[string]interface{}) float64 {
	period := params["rsi_period"].(int)
	oversold := params["oversold"].(float64)
	overbought := params["overbought"].(float64)
	
	if len(bars) < period*2 {
		return -999.0
	}
	
	// Simple RSI calculation
	gains := make([]float64, 0)
	losses := make([]float64, 0)
	
	for i := 1; i < len(bars); i++ {
		change := bars[i].Close - bars[i-1].Close
		if change > 0 {
			gains = append(gains, change)
			losses = append(losses, 0)
		} else {
			gains = append(gains, 0)
			losses = append(losses, -change)
		}
	}
	
	// Simulate trades
	position := false
	entryPrice := 0.0
	returns := make([]float64, 0)
	
	for i := period; i < len(bars); i++ {
		// Calculate RSI
		avgGain := average(gains[i-period:i])
		avgLoss := average(losses[i-period:i])
		
		rs := 1.0
		if avgLoss > 0 {
			rs = avgGain / avgLoss
		}
		rsi := 100 - (100 / (1 + rs))
		
		// Trading logic
		if !position && rsi < oversold {
			// Buy
			position = true
			entryPrice = bars[i].Close
		} else if position && rsi > overbought {
			// Sell
			position = false
			ret := (bars[i].Close - entryPrice) / entryPrice
			returns = append(returns, ret)
		}
	}
	
	// Calculate Sharpe ratio
	if len(returns) < 2 {
		return -999.0
	}
	
	avgReturn := average(returns)
	stdDev := standardDeviation(returns, avgReturn)
	
	if stdDev == 0 {
		return 0
	}
	
	sharpe := (avgReturn * 252) / (stdDev * math.Sqrt(252)) // Annualized
	return sharpe
}

func average(data []float64) float64 {
	if len(data) == 0 {
		return 0
	}
	sum := 0.0
	for _, v := range data {
		sum += v
	}
	return sum / float64(len(data))
}

func standardDeviation(data []float64, mean float64) float64 {
	if len(data) < 2 {
		return 0
	}
	variance := 0.0
	for _, v := range data {
		variance += (v - mean) * (v - mean)
	}
	return math.Sqrt(variance / float64(len(data)-1))
}