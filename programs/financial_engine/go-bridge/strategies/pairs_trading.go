package strategies

import (
	"context"
	"fmt"
	"log"
	"math"
	"sync"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
	"github.com/shopspring/decimal"
	"gonum.org/v1/gonum/stat"
)

// PairsTradingStrategy implements statistical arbitrage on correlated pairs
// Goes long underperformer and short outperformer when spread diverges
type PairsTradingStrategy struct {
	// Configuration
	SymbolA       string  // First symbol in pair
	SymbolB       string  // Second symbol in pair
	LookbackDays  int     // Days for calculating statistics
	EntryZScore   float64 // Z-score threshold for entry (e.g., 2.0)
	ExitZScore    float64 // Z-score threshold for exit (e.g., 0.5)
	StopZScore    float64 // Stop loss z-score (e.g., 3.0)
	PositionSize  float64 // Percentage of equity per leg
	MinCorrelation float64 // Minimum correlation required

	// Alpaca clients
	tradingClient *alpaca.Client
	dataClient    *marketdata.Client

	// State management
	mu            sync.RWMutex
	pricesA       []float64
	pricesB       []float64
	hedgeRatio    float64
	meanSpread    float64
	stdSpread     float64
	correlation   float64
	currentSpread float64
	currentZScore float64
	lastPriceA    float64
	lastPriceB    float64
	
	// Position tracking
	inPosition    bool
	positionType  string // "longA_shortB" or "shortA_longB"
	entrySpread   float64
	qtyA          int64
	qtyB          int64
	entryPriceA   float64
	entryPriceB   float64
	
	// Cointegration tracking
	isCointegrated bool
	lastCointegrationCheck time.Time
	
	// Performance tracking
	logger        *log.Logger
	tradeCount    int
	winCount      int
	totalPnL      float64
	correlationBreaks int
	maxSpreadDeviation float64
}

// NewPairsTradingStrategy creates a new pairs trading strategy
func NewPairsTradingStrategy(symbolA, symbolB string) *PairsTradingStrategy {
	return &PairsTradingStrategy{
		SymbolA:        symbolA,
		SymbolB:        symbolB,
		LookbackDays:   60,    // 60 days for statistics
		EntryZScore:    2.0,   // Enter when spread is 2 std devs away
		ExitZScore:     0.5,   // Exit when spread returns to 0.5 std devs
		StopZScore:     3.0,   // Stop loss at 3 std devs
		PositionSize:   0.01,  // 1% per leg
		MinCorrelation: 0.70,  // Minimum 70% correlation
		pricesA:        make([]float64, 0, 252),
		pricesB:        make([]float64, 0, 252),
		logger:         log.New(log.Writer(), "[PAIRS] ", log.LstdFlags),
	}
}

// Initialize sets up the Alpaca clients and calculates initial pair parameters
func (s *PairsTradingStrategy) Initialize(apiKey, apiSecret, baseURL string) error {
	// Initialize Alpaca trading client
	s.tradingClient = alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret,
		BaseURL:   baseURL,
	})

	// Initialize market data client
	s.dataClient = marketdata.NewClient(marketdata.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret,
	})

	// Load historical data and calculate pair parameters
	if err := s.calculatePairParameters(); err != nil {
		return fmt.Errorf("failed to calculate pair parameters: %w", err)
	}

	// Check current positions
	if err := s.syncPositions(); err != nil {
		return fmt.Errorf("failed to sync positions: %w", err)
	}

	s.logger.Printf("Pairs trading initialized for %s/%s (Correlation: %.3f, Hedge Ratio: %.3f)",
		s.SymbolA, s.SymbolB, s.correlation, s.hedgeRatio)
	return nil
}

// calculatePairParameters loads historical data and calculates hedge ratio, mean, std
func (s *PairsTradingStrategy) calculatePairParameters() error {
	end := time.Now()
	start := end.AddDate(0, 0, -s.LookbackDays)

	// Fetch historical bars for both symbols
	barsReq := marketdata.GetBarsRequest{
		TimeFrame: marketdata.OneDay,
		Start:     start,
		End:       end,
		PageLimit: int(s.LookbackDays),
	}

	barsA, err := s.dataClient.GetBars(s.SymbolA, barsReq)
	if err != nil {
		return fmt.Errorf("failed to get bars for %s: %w", s.SymbolA, err)
	}

	barsB, err := s.dataClient.GetBars(s.SymbolB, barsReq)
	if err != nil {
		return fmt.Errorf("failed to get bars for %s: %w", s.SymbolB, err)
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	// Clear and populate price arrays
	s.pricesA = []float64{}
	s.pricesB = []float64{}
	
	// Align bars by date
	mapA := make(map[string]float64)
	for _, bar := range barsA {
		dateKey := bar.Timestamp.Format("2006-01-02")
		mapA[dateKey] = bar.Close
	}

	for _, bar := range barsB {
		dateKey := bar.Timestamp.Format("2006-01-02")
		if priceA, exists := mapA[dateKey]; exists {
			s.pricesA = append(s.pricesA, priceA)
			s.pricesB = append(s.pricesB, bar.Close)
		}
	}

	if len(s.pricesA) < 20 {
		return fmt.Errorf("insufficient data: only %d aligned bars", len(s.pricesA))
	}

	// Calculate correlation
	s.correlation = stat.Correlation(s.pricesA, s.pricesB, nil)
	
	if s.correlation < s.MinCorrelation {
		s.logger.Printf("Warning: Low correlation %.3f < %.3f", s.correlation, s.MinCorrelation)
		s.isCointegrated = false
	} else {
		s.isCointegrated = true
	}

	// Calculate hedge ratio using linear regression (OLS)
	// priceA = alpha + beta * priceB
	// beta is our hedge ratio
	alpha, beta := stat.LinearRegression(s.pricesB, s.pricesA, nil, false)
	s.hedgeRatio = beta
	
	// Calculate spread series: spreadT = priceA - hedgeRatio * priceB
	spreads := make([]float64, len(s.pricesA))
	for i := range s.pricesA {
		spreads[i] = s.pricesA[i] - s.hedgeRatio*s.pricesB[i]
	}
	
	// Calculate mean and standard deviation of spread
	s.meanSpread = stat.Mean(spreads, nil)
	s.stdSpread = stat.StdDev(spreads, nil)
	
	// Simple stationarity check (approximation of ADF test)
	// Check if spread mean-reverts by looking at autocorrelation
	if len(spreads) > 1 {
		autocorr := s.calculateAutocorrelation(spreads, 1)
		if autocorr > 0.95 {
			s.logger.Printf("Warning: Spread shows high autocorrelation (%.3f), may not be stationary", autocorr)
			s.isCointegrated = false
		}
	}
	
	s.lastCointegrationCheck = time.Now()
	
	s.logger.Printf("Pair parameters: Alpha=%.3f, Beta=%.3f, Mean=%.2f, Std=%.2f, Corr=%.3f",
		alpha, s.hedgeRatio, s.meanSpread, s.stdSpread, s.correlation)
	
	return nil
}

// calculateAutocorrelation computes autocorrelation at given lag
func (s *PairsTradingStrategy) calculateAutocorrelation(series []float64, lag int) float64 {
	if lag >= len(series) {
		return 0
	}
	
	n := len(series) - lag
	series1 := series[:n]
	series2 := series[lag:]
	
	return stat.Correlation(series1, series2, nil)
}

// syncPositions checks if we have existing positions in the pair
func (s *PairsTradingStrategy) syncPositions() error {
	positions, err := s.tradingClient.GetPositions()
	if err != nil {
		return err
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	s.inPosition = false
	hasA, hasB := false, false
	
	for _, pos := range positions {
		if pos.Symbol == s.SymbolA {
			hasA = true
			s.qtyA = pos.Qty.BigInt().Int64()
			avgPrice, _ := pos.AvgEntryPrice.Float64()
			s.entryPriceA = avgPrice
			
			// Determine position type based on side
			if s.qtyA > 0 {
				s.positionType = "longA_shortB"
			} else {
				s.positionType = "shortA_longB"
			}
		}
		if pos.Symbol == s.SymbolB {
			hasB = true
			s.qtyB = pos.Qty.BigInt().Int64()
			avgPrice, _ := pos.AvgEntryPrice.Float64()
			s.entryPriceB = avgPrice
		}
	}
	
	s.inPosition = hasA && hasB
	
	if s.inPosition {
		s.logger.Printf("Found existing pair position: %s (A: %d @ %.2f, B: %d @ %.2f)",
			s.positionType, s.qtyA, s.entryPriceA, s.qtyB, s.entryPriceB)
	}

	return nil
}

// ProcessBars handles new price data for both symbols
func (s *PairsTradingStrategy) ProcessBars(priceA, priceB float64, timestamp time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Update prices
	s.lastPriceA = priceA
	s.lastPriceB = priceB
	
	// Update rolling price windows
	s.pricesA = append(s.pricesA, priceA)
	s.pricesB = append(s.pricesB, priceB)
	
	// Keep only needed history
	if len(s.pricesA) > s.LookbackDays {
		s.pricesA = s.pricesA[1:]
		s.pricesB = s.pricesB[1:]
	}
	
	// Recalculate parameters periodically (daily)
	if time.Since(s.lastCointegrationCheck) > 24*time.Hour {
		go func() {
			if err := s.calculatePairParameters(); err != nil {
				s.logger.Printf("Failed to update parameters: %v", err)
			}
		}()
	}
	
	// Calculate current spread and z-score
	s.currentSpread = priceA - s.hedgeRatio*priceB
	if s.stdSpread > 0 {
		s.currentZScore = (s.currentSpread - s.meanSpread) / s.stdSpread
	}
	
	// Track maximum spread deviation
	absZ := math.Abs(s.currentZScore)
	if absZ > s.maxSpreadDeviation {
		s.maxSpreadDeviation = absZ
	}
	
	// Check if pair is still valid
	if !s.isCointegrated || s.correlation < s.MinCorrelation {
		if s.inPosition {
			s.logger.Printf("Cointegration/correlation broken, unwinding position")
			go s.executePairTrade("UNWIND", priceA, priceB)
		}
		return
	}
	
	// Generate trading signal
	signal := s.generateSignal()
	
	if signal != "" {
		s.logger.Printf("Signal: %s | Spread: %.2f | Z-Score: %.2f | Prices: A=%.2f B=%.2f",
			signal, s.currentSpread, s.currentZScore, priceA, priceB)
		
		// Execute trade asynchronously
		go s.executePairTrade(signal, priceA, priceB)
	}
}

// generateSignal determines if we should enter/exit positions
func (s *PairsTradingStrategy) generateSignal() string {
	// Entry signals
	if !s.inPosition {
		if s.currentZScore > s.EntryZScore {
			// Spread is too high: A is overvalued relative to B
			// Short A, Long B
			return "SHORT_A_LONG_B"
		} else if s.currentZScore < -s.EntryZScore {
			// Spread is too low: A is undervalued relative to B
			// Long A, Short B
			return "LONG_A_SHORT_B"
		}
	}
	
	// Exit signals
	if s.inPosition {
		// Mean reversion: spread returned close to mean
		if math.Abs(s.currentZScore) < s.ExitZScore {
			s.logger.Printf("Mean reversion complete, z-score: %.2f", s.currentZScore)
			return "UNWIND"
		}
		
		// Stop loss: spread diverged too much
		if math.Abs(s.currentZScore) > s.StopZScore {
			s.logger.Printf("Stop loss triggered, z-score: %.2f", s.currentZScore)
			return "UNWIND"
		}
		
		// Profitable exit based on position type
		if s.positionType == "longA_shortB" && s.currentZScore > 0.5 {
			// We were long A/short B when spread was negative
			// Now spread is positive, take profit
			return "UNWIND"
		} else if s.positionType == "shortA_longB" && s.currentZScore < -0.5 {
			// We were short A/long B when spread was positive
			// Now spread is negative, take profit
			return "UNWIND"
		}
	}
	
	return ""
}

// executePairTrade places simultaneous orders for both legs
func (s *PairsTradingStrategy) executePairTrade(signal string, priceA, priceB float64) {
	// Get account info for position sizing
	account, err := s.tradingClient.GetAccount()
	if err != nil {
		s.logger.Printf("Failed to get account: %v", err)
		return
	}

	equity, _ := account.Equity.Float64()
	buyingPower, _ := account.BuyingPower.Float64()

	// Check compliance
	if !s.validateTradeCompliance(account, signal) {
		s.logger.Printf("Trade blocked by compliance checks")
		return
	}

	if signal == "UNWIND" {
		// Close existing positions
		if !s.inPosition {
			s.logger.Printf("No position to unwind")
			return
		}
		
		// Calculate P&L before closing
		pnlA := float64(s.qtyA) * (priceA - s.entryPriceA)
		pnlB := -float64(s.qtyB) * (priceB - s.entryPriceB) // Negative because opposite side
		totalPnL := pnlA + pnlB
		
		s.totalPnL += totalPnL
		if totalPnL > 0 {
			s.winCount++
		}
		s.tradeCount++
		
		// Close position A
		orderA := alpaca.PlaceOrderRequest{
			Symbol:      s.SymbolA,
			Qty:         &[]decimal.Decimal{decimal.NewFromInt(int64(math.Abs(float64(s.qtyA))))}[0],
			Side:        alpaca.Sell,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
		}
		if s.qtyA < 0 { // Was short, need to buy to close
			orderA.Side = alpaca.Buy
		}
		
		// Close position B
		orderB := alpaca.PlaceOrderRequest{
			Symbol:      s.SymbolB,
			Qty:         &[]decimal.Decimal{decimal.NewFromInt(int64(math.Abs(float64(s.qtyB))))}[0],
			Side:        alpaca.Sell,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
		}
		if s.qtyB < 0 { // Was short, need to buy to close
			orderB.Side = alpaca.Buy
		}
		
		// Submit orders
		if _, err := s.tradingClient.PlaceOrder(orderA); err != nil {
			s.logger.Printf("Failed to close %s: %v", s.SymbolA, err)
			return
		}
		if _, err := s.tradingClient.PlaceOrder(orderB); err != nil {
			s.logger.Printf("Failed to close %s: %v", s.SymbolB, err)
			return
		}
		
		s.logger.Printf("Unwound pair position, P&L: %.2f (A: %.2f, B: %.2f)",
			totalPnL, pnlA, pnlB)
		
		// Update state
		s.mu.Lock()
		s.inPosition = false
		s.positionType = ""
		s.qtyA = 0
		s.qtyB = 0
		s.entryPriceA = 0
		s.entryPriceB = 0
		s.entrySpread = 0
		s.mu.Unlock()
		
	} else {
		// Enter new position
		if s.inPosition {
			s.logger.Printf("Already in position, skipping entry")
			return
		}
		
		// Calculate position sizes (balanced by hedge ratio)
		positionValue := equity * s.PositionSize
		qtyA := int64(math.Floor(positionValue / priceA))
		qtyB := int64(math.Floor(float64(qtyA) * s.hedgeRatio))
		
		// Adjust for buying power
		requiredCapital := float64(qtyA)*priceA + float64(qtyB)*priceB
		if requiredCapital > buyingPower {
			scale := buyingPower / requiredCapital * 0.95 // Leave some buffer
			qtyA = int64(float64(qtyA) * scale)
			qtyB = int64(float64(qtyB) * scale)
			s.logger.Printf("Adjusted quantities for buying power: A=%d, B=%d", qtyA, qtyB)
		}
		
		if qtyA <= 0 || qtyB <= 0 {
			s.logger.Printf("Position size too small")
			return
		}
		
		var orderA, orderB alpaca.PlaceOrderRequest
		
		if signal == "LONG_A_SHORT_B" {
			// Long A
			orderA = alpaca.PlaceOrderRequest{
				Symbol:      s.SymbolA,
				Qty:         &[]decimal.Decimal{decimal.NewFromInt(qtyA)}[0],
				Side:        alpaca.Buy,
				Type:        alpaca.Market,
				TimeInForce: alpaca.Day,
			}
			
			// Short B
			orderB = alpaca.PlaceOrderRequest{
				Symbol:      s.SymbolB,
				Qty:         &[]decimal.Decimal{decimal.NewFromInt(qtyB)}[0],
				Side:        alpaca.Sell,
				Type:        alpaca.Market,
				TimeInForce: alpaca.Day,
			}
			
		} else if signal == "SHORT_A_LONG_B" {
			// Short A
			orderA = alpaca.PlaceOrderRequest{
				Symbol:      s.SymbolA,
				Qty:         &[]decimal.Decimal{decimal.NewFromInt(qtyA)}[0],
				Side:        alpaca.Sell,
				Type:        alpaca.Market,
				TimeInForce: alpaca.Day,
			}
			
			// Long B
			orderB = alpaca.PlaceOrderRequest{
				Symbol:      s.SymbolB,
				Qty:         &[]decimal.Decimal{decimal.NewFromInt(qtyB)}[0],
				Side:        alpaca.Buy,
				Type:        alpaca.Market,
				TimeInForce: alpaca.Day,
			}
		}
		
		// Submit orders (ideally would batch these)
		orderAResp, err := s.tradingClient.PlaceOrder(orderA)
		if err != nil {
			s.logger.Printf("Failed to place order for %s: %v", s.SymbolA, err)
			return
		}
		
		_, err = s.tradingClient.PlaceOrder(orderB)
		if err != nil {
			s.logger.Printf("Failed to place order for %s: %v", s.SymbolB, err)
			// Cancel first order if second fails
			s.tradingClient.CancelOrder(orderAResp.ID)
			return
		}
		
		s.logger.Printf("Entered pair position: %s (A: %d @ %.2f, B: %d @ %.2f)",
			signal, qtyA, priceA, qtyB, priceB)
		
		// Update state
		s.mu.Lock()
		s.inPosition = true
		s.positionType = signal
		s.qtyA = qtyA
		s.qtyB = qtyB
		s.entryPriceA = priceA
		s.entryPriceB = priceB
		s.entrySpread = s.currentSpread
		if signal == "SHORT_A_LONG_B" {
			s.qtyA = -qtyA // Negative for short
		} else {
			s.qtyB = -qtyB // Negative for short
		}
		s.mu.Unlock()
	}
}

// validateTradeCompliance checks trading rules and restrictions
func (s *PairsTradingStrategy) validateTradeCompliance(account *alpaca.Account, signal string) bool {
	// Check if account can short (needed for pairs trading)
	if !account.ShortingEnabled && (signal == "SHORT_A_LONG_B" || signal == "LONG_A_SHORT_B") {
		s.logger.Printf("Shorting not enabled on account")
		return false
	}
	
	// Check for Day Trade Margin Call
	if account.TradingBlocked {
		s.logger.Printf("Trading blocked on account")
		return false
	}
	
	// PDT check (pairs trading counts as 2 day trades)
	if account.PatternDayTrader && account.DaytradeCount >= 2 {
		equity, _ := account.Equity.Float64()
		if equity < 25000 {
			s.logger.Printf("PDT rule: Would exceed day trade limit with equity %.2f < $25,000",
				equity)
			return false
		}
	}
	
	return true
}

// GetStatistics returns strategy performance metrics
func (s *PairsTradingStrategy) GetStatistics() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()

	winRate := 0.0
	avgTrade := 0.0
	if s.tradeCount > 0 {
		winRate = float64(s.winCount) / float64(s.tradeCount) * 100
		avgTrade = s.totalPnL / float64(s.tradeCount)
	}

	return map[string]interface{}{
		"symbol":              fmt.Sprintf("%s/%s", s.SymbolA, s.SymbolB),
		"strategy":            "Pairs Trading",
		"correlation":         s.correlation,
		"hedge_ratio":         s.hedgeRatio,
		"current_z_score":     s.currentZScore,
		"max_z_score":         s.maxSpreadDeviation,
		"trades":              s.tradeCount,
		"wins":                s.winCount,
		"win_rate":            winRate,
		"total_pnl":           s.totalPnL,
		"avg_trade_pnl":       avgTrade,
		"correlation_breaks":  s.correlationBreaks,
		"is_cointegrated":     s.isCointegrated,
		"in_position":         s.inPosition,
		"position_type":       s.positionType,
	}
}

// Run starts the strategy main loop with polling (WebSocket coming next)
func (s *PairsTradingStrategy) Run(ctx context.Context) error {
	// Use polling approach for now
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()

	// Polling setup (WebSocket implementation will follow)
	// This ensures compilation success first

	s.logger.Printf("Pairs trading strategy running for %s/%s", s.SymbolA, s.SymbolB)

	// Periodic statistics and parameter updates
	statsTicker := time.NewTicker(15 * time.Minute)
	paramTicker := time.NewTicker(24 * time.Hour)
	defer statsTicker.Stop()
	defer paramTicker.Stop()

	for {
		select {
		case <-ctx.Done():
			// Unwind any open positions before exit
			if s.inPosition {
				s.logger.Printf("Shutting down, unwinding position")
				s.executePairTrade("UNWIND", s.lastPriceA, s.lastPriceB)
				time.Sleep(5 * time.Second) // Wait for orders to fill
			}
			
			// Print final statistics
			stats := s.GetStatistics()
			s.logger.Printf("Final Statistics: %+v", stats)
			return nil
			
		case <-statsTicker.C:
			// Print periodic statistics
			stats := s.GetStatistics()
			s.logger.Printf("Periodic Statistics: %+v", stats)
			
		case <-paramTicker.C:
			// Recalculate pair parameters daily
			if err := s.calculatePairParameters(); err != nil {
				s.logger.Printf("Failed to update parameters: %v", err)
				if s.inPosition && !s.isCointegrated {
					s.logger.Printf("Cointegration lost, consider unwinding")
				}
			}
		}
	}
}