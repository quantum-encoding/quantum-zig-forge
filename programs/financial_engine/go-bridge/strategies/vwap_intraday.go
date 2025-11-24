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

// VWAPIntradayStrategy implements mean reversion around Volume-Weighted Average Price
// Ideal for day trading, especially crypto (24/7, no PDT rules)
type VWAPIntradayStrategy struct {
	// Configuration
	Symbol        string
	TimeFrame     marketdata.TimeFrame // Bar timeframe (1Min, 5Min, etc)
	PositionSize  float64             // Percentage of equity
	StopLossPct   float64
	TakeProfitPct float64
	VWAPDeviation float64 // Buy below VWAP-deviation%, sell above VWAP+deviation%
	MinVolume     float64 // Minimum volume for trade signals
	MaxPositions  int     // Max intraday positions (risk management)

	// Alpaca clients
	tradingClient *alpaca.Client
	dataClient    *marketdata.Client

	// State management
	mu            sync.RWMutex
	vwap          float64
	cumulativePV  float64 // Cumulative Price*Volume
	cumulativeVol float64 // Cumulative Volume
	dayHighPrice  float64
	dayLowPrice   float64
	avgVolume     float64
	lastResetTime time.Time
	intradayBars  []IntradayBar
	
	// Position tracking
	hasPosition   bool
	entryPrice    float64
	positionQty   int64
	dayTrades     int // Track day trades for risk management
	lastSignal    string
	
	// Performance tracking
	logger        *log.Logger
	tradeCount    int
	winCount      int
	totalPnL      float64
	maxDrawdown   float64
	currentDrawdown float64
}

// IntradayBar stores bar data for VWAP calculation
type IntradayBar struct {
	Time   time.Time
	Price  float64
	Volume float64
	High   float64
	Low    float64
}

// NewVWAPIntradayStrategy creates a new VWAP intraday strategy
func NewVWAPIntradayStrategy(symbol string, timeFrame marketdata.TimeFrame) *VWAPIntradayStrategy {
	return &VWAPIntradayStrategy{
		Symbol:        symbol,
		TimeFrame:     timeFrame,
		PositionSize:  0.005,  // 0.5% for intraday (smaller size, more trades)
		StopLossPct:   0.01,   // 1% stop loss (tighter for intraday)
		TakeProfitPct: 0.015,  // 1.5% take profit
		VWAPDeviation: 0.005,  // 0.5% deviation from VWAP
		MinVolume:     10000,  // Minimum volume threshold
		MaxPositions:  3,      // Max 3 positions per day
		intradayBars:  make([]IntradayBar, 0, 390), // ~390 minutes in regular session
		logger:        log.New(log.Writer(), "[VWAP-INTRADAY] ", log.LstdFlags),
	}
}

// Initialize sets up the Alpaca clients and prepares for trading
func (s *VWAPIntradayStrategy) Initialize(apiKey, apiSecret, baseURL string) error {
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

	// Check if crypto (24/7) or stock
	s.checkAssetType()

	// Initialize VWAP for current session
	if err := s.initializeVWAP(); err != nil {
		return fmt.Errorf("failed to initialize VWAP: %w", err)
	}

	// Check current position
	if err := s.syncPosition(); err != nil {
		return fmt.Errorf("failed to sync position: %w", err)
	}

	s.logger.Printf("VWAP Intraday strategy initialized for %s (TimeFrame: %v, Deviation: %.2f%%)",
		s.Symbol, s.TimeFrame, s.VWAPDeviation*100)
	return nil
}

// checkAssetType determines if trading crypto or stocks for PDT rules
func (s *VWAPIntradayStrategy) checkAssetType() {
	// Check if symbol is crypto (contains USD, USDT, USDC)
	if len(s.Symbol) > 3 && (s.Symbol[len(s.Symbol)-3:] == "USD" || 
		s.Symbol[len(s.Symbol)-4:] == "USDT" || 
		s.Symbol[len(s.Symbol)-4:] == "USDC") {
		s.logger.Printf("Crypto asset detected - PDT rules do not apply")
		s.MaxPositions = 10 // Allow more trades for crypto
	}
}

// initializeVWAP loads today's bars to calculate initial VWAP
func (s *VWAPIntradayStrategy) initializeVWAP() error {
	now := time.Now()
	
	// Determine session start based on asset type
	var sessionStart time.Time
	if s.MaxPositions > 3 { // Crypto (24/7)
		sessionStart = time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, now.Location())
	} else { // Stocks (9:30 AM ET)
		loc, _ := time.LoadLocation("America/New_York")
		sessionStart = time.Date(now.Year(), now.Month(), now.Day(), 9, 30, 0, 0, loc)
		
		// If before market open, use previous day
		if now.Before(sessionStart) {
			sessionStart = sessionStart.AddDate(0, 0, -1)
		}
	}

	s.lastResetTime = sessionStart

	// Fetch today's bars
	barsReq := marketdata.GetBarsRequest{
		TimeFrame: s.TimeFrame,
		Start:     sessionStart,
		End:       now,
		PageLimit: 1000,
	}

	bars, err := s.dataClient.GetBars(s.Symbol, barsReq)
	if err != nil {
		return err
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	// Reset VWAP calculation
	s.cumulativePV = 0
	s.cumulativeVol = 0
	s.intradayBars = []IntradayBar{}
	s.dayHighPrice = 0
	s.dayLowPrice = math.MaxFloat64

	// Process bars to calculate VWAP
	totalVolume := 0.0
	for _, bar := range bars {
		typicalPrice := (bar.High + bar.Low + bar.Close) / 3
		volume := float64(bar.Volume)
		
		s.cumulativePV += typicalPrice * volume
		s.cumulativeVol += volume
		totalVolume += volume
		
		// Track day high/low
		if bar.High > s.dayHighPrice {
			s.dayHighPrice = bar.High
		}
		if bar.Low < s.dayLowPrice {
			s.dayLowPrice = bar.Low
		}
		
		// Store bar
		s.intradayBars = append(s.intradayBars, IntradayBar{
			Time:   bar.Timestamp,
			Price:  bar.Close,
			Volume: volume,
			High:   bar.High,
			Low:    bar.Low,
		})
	}

	// Calculate VWAP
	if s.cumulativeVol > 0 {
		s.vwap = s.cumulativePV / s.cumulativeVol
		s.avgVolume = totalVolume / float64(len(bars))
	}

	s.logger.Printf("VWAP initialized: %.2f (from %d bars, avg volume: %.0f)",
		s.vwap, len(bars), s.avgVolume)
	return nil
}

// syncPosition checks if we have an existing position
func (s *VWAPIntradayStrategy) syncPosition() error {
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
func (s *VWAPIntradayStrategy) ProcessBar(price, volume float64, high, low float64, timestamp time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if we need to reset for new trading day
	s.checkDayReset(timestamp)

	// Update VWAP calculation
	typicalPrice := (high + low + price) / 3
	s.cumulativePV += typicalPrice * volume
	s.cumulativeVol += volume
	
	if s.cumulativeVol > 0 {
		s.vwap = s.cumulativePV / s.cumulativeVol
	}

	// Update day high/low
	if high > s.dayHighPrice {
		s.dayHighPrice = high
	}
	if low < s.dayLowPrice {
		s.dayLowPrice = low
	}

	// Store bar
	s.intradayBars = append(s.intradayBars, IntradayBar{
		Time:   timestamp,
		Price:  price,
		Volume: volume,
		High:   high,
		Low:    low,
	})

	// Update average volume
	if len(s.intradayBars) > 20 {
		recentVol := 0.0
		for i := len(s.intradayBars) - 20; i < len(s.intradayBars); i++ {
			recentVol += s.intradayBars[i].Volume
		}
		s.avgVolume = recentVol / 20
	}

	// Generate signal
	signal := s.generateSignal(price, volume)
	
	if signal != "" {
		s.logger.Printf("Signal: %s | Price: %.2f | VWAP: %.2f | Deviation: %.2f%% | Volume: %.0f",
			signal, price, s.vwap, ((price-s.vwap)/s.vwap)*100, volume)
		
		// Execute trade asynchronously
		go s.executeTrade(signal, price)
	}
}

// checkDayReset resets VWAP at start of new trading day
func (s *VWAPIntradayStrategy) checkDayReset(timestamp time.Time) {
	// For stocks, reset at 9:30 AM ET
	// For crypto, reset at midnight UTC
	var shouldReset bool
	
	if s.MaxPositions > 3 { // Crypto
		shouldReset = timestamp.Day() != s.lastResetTime.Day()
	} else { // Stocks
		loc, _ := time.LoadLocation("America/New_York")
		marketOpen := time.Date(timestamp.Year(), timestamp.Month(), timestamp.Day(), 9, 30, 0, 0, loc)
		shouldReset = timestamp.After(marketOpen) && s.lastResetTime.Before(marketOpen)
	}
	
	if shouldReset {
		s.logger.Printf("New trading day detected, resetting VWAP")
		s.cumulativePV = 0
		s.cumulativeVol = 0
		s.vwap = 0
		s.dayHighPrice = 0
		s.dayLowPrice = math.MaxFloat64
		s.intradayBars = []IntradayBar{}
		s.dayTrades = 0
		s.lastResetTime = timestamp
	}
}

// generateSignal determines if we should buy/sell based on VWAP levels
func (s *VWAPIntradayStrategy) generateSignal(price, volume float64) string {
	// Need valid VWAP
	if s.vwap == 0 || s.cumulativeVol < s.MinVolume {
		return ""
	}

	// Calculate deviation from VWAP
	deviation := (price - s.vwap) / s.vwap
	
	// Buy signals
	if !s.hasPosition && s.dayTrades < s.MaxPositions {
		// Buy when price is below VWAP by threshold with volume confirmation
		if deviation < -s.VWAPDeviation && volume > s.avgVolume {
			// Additional filter: Price bouncing from day low
			if price > s.dayLowPrice * 1.001 {
				return "BUY"
			}
		}
		
		// Alternative: Strong bounce from VWAP with high volume
		if math.Abs(deviation) < 0.001 && volume > s.avgVolume * 2 {
			// Price touching VWAP with high volume
			if len(s.intradayBars) > 1 {
				prevPrice := s.intradayBars[len(s.intradayBars)-2].Price
				if prevPrice < s.vwap && price > s.vwap {
					s.logger.Printf("VWAP bounce detected with volume surge")
					return "BUY"
				}
			}
		}
	}
	
	// Sell signals
	if s.hasPosition {
		// Sell when price is above VWAP by threshold
		if deviation > s.VWAPDeviation {
			return "SELL"
		}
		
		// Mean reversion complete - price returned to VWAP
		if s.entryPrice < s.vwap && price >= s.vwap {
			s.logger.Printf("Mean reversion to VWAP complete")
			return "SELL"
		}
		
		// Intraday momentum dying - decreasing volume
		if volume < s.avgVolume * 0.5 && deviation < 0 {
			s.logger.Printf("Momentum fading, volume declining")
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
func (s *VWAPIntradayStrategy) executeTrade(signal string, currentPrice float64) {
	// Get account info for position sizing
	account, err := s.tradingClient.GetAccount()
	if err != nil {
		s.logger.Printf("Failed to get account: %v", err)
		return
	}

	equity, _ := account.Equity.Float64()
	buyingPower, _ := account.BuyingPower.Float64()

	// Check PDT and other protections (skip for crypto)
	if s.MaxPositions <= 3 && !s.validateTradeCompliance(account, signal) {
		s.logger.Printf("Trade blocked by compliance checks")
		return
	}

	var orderReq alpaca.PlaceOrderRequest
	var qty int64

	if signal == "BUY" {
		// Calculate position size (smaller for intraday)
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

		// Create bracket order with tight stops for intraday
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

		s.logger.Printf("Placing BUY order: %d shares at %.2f (VWAP: %.2f), stop=%.2f, target=%.2f",
			qty, currentPrice, s.vwap, stopPrice, limitPrice)

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
			TimeInForce: alpaca.IOC, // Immediate or cancel for quick exit
		}

		// Calculate P&L
		pnl := (currentPrice - s.entryPrice) * float64(s.positionQty)
		s.totalPnL += pnl
		if pnl > 0 {
			s.winCount++
		} else {
			// Track drawdown
			s.currentDrawdown += math.Abs(pnl)
			if s.currentDrawdown > s.maxDrawdown {
				s.maxDrawdown = s.currentDrawdown
			}
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
		s.dayTrades++
		s.currentDrawdown = 0 // Reset on new position
	} else if signal == "SELL" {
		s.hasPosition = false
		s.entryPrice = 0
		s.positionQty = 0
	}
	s.lastSignal = signal
	s.mu.Unlock()

	s.logger.Printf("Order placed successfully: %s", order.ID)
}

// validateTradeCompliance checks PDT rules for stock trading
func (s *VWAPIntradayStrategy) validateTradeCompliance(account *alpaca.Account, signal string) bool {
	// Check Pattern Day Trader rule (stocks only)
	if account.PatternDayTrader && s.dayTrades >= 3 {
		equity, _ := account.Equity.Float64()
		if equity < 25000 {
			s.logger.Printf("PDT rule: Already made %d day trades with equity %.2f < $25,000",
				s.dayTrades, equity)
			return false
		}
	}

	// Check for Day Trade Margin Call
	if account.TradingBlocked {
		s.logger.Printf("Trading blocked on account")
		return false
	}

	// Intraday position limit
	if s.dayTrades >= s.MaxPositions {
		s.logger.Printf("Max intraday positions reached: %d", s.MaxPositions)
		return false
	}

	return true
}

// GetStatistics returns strategy performance metrics
func (s *VWAPIntradayStrategy) GetStatistics() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()

	winRate := 0.0
	avgTrade := 0.0
	if s.tradeCount > 0 {
		winRate = float64(s.winCount) / float64(s.tradeCount) * 100
		avgTrade = s.totalPnL / float64(s.tradeCount)
	}

	profitFactor := 0.0
	if s.maxDrawdown > 0 {
		profitFactor = math.Max(0, s.totalPnL) / s.maxDrawdown
	}

	return map[string]interface{}{
		"symbol":         s.Symbol,
		"strategy":       "VWAP Intraday",
		"timeframe":      s.TimeFrame,
		"trades":         s.tradeCount,
		"wins":           s.winCount,
		"win_rate":       winRate,
		"total_pnl":      s.totalPnL,
		"avg_trade_pnl":  avgTrade,
		"max_drawdown":   s.maxDrawdown,
		"profit_factor":  profitFactor,
		"current_vwap":   s.vwap,
		"day_trades":     s.dayTrades,
		"has_position":   s.hasPosition,
	}
}

// Run starts the strategy main loop with WebSocket streaming
func (s *VWAPIntradayStrategy) Run(ctx context.Context) error {
	// Create WebSocket connection for real-time bars
	// Temporary polling approach - WebSocket implementation follows
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()
	
	// WebSocket streaming temporarily disabled for compilation
	// Will implement proper Alpaca WebSocket streaming next

	s.logger.Printf("VWAP Intraday strategy running for %s", s.Symbol)

	// More frequent reporting for intraday
	statsTicker := time.NewTicker(15 * time.Minute)
	defer statsTicker.Stop()

	// End of day reporting
	eodTicker := time.NewTicker(time.Hour)
	defer eodTicker.Stop()

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
			s.logger.Printf("Intraday Statistics: %+v", stats)
			
		case <-eodTicker.C:
			// Check for end of day
			now := time.Now()
			loc, _ := time.LoadLocation("America/New_York")
			marketClose := time.Date(now.Year(), now.Month(), now.Day(), 16, 0, 0, 0, loc)
			
			if now.After(marketClose) && s.hasPosition {
				s.logger.Printf("Market closing, liquidating position")
				go s.executeTrade("SELL", s.intradayBars[len(s.intradayBars)-1].Price)
			}
		}
	}
}