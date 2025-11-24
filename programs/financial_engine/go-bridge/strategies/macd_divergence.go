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
)

// MACDDivergenceStrategy implements momentum trading with MACD crossovers and divergence detection
type MACDDivergenceStrategy struct {
	// Configuration
	Symbol        string
	FastPeriod    int     // Fast EMA period (default 12)
	SlowPeriod    int     // Slow EMA period (default 26)
	SignalPeriod  int     // Signal line EMA period (default 9)
	PositionSize  float64 // Percentage of equity
	StopLossPct   float64
	TakeProfitPct float64
	DivergenceWindow int  // Window to look for divergences

	// Alpaca clients
	tradingClient *alpaca.Client
	dataClient    *marketdata.Client
	
	// API credentials (needed for WebSocket)
	apiKey        string
	apiSecret     string
	baseURL       string

	// State management
	mu            sync.RWMutex
	prices        []float64
	timestamps    []time.Time
	fastEMA       float64
	slowEMA       float64
	macdLine      float64
	signalLine    float64
	histogram     float64
	macdHistory   []float64
	signalHistory []float64
	priceHighs    []float64
	priceLows     []float64
	macdHighs     []float64
	macdLows      []float64
	lastSignal    string
	hasPosition   bool
	entryPrice    float64
	positionQty   int64
	
	// Divergence tracking
	bullishDivergence bool
	bearishDivergence bool
	
	// Performance tracking
	logger        *log.Logger
	tradeCount    int
	winCount      int
	totalPnL      float64
	divergenceHits int
	divergenceMisses int
}

// NewMACDDivergenceStrategy creates a new MACD divergence strategy
func NewMACDDivergenceStrategy(symbol string) *MACDDivergenceStrategy {
	return &MACDDivergenceStrategy{
		Symbol:           symbol,
		FastPeriod:       12,
		SlowPeriod:       26,
		SignalPeriod:     9,
		PositionSize:     0.01, // 1% of equity
		StopLossPct:      0.02, // 2% stop loss
		TakeProfitPct:    0.05, // 5% take profit
		DivergenceWindow: 14,   // Look back 14 periods for divergences
		prices:           make([]float64, 0, 100),
		timestamps:       make([]time.Time, 0, 100),
		macdHistory:      make([]float64, 0, 100),
		signalHistory:    make([]float64, 0, 100),
		priceHighs:       make([]float64, 0, 14),
		priceLows:        make([]float64, 0, 14),
		macdHighs:        make([]float64, 0, 14),
		macdLows:         make([]float64, 0, 14),
		logger:           log.New(log.Writer(), "[MACD-DIV] ", log.LstdFlags),
	}
}

// Initialize sets up the Alpaca clients and loads historical data
func (s *MACDDivergenceStrategy) Initialize(apiKey, apiSecret, baseURL string) error {
	// Store credentials for WebSocket connections
	s.apiKey = apiKey
	s.apiSecret = apiSecret
	s.baseURL = baseURL
	
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

	// Load historical data to warm up indicators
	if err := s.loadHistoricalData(); err != nil {
		return fmt.Errorf("failed to load historical data: %w", err)
	}

	// Check current position
	if err := s.syncPosition(); err != nil {
		return fmt.Errorf("failed to sync position: %w", err)
	}

	s.logger.Printf("MACD Divergence strategy initialized for %s (Fast: %d, Slow: %d, Signal: %d)",
		s.Symbol, s.FastPeriod, s.SlowPeriod, s.SignalPeriod)
	return nil
}

// loadHistoricalData fetches enough bars to calculate initial MACD
func (s *MACDDivergenceStrategy) loadHistoricalData() error {
	end := time.Now()
	lookback := s.SlowPeriod * 3 // Need extra for EMA warmup
	start := end.AddDate(0, 0, -lookback)

	barsReq := marketdata.GetBarsRequest{
		TimeFrame: marketdata.OneDay,
		Start:     start,
		End:       end,
		PageLimit: int(lookback),
	}

	bars, err := s.dataClient.GetBars(s.Symbol, barsReq)
	if err != nil {
		return err
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	// Store prices and timestamps
	for _, bar := range bars {
		s.prices = append(s.prices, bar.Close)
		s.timestamps = append(s.timestamps, bar.Timestamp)
	}

	// Initialize EMAs if we have enough data
	if len(s.prices) >= s.SlowPeriod {
		s.initializeEMAs()
		s.calculateMACD()
	}

	s.logger.Printf("Loaded %d historical bars, initial MACD: %.4f, Signal: %.4f, Histogram: %.4f",
		len(s.prices), s.macdLine, s.signalLine, s.histogram)
	return nil
}

// initializeEMAs calculates initial EMA values using SMA for the first value
func (s *MACDDivergenceStrategy) initializeEMAs() {
	// Calculate initial SMAs
	fastSum := 0.0
	for i := len(s.prices) - s.FastPeriod; i < len(s.prices); i++ {
		fastSum += s.prices[i]
	}
	s.fastEMA = fastSum / float64(s.FastPeriod)

	slowSum := 0.0
	for i := len(s.prices) - s.SlowPeriod; i < len(s.prices); i++ {
		slowSum += s.prices[i]
	}
	s.slowEMA = slowSum / float64(s.SlowPeriod)
}

// syncPosition checks if we have an existing position
func (s *MACDDivergenceStrategy) syncPosition() error {
	positions, err := s.tradingClient.GetPositions()
	if err != nil {
		return err
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	s.hasPosition = false
	for _, pos := range positions {
		if pos.Symbol == s.Symbol {
			s.hasPosition = true
			s.positionQty = pos.Qty.BigInt().Int64()
			avgPrice, _ := pos.AvgEntryPrice.Float64()
			s.entryPrice = avgPrice
			s.logger.Printf("Found existing position: %d shares at %.2f", s.positionQty, s.entryPrice)
			break
		}
	}

	return nil
}

// ProcessBar handles new price data and generates trading signals
func (s *MACDDivergenceStrategy) ProcessBar(price float64, timestamp time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Update price history
	s.prices = append(s.prices, price)
	s.timestamps = append(s.timestamps, timestamp)

	// Keep reasonable history (100 bars)
	if len(s.prices) > 100 {
		s.prices = s.prices[1:]
		s.timestamps = s.timestamps[1:]
	}

	// Need enough data for slow EMA
	if len(s.prices) < s.SlowPeriod {
		return
	}

	// Update EMAs and MACD
	s.updateEMAs(price)
	prevMACD := s.macdLine
	prevSignal := s.signalLine
	prevHistogram := s.histogram
	
	s.calculateMACD()
	
	// Store MACD history for divergence detection
	s.macdHistory = append(s.macdHistory, s.macdLine)
	s.signalHistory = append(s.signalHistory, s.signalLine)
	if len(s.macdHistory) > s.DivergenceWindow {
		s.macdHistory = s.macdHistory[1:]
		s.signalHistory = s.signalHistory[1:]
	}

	// Update highs and lows for divergence
	s.updateHighsLows(price)
	
	// Detect divergences
	s.detectDivergences()

	// Generate signal
	signal := s.generateSignal(prevMACD, prevSignal, prevHistogram, price)
	
	if signal != "" {
		s.logger.Printf("Signal: %s | Price: %.2f | MACD: %.4f | Signal: %.4f | Histogram: %.4f | Divergence: Bull=%v Bear=%v",
			signal, price, s.macdLine, s.signalLine, s.histogram, s.bullishDivergence, s.bearishDivergence)
		
		// Execute trade asynchronously
		go s.executeTrade(signal, price)
	}
}

// updateEMAs updates exponential moving averages
func (s *MACDDivergenceStrategy) updateEMAs(price float64) {
	// EMA = (Price - Previous EMA) * Multiplier + Previous EMA
	fastMultiplier := 2.0 / float64(s.FastPeriod+1)
	slowMultiplier := 2.0 / float64(s.SlowPeriod+1)
	
	s.fastEMA = (price - s.fastEMA) * fastMultiplier + s.fastEMA
	s.slowEMA = (price - s.slowEMA) * slowMultiplier + s.slowEMA
}

// calculateMACD calculates MACD line, signal line, and histogram
func (s *MACDDivergenceStrategy) calculateMACD() {
	// MACD line = Fast EMA - Slow EMA
	s.macdLine = s.fastEMA - s.slowEMA
	
	// Signal line = EMA of MACD line
	if s.signalLine == 0 && len(s.macdHistory) >= s.SignalPeriod {
		// Initialize signal line with SMA
		sum := 0.0
		start := len(s.macdHistory) - s.SignalPeriod
		for i := start; i < len(s.macdHistory); i++ {
			sum += s.macdHistory[i]
		}
		s.signalLine = sum / float64(s.SignalPeriod)
	} else if s.signalLine != 0 {
		// Update signal line EMA
		signalMultiplier := 2.0 / float64(s.SignalPeriod+1)
		s.signalLine = (s.macdLine - s.signalLine) * signalMultiplier + s.signalLine
	}
	
	// Histogram = MACD line - Signal line
	s.histogram = s.macdLine - s.signalLine
}

// updateHighsLows tracks price and MACD highs/lows for divergence detection
func (s *MACDDivergenceStrategy) updateHighsLows(price float64) {
	// Find local highs and lows (simple peak/trough detection)
	if len(s.prices) >= 3 {
		idx := len(s.prices) - 2
		prevPrice := s.prices[idx-1]
		currPrice := s.prices[idx]
		nextPrice := price
		
		// Local high
		if currPrice > prevPrice && currPrice > nextPrice {
			s.priceHighs = append(s.priceHighs, currPrice)
			if len(s.macdHistory) > 1 {
				s.macdHighs = append(s.macdHighs, s.macdHistory[len(s.macdHistory)-2])
			}
		}
		
		// Local low
		if currPrice < prevPrice && currPrice < nextPrice {
			s.priceLows = append(s.priceLows, currPrice)
			if len(s.macdHistory) > 1 {
				s.macdLows = append(s.macdLows, s.macdHistory[len(s.macdHistory)-2])
			}
		}
	}
	
	// Keep only recent highs/lows
	if len(s.priceHighs) > 5 {
		s.priceHighs = s.priceHighs[1:]
		s.macdHighs = s.macdHighs[1:]
	}
	if len(s.priceLows) > 5 {
		s.priceLows = s.priceLows[1:]
		s.macdLows = s.macdLows[1:]
	}
}

// detectDivergences identifies bullish and bearish divergences
func (s *MACDDivergenceStrategy) detectDivergences() {
	s.bullishDivergence = false
	s.bearishDivergence = false
	
	// Bullish divergence: price makes lower low, MACD makes higher low
	if len(s.priceLows) >= 2 && len(s.macdLows) >= 2 {
		lastPriceLow := s.priceLows[len(s.priceLows)-1]
		prevPriceLow := s.priceLows[len(s.priceLows)-2]
		lastMACDLow := s.macdLows[len(s.macdLows)-1]
		prevMACDLow := s.macdLows[len(s.macdLows)-2]
		
		if lastPriceLow < prevPriceLow && lastMACDLow > prevMACDLow {
			s.bullishDivergence = true
			s.logger.Printf("Bullish divergence detected: Price low %.2f < %.2f, MACD low %.4f > %.4f",
				lastPriceLow, prevPriceLow, lastMACDLow, prevMACDLow)
		}
	}
	
	// Bearish divergence: price makes higher high, MACD makes lower high
	if len(s.priceHighs) >= 2 && len(s.macdHighs) >= 2 {
		lastPriceHigh := s.priceHighs[len(s.priceHighs)-1]
		prevPriceHigh := s.priceHighs[len(s.priceHighs)-2]
		lastMACDHigh := s.macdHighs[len(s.macdHighs)-1]
		prevMACDHigh := s.macdHighs[len(s.macdHighs)-2]
		
		if lastPriceHigh > prevPriceHigh && lastMACDHigh < prevMACDHigh {
			s.bearishDivergence = true
			s.logger.Printf("Bearish divergence detected: Price high %.2f > %.2f, MACD high %.4f < %.4f",
				lastPriceHigh, prevPriceHigh, lastMACDHigh, prevMACDHigh)
		}
	}
}

// generateSignal determines if we should buy/sell based on MACD crossovers and divergences
func (s *MACDDivergenceStrategy) generateSignal(prevMACD, prevSignal, prevHistogram, price float64) string {
	// Buy signals
	if !s.hasPosition {
		// Signal 1: MACD crosses above signal line (bullish crossover)
		if prevMACD <= prevSignal && s.macdLine > s.signalLine {
			// Confirm with positive histogram momentum
			if s.histogram > prevHistogram {
				return "BUY"
			}
		}
		
		// Signal 2: Bullish divergence with MACD turning up
		if s.bullishDivergence && s.macdLine > prevMACD && s.histogram > 0 {
			s.divergenceHits++
			return "BUY"
		}
		
		// Signal 3: Zero line cross with momentum
		if prevMACD < 0 && s.macdLine > 0 && s.histogram > prevHistogram {
			return "BUY"
		}
	}
	
	// Sell signals
	if s.hasPosition {
		// Signal 1: MACD crosses below signal line (bearish crossover)
		if prevMACD >= prevSignal && s.macdLine < s.signalLine {
			return "SELL"
		}
		
		// Signal 2: Bearish divergence with MACD turning down
		if s.bearishDivergence && s.macdLine < prevMACD {
			s.divergenceHits++
			return "SELL"
		}
		
		// Signal 3: Histogram weakening significantly
		if s.histogram < 0 && s.histogram < prevHistogram * 0.5 {
			return "SELL"
		}
		
		// Stop loss or take profit
		if s.entryPrice > 0 {
			pnlPct := (price - s.entryPrice) / s.entryPrice
			
			if pnlPct <= -s.StopLossPct {
				s.logger.Printf("Stop loss triggered: %.2f%%", pnlPct*100)
				return "SELL"
			}
			
			if pnlPct >= s.TakeProfitPct {
				s.logger.Printf("Take profit triggered: %.2f%%", pnlPct*100)
				return "SELL"
			}
		}
	}
	
	return ""
}

// executeTrade places orders based on signals
func (s *MACDDivergenceStrategy) executeTrade(signal string, currentPrice float64) {
	// Get account info for position sizing
	account, err := s.tradingClient.GetAccount()
	if err != nil {
		s.logger.Printf("Failed to get account: %v", err)
		return
	}

	equity, _ := account.Equity.Float64()
	buyingPower, _ := account.BuyingPower.Float64()

	// Check PDT and other protections
	if !s.validateTradeCompliance(account, signal) {
		s.logger.Printf("Trade blocked by compliance checks")
		return
	}

	var orderReq alpaca.PlaceOrderRequest
	var qty int64

	if signal == "BUY" {
		// Calculate position size
		positionValue := equity * s.PositionSize
		qty = int64(math.Floor(positionValue / currentPrice))
		
		if qty <= 0 {
			s.logger.Printf("Position size too small: %.2f", positionValue)
			return
		}

		// Check buying power
		requiredCapital := float64(qty) * currentPrice
		if requiredCapital > buyingPower {
			qty = int64(math.Floor(buyingPower / currentPrice))
			s.logger.Printf("Adjusted qty for buying power: %d", qty)
		}

		// Create bracket order
		stopPrice := currentPrice * (1 - s.StopLossPct)
		limitPrice := currentPrice * (1 + s.TakeProfitPct)

		orderReq = alpaca.PlaceOrderRequest{
			Symbol:      s.Symbol,
			Qty:         &[]decimal.Decimal{decimal.NewFromInt(qty)}[0],
			Side:        alpaca.Buy,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
			OrderClass:  alpaca.Bracket,
			TakeProfit: &alpaca.TakeProfit{
				LimitPrice: &[]decimal.Decimal{decimal.NewFromFloat(limitPrice)}[0],
			},
			StopLoss: &alpaca.StopLoss{
				StopPrice: &[]decimal.Decimal{decimal.NewFromFloat(stopPrice)}[0],
			},
		}

		s.logger.Printf("Placing BUY order: %d shares, stop=%.2f, target=%.2f",
			qty, stopPrice, limitPrice)

	} else if signal == "SELL" {
		if !s.hasPosition || s.positionQty <= 0 {
			s.logger.Printf("No position to sell")
			return
		}

		orderReq = alpaca.PlaceOrderRequest{
			Symbol:      s.Symbol,
			Qty:         &[]decimal.Decimal{decimal.NewFromInt(s.positionQty)}[0],
			Side:        alpaca.Sell,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
		}

		// Calculate P&L
		pnl := (currentPrice - s.entryPrice) * float64(s.positionQty)
		s.totalPnL += pnl
		if pnl > 0 {
			s.winCount++
		}
		s.tradeCount++

		s.logger.Printf("Placing SELL order: %d shares, entry=%.2f, exit=%.2f, P&L=%.2f",
			s.positionQty, s.entryPrice, currentPrice, pnl)
	}

	// Submit order
	order, err := s.tradingClient.PlaceOrder(orderReq)
	if err != nil {
		s.logger.Printf("Order failed: %v", err)
		s.divergenceMisses++
		return
	}

	// Update state
	s.mu.Lock()
	if signal == "BUY" {
		s.hasPosition = true
		s.entryPrice = currentPrice
		s.positionQty = qty
	} else if signal == "SELL" {
		s.hasPosition = false
		s.entryPrice = 0
		s.positionQty = 0
	}
	s.lastSignal = signal
	s.mu.Unlock()

	s.logger.Printf("Order placed successfully: %s", order.ID)
}

// validateTradeCompliance checks PDT rules and other protections
func (s *MACDDivergenceStrategy) validateTradeCompliance(account *alpaca.Account, signal string) bool {
	// Check Pattern Day Trader rule
	if account.PatternDayTrader && account.DaytradeCount >= 3 {
		equity, _ := account.Equity.Float64()
		if equity < 25000 {
			s.logger.Printf("PDT rule violation: equity %.2f < $25,000 with %d day trades",
				equity, account.DaytradeCount)
			return false
		}
	}

	// Check for Day Trade Margin Call
	if account.TradingBlocked {
		s.logger.Printf("Trading blocked on account")
		return false
	}

	return true
}

// GetStatistics returns strategy performance metrics
func (s *MACDDivergenceStrategy) GetStatistics() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()

	winRate := 0.0
	avgTrade := 0.0
	if s.tradeCount > 0 {
		winRate = float64(s.winCount) / float64(s.tradeCount) * 100
		avgTrade = s.totalPnL / float64(s.tradeCount)
	}

	divergenceAccuracy := 0.0
	if (s.divergenceHits + s.divergenceMisses) > 0 {
		divergenceAccuracy = float64(s.divergenceHits) / float64(s.divergenceHits + s.divergenceMisses) * 100
	}

	return map[string]interface{}{
		"symbol":              s.Symbol,
		"strategy":            "MACD Divergence",
		"trades":              s.tradeCount,
		"wins":                s.winCount,
		"win_rate":            winRate,
		"total_pnl":           s.totalPnL,
		"avg_trade_pnl":       avgTrade,
		"current_macd":        s.macdLine,
		"current_signal":      s.signalLine,
		"current_histogram":   s.histogram,
		"divergence_hits":     s.divergenceHits,
		"divergence_accuracy": divergenceAccuracy,
		"has_position":        s.hasPosition,
	}
}

// fetchAndProcessLatestBar fetches the latest bar and processes it
func (s *MACDDivergenceStrategy) fetchAndProcessLatestBar() error {
	end := time.Now()
	start := end.Add(-5 * time.Minute) // Get last 5 minutes

	barsReq := marketdata.GetBarsRequest{
		TimeFrame: marketdata.OneDay,
		Start:     start,
		End:       end,
		PageLimit: 1,
	}

	bars, err := s.dataClient.GetBars(s.Symbol, barsReq)
	if err != nil {
		return err
	}

	if len(bars) > 0 {
		latestBar := bars[len(bars)-1]
		s.ProcessBar(latestBar.Close, latestBar.Timestamp)
	}

	return nil
}

// Run starts the strategy main loop with WebSocket streaming
func (s *MACDDivergenceStrategy) Run(ctx context.Context) error {
	// Create proper WebSocket market data stream
	marketStream := NewMarketDataStream(s.apiKey, s.apiSecret, s.baseURL)
	
	// Set up bar handler
	marketStream.SetBarHandler(func(bar MarketBar) {
		if bar.Symbol == s.Symbol {
			s.ProcessBar(bar.Close, bar.Timestamp)
		}
	})
	
	// Connect to market data stream
	if err := marketStream.Connect(ctx); err != nil {
		return fmt.Errorf("failed to connect to market data stream: %w", err)
	}
	defer marketStream.Disconnect()
	
	// Subscribe to bars for our symbol
	if err := marketStream.SubscribeBars([]string{s.Symbol}); err != nil {
		return fmt.Errorf("failed to subscribe to bars: %w", err)
	}
	
	// Create trade updates stream for order confirmations
	tradeStream := NewTradeUpdatesStream(s.apiKey, s.apiSecret, s.baseURL)
	
	// Set up trade update handler
	tradeStream.SetTradeUpdateHandler(func(update TradeUpdate) {
		s.logger.Printf("Trade update: %s for %s - %s", update.Data.Event, update.Data.Order.Symbol, update.Data.Order.Status)
	})
	
	// Connect to trade updates stream
	if err := tradeStream.Connect(ctx); err != nil {
		return fmt.Errorf("failed to connect to trade updates stream: %w", err)
	}
	defer tradeStream.Disconnect()

	s.logger.Printf("MACD Divergence strategy running for %s", s.Symbol)

	// Periodic statistics reporting
	statsTicker := time.NewTicker(5 * time.Minute)
	defer statsTicker.Stop()

	s.logger.Printf("MACD Divergence strategy running with WebSocket streaming for %s", s.Symbol)
	
	for {
		select {
		case <-ctx.Done():
			// Print final statistics
			stats := s.GetStatistics()
			s.logger.Printf("Final Statistics: %+v", stats)
			return nil
			
		case <-statsTicker.C:
			// Print periodic statistics
			stats := s.GetStatistics()
			s.logger.Printf("Periodic Statistics: %+v", stats)
		}
	}
}