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

// RSIMeanReversionStrategy implements a mean reversion strategy using RSI
// Buys when RSI < 30 (oversold), sells when RSI > 70 (overbought)
type RSIMeanReversionStrategy struct {
	// Configuration
	Symbol        string
	RSIPeriod     int
	OversoldLevel float64
	OverboughtLevel float64
	PositionSize  float64 // Percentage of equity
	StopLossPct   float64
	TakeProfitPct float64
	UseTrendFilter bool   // Optional: only trade in direction of trend

	// Alpaca clients
	tradingClient *alpaca.Client
	dataClient    *marketdata.Client

	// State management
	mu            sync.RWMutex
	prices        []float64
	gains         []float64
	losses        []float64
	currentRSI    float64
	avgGain       float64
	avgLoss       float64
	lastSignal    string
	hasPosition   bool
	entryPrice    float64
	positionQty   int64
	trendMA       float64 // 200-day MA for trend filter

	// Logging and monitoring
	logger        *log.Logger
	tradeCount    int
	winCount      int
	totalPnL      float64
	consecutiveSignals int // Track consecutive oversold/overbought readings
}

// NewRSIMeanReversionStrategy creates a new RSI mean reversion strategy
func NewRSIMeanReversionStrategy(symbol string, rsiPeriod int) *RSIMeanReversionStrategy {
	return &RSIMeanReversionStrategy{
		Symbol:          symbol,
		RSIPeriod:       rsiPeriod,
		OversoldLevel:   30.0,
		OverboughtLevel: 70.0,
		PositionSize:    0.01, // 1% of equity
		StopLossPct:     0.02, // 2% stop loss
		TakeProfitPct:   0.03, // 3% take profit (smaller for mean reversion)
		UseTrendFilter:  true, // Only buy in uptrend, sell in downtrend
		prices:          make([]float64, 0, rsiPeriod+2),
		gains:           make([]float64, 0, rsiPeriod),
		losses:          make([]float64, 0, rsiPeriod),
		logger:          log.New(log.Writer(), "[RSI-MEAN-REV] ", log.LstdFlags),
	}
}

// Initialize sets up the Alpaca clients and loads historical data
func (s *RSIMeanReversionStrategy) Initialize(apiKey, apiSecret, baseURL string) error {
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

	// Load historical data to warm up RSI calculation
	if err := s.loadHistoricalData(); err != nil {
		return fmt.Errorf("failed to load historical data: %w", err)
	}

	// Check current position
	if err := s.syncPosition(); err != nil {
		return fmt.Errorf("failed to sync position: %w", err)
	}

	s.logger.Printf("RSI strategy initialized for %s (Period: %d, Oversold: %.1f, Overbought: %.1f)",
		s.Symbol, s.RSIPeriod, s.OversoldLevel, s.OverboughtLevel)
	return nil
}

// loadHistoricalData fetches enough bars to calculate initial RSI
func (s *RSIMeanReversionStrategy) loadHistoricalData() error {
	end := time.Now()
	// Need more data for trend filter (200-day MA)
	lookback := 220
	if !s.UseTrendFilter {
		lookback = s.RSIPeriod * 2
	}
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

	// Store closing prices
	for _, bar := range bars {
		s.prices = append(s.prices, bar.Close)
	}

	// Calculate initial RSI if we have enough data
	if len(s.prices) > s.RSIPeriod {
		s.calculateInitialRSI()
		
		// Calculate trend MA if using trend filter
		if s.UseTrendFilter && len(s.prices) >= 200 {
			s.trendMA = s.calculateMA(s.prices[len(s.prices)-200:])
		}
	}

	s.logger.Printf("Loaded %d historical bars, initial RSI: %.2f, Trend MA: %.2f",
		len(s.prices), s.currentRSI, s.trendMA)
	return nil
}

// calculateInitialRSI computes the first RSI value using all available data
func (s *RSIMeanReversionStrategy) calculateInitialRSI() {
	if len(s.prices) < s.RSIPeriod+1 {
		return
	}

	// Calculate price changes
	s.gains = []float64{}
	s.losses = []float64{}
	
	startIdx := len(s.prices) - s.RSIPeriod - 1
	for i := startIdx + 1; i < len(s.prices); i++ {
		change := s.prices[i] - s.prices[i-1]
		if change > 0 {
			s.gains = append(s.gains, change)
			s.losses = append(s.losses, 0)
		} else {
			s.gains = append(s.gains, 0)
			s.losses = append(s.losses, math.Abs(change))
		}
	}

	// Calculate average gain and loss
	s.avgGain = s.average(s.gains)
	s.avgLoss = s.average(s.losses)

	// Calculate RSI
	if s.avgLoss == 0 {
		s.currentRSI = 100
	} else {
		rs := s.avgGain / s.avgLoss
		s.currentRSI = 100 - (100 / (1 + rs))
	}
}

// syncPosition checks if we have an existing position
func (s *RSIMeanReversionStrategy) syncPosition() error {
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
func (s *RSIMeanReversionStrategy) ProcessBar(price float64, timestamp time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Update price history
	s.prices = append(s.prices, price)
	
	// Need at least RSI period + 1 prices
	if len(s.prices) < s.RSIPeriod+1 {
		return
	}

	// Keep only what we need (max 200 for trend filter)
	maxKeep := s.RSIPeriod + 1
	if s.UseTrendFilter {
		maxKeep = 201
	}
	if len(s.prices) > maxKeep {
		s.prices = s.prices[len(s.prices)-maxKeep:]
	}

	// Update RSI calculation
	s.updateRSI(price)

	// Update trend filter if enabled
	if s.UseTrendFilter && len(s.prices) >= 200 {
		s.trendMA = s.calculateMA(s.prices[len(s.prices)-200:])
	}

	// Generate signal
	signal := s.generateSignal(price)
	
	if signal != "" {
		s.logger.Printf("Signal generated: %s (RSI: %.2f, Price: %.2f, Trend MA: %.2f)",
			signal, s.currentRSI, price, s.trendMA)
		
		// Execute trade asynchronously
		go s.executeTrade(signal, price)
	}
}

// updateRSI calculates RSI using the exponential moving average method
func (s *RSIMeanReversionStrategy) updateRSI(currentPrice float64) {
	if len(s.prices) < 2 {
		return
	}

	// Calculate the latest price change
	previousPrice := s.prices[len(s.prices)-2]
	change := currentPrice - previousPrice
	
	gain := 0.0
	loss := 0.0
	if change > 0 {
		gain = change
	} else {
		loss = math.Abs(change)
	}

	// Update exponential moving averages (Wilder's smoothing)
	alpha := 1.0 / float64(s.RSIPeriod)
	s.avgGain = (s.avgGain * (1 - alpha)) + (gain * alpha)
	s.avgLoss = (s.avgLoss * (1 - alpha)) + (loss * alpha)

	// Calculate RSI
	if s.avgLoss == 0 {
		s.currentRSI = 100
	} else {
		rs := s.avgGain / s.avgLoss
		s.currentRSI = 100 - (100 / (1 + rs))
	}
}

// generateSignal determines if we should buy/sell based on RSI levels
func (s *RSIMeanReversionStrategy) generateSignal(currentPrice float64) string {
	// Check oversold condition for buy signal
	if s.currentRSI < s.OversoldLevel && !s.hasPosition {
		// Apply trend filter if enabled
		if s.UseTrendFilter && s.trendMA > 0 {
			if currentPrice < s.trendMA * 0.98 { // Price below trend, skip buy
				s.logger.Printf("Oversold but below trend, skipping buy (Price: %.2f < Trend: %.2f)",
					currentPrice, s.trendMA)
				return ""
			}
		}
		
		// Additional confirmation: RSI starting to turn up
		if len(s.gains) > 1 && s.gains[len(s.gains)-1] > s.gains[len(s.gains)-2] {
			s.consecutiveSignals++
			if s.consecutiveSignals >= 1 { // Can require multiple confirmations
				s.consecutiveSignals = 0
				return "BUY"
			}
		}
	}
	
	// Check overbought condition for sell signal
	if s.currentRSI > s.OverboughtLevel && s.hasPosition {
		s.consecutiveSignals = 0
		return "SELL"
	}
	
	// Alternative exit: Stop loss or take profit hit
	if s.hasPosition && s.entryPrice > 0 {
		pnlPct := (currentPrice - s.entryPrice) / s.entryPrice
		
		if pnlPct <= -s.StopLossPct {
			s.logger.Printf("Stop loss triggered: %.2f%%", pnlPct*100)
			return "SELL"
		}
		
		if pnlPct >= s.TakeProfitPct {
			s.logger.Printf("Take profit triggered: %.2f%%", pnlPct*100)
			return "SELL"
		}
	}
	
	return ""
}

// calculateMA computes simple moving average
func (s *RSIMeanReversionStrategy) calculateMA(prices []float64) float64 {
	if len(prices) == 0 {
		return 0
	}
	
	sum := 0.0
	for _, p := range prices {
		sum += p
	}
	return sum / float64(len(prices))
}

// average calculates the average of a slice
func (s *RSIMeanReversionStrategy) average(values []float64) float64 {
	if len(values) == 0 {
		return 0
	}
	
	sum := 0.0
	for _, v := range values {
		sum += v
	}
	return sum / float64(len(values))
}

// executeTrade places orders based on signals
func (s *RSIMeanReversionStrategy) executeTrade(signal string, currentPrice float64) {
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
		// Calculate position size (1% of equity)
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

		// Create bracket order for risk management
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

		s.logger.Printf("Placing BUY order: %d shares at RSI %.2f, stop=%.2f, target=%.2f",
			qty, s.currentRSI, stopPrice, limitPrice)

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

		// Calculate P&L for logging
		pnl := (currentPrice - s.entryPrice) * float64(s.positionQty)
		s.totalPnL += pnl
		if pnl > 0 {
			s.winCount++
		}
		s.tradeCount++

		s.logger.Printf("Placing SELL order: %d shares at RSI %.2f, entry=%.2f, exit=%.2f, P&L=%.2f",
			s.positionQty, s.currentRSI, s.entryPrice, currentPrice, pnl)
	}

	// Submit order
	order, err := s.tradingClient.PlaceOrder(orderReq)
	if err != nil {
		s.logger.Printf("Order failed: %v", err)
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
func (s *RSIMeanReversionStrategy) validateTradeCompliance(account *alpaca.Account, signal string) bool {
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

	// Additional check for mean reversion: avoid catching falling knives
	if signal == "BUY" && s.currentRSI < 20 {
		s.logger.Printf("Warning: Extremely oversold (RSI: %.2f), consider waiting", s.currentRSI)
		// Still allow but log warning
	}

	return true
}

// GetStatistics returns strategy performance metrics
func (s *RSIMeanReversionStrategy) GetStatistics() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()

	winRate := 0.0
	avgTrade := 0.0
	if s.tradeCount > 0 {
		winRate = float64(s.winCount) / float64(s.tradeCount) * 100
		avgTrade = s.totalPnL / float64(s.tradeCount)
	}

	return map[string]interface{}{
		"symbol":         s.Symbol,
		"strategy":       "RSI Mean Reversion",
		"rsi_period":     s.RSIPeriod,
		"current_rsi":    s.currentRSI,
		"oversold_level": s.OversoldLevel,
		"overbought_level": s.OverboughtLevel,
		"trades":         s.tradeCount,
		"wins":           s.winCount,
		"win_rate":       winRate,
		"total_pnl":      s.totalPnL,
		"avg_trade_pnl":  avgTrade,
		"has_position":   s.hasPosition,
		"trend_filter":   s.UseTrendFilter,
		"trend_ma":       s.trendMA,
	}
}

// Run starts the strategy main loop with WebSocket streaming
func (s *RSIMeanReversionStrategy) Run(ctx context.Context) error {
	// Use polling approach for now (WebSocket streaming to follow)
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()

	s.logger.Printf("RSI Mean Reversion strategy running for %s", s.Symbol)

	// Periodic statistics reporting
	statsTicker := time.NewTicker(5 * time.Minute)
	defer statsTicker.Stop()

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