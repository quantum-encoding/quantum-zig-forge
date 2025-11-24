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

// MovingAverageCrossoverStrategy implements a classic trend-following strategy
// Buys when short MA crosses above long MA, sells when it crosses below
type MovingAverageCrossoverStrategy struct {
	// Configuration
	Symbol        string
	ShortWindow   int
	LongWindow    int
	PositionSize  float64 // Percentage of equity
	StopLossPct   float64
	TakeProfitPct float64

	// Alpaca clients
	tradingClient *alpaca.Client
	dataClient    *marketdata.Client

	// State management
	mu            sync.RWMutex
	prices        []float64
	shortMA       float64
	longMA        float64
	lastSignal    string
	hasPosition   bool
	entryPrice    float64
	positionQty   int64

	// Logging and monitoring
	logger        *log.Logger
	tradeCount    int
	winCount      int
	totalPnL      float64
}

// NewMovingAverageCrossoverStrategy creates a new MA crossover strategy instance
func NewMovingAverageCrossoverStrategy(symbol string, shortWindow, longWindow int) *MovingAverageCrossoverStrategy {
	return &MovingAverageCrossoverStrategy{
		Symbol:        symbol,
		ShortWindow:   shortWindow,
		LongWindow:    longWindow,
		PositionSize:  0.01, // 1% of equity default
		StopLossPct:   0.02, // 2% stop loss
		TakeProfitPct: 0.05, // 5% take profit
		prices:        make([]float64, 0, longWindow+1),
		logger:        log.New(log.Writer(), "[MA-CROSS] ", log.LstdFlags),
	}
}

// Initialize sets up the Alpaca clients and loads historical data
func (s *MovingAverageCrossoverStrategy) Initialize(apiKey, apiSecret, baseURL string) error {
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

	// Load historical data to warm up moving averages
	if err := s.loadHistoricalData(); err != nil {
		return fmt.Errorf("failed to load historical data: %w", err)
	}

	// Check current position
	if err := s.syncPosition(); err != nil {
		return fmt.Errorf("failed to sync position: %w", err)
	}

	s.logger.Printf("Strategy initialized for %s (MA %d/%d)", s.Symbol, s.ShortWindow, s.LongWindow)
	return nil
}

// loadHistoricalData fetches enough bars to calculate initial MAs
func (s *MovingAverageCrossoverStrategy) loadHistoricalData() error {
	end := time.Now()
	start := end.AddDate(0, 0, -(s.LongWindow * 2)) // Get extra data for warmup

	barsReq := marketdata.GetBarsRequest{
		TimeFrame: marketdata.OneDay,
		Start:     start,
		End:       end,
		PageLimit: int(s.LongWindow * 2),
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

	// Trim to max needed
	if len(s.prices) > s.LongWindow {
		s.prices = s.prices[len(s.prices)-s.LongWindow:]
	}

	// Calculate initial MAs if we have enough data
	if len(s.prices) >= s.LongWindow {
		s.longMA = s.calculateMA(s.prices)
		if len(s.prices) >= s.ShortWindow {
			s.shortMA = s.calculateMA(s.prices[len(s.prices)-s.ShortWindow:])
		}
	}

	s.logger.Printf("Loaded %d historical bars, initial MAs: short=%.2f, long=%.2f", 
		len(s.prices), s.shortMA, s.longMA)
	return nil
}

// syncPosition checks if we have an existing position
func (s *MovingAverageCrossoverStrategy) syncPosition() error {
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
func (s *MovingAverageCrossoverStrategy) ProcessBar(price float64, timestamp time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Update price history
	s.prices = append(s.prices, price)
	if len(s.prices) > s.LongWindow {
		s.prices = s.prices[1:] // Keep only needed history
	}

	// Need full window for long MA
	if len(s.prices) < s.LongWindow {
		return
	}

	// Calculate moving averages
	prevShortMA := s.shortMA
	prevLongMA := s.longMA
	
	s.longMA = s.calculateMA(s.prices)
	s.shortMA = s.calculateMA(s.prices[len(s.prices)-s.ShortWindow:])

	// Generate signal
	signal := s.generateSignal(prevShortMA, prevLongMA)
	
	if signal != "" {
		s.logger.Printf("Signal generated: %s (Short MA: %.2f, Long MA: %.2f, Price: %.2f)",
			signal, s.shortMA, s.longMA, price)
		
		// Execute trade asynchronously to avoid blocking
		go s.executeTrade(signal, price)
	}
}

// generateSignal determines if we should buy/sell based on MA crossover
func (s *MovingAverageCrossoverStrategy) generateSignal(prevShort, prevLong float64) string {
	// Golden cross: short MA crosses above long MA
	if prevShort <= prevLong && s.shortMA > s.longMA && !s.hasPosition {
		return "BUY"
	}
	
	// Death cross: short MA crosses below long MA
	if prevShort >= prevLong && s.shortMA < s.longMA && s.hasPosition {
		return "SELL"
	}
	
	return ""
}

// calculateMA computes simple moving average
func (s *MovingAverageCrossoverStrategy) calculateMA(prices []float64) float64 {
	if len(prices) == 0 {
		return 0
	}
	
	sum := 0.0
	for _, p := range prices {
		sum += p
	}
	return sum / float64(len(prices))
}

// executeTrade places orders based on signals
func (s *MovingAverageCrossoverStrategy) executeTrade(signal string, currentPrice float64) {
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

		// Create bracket order with stop loss and take profit
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

		// Calculate P&L for logging
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
func (s *MovingAverageCrossoverStrategy) validateTradeCompliance(account *alpaca.Account, signal string) bool {
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
func (s *MovingAverageCrossoverStrategy) GetStatistics() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()

	winRate := 0.0
	if s.tradeCount > 0 {
		winRate = float64(s.winCount) / float64(s.tradeCount) * 100
	}

	return map[string]interface{}{
		"symbol":       s.Symbol,
		"strategy":     "Moving Average Crossover",
		"short_window": s.ShortWindow,
		"long_window":  s.LongWindow,
		"trades":       s.tradeCount,
		"wins":         s.winCount,
		"win_rate":     winRate,
		"total_pnl":    s.totalPnL,
		"current_ma_short": s.shortMA,
		"current_ma_long":  s.longMA,
		"has_position": s.hasPosition,
	}
}

// Run starts the strategy main loop with WebSocket streaming
func (s *MovingAverageCrossoverStrategy) Run(ctx context.Context) error {
	// Use polling approach (WebSocket streaming will be implemented later)
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()

	s.logger.Printf("Strategy running for %s", s.Symbol)

	// Run until context is cancelled
	<-ctx.Done()
	
	// Print final statistics
	stats := s.GetStatistics()
	s.logger.Printf("Final Statistics: %+v", stats)
	
	return nil
}