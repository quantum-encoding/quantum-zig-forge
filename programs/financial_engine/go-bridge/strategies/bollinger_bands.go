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

// BollingerBandsStrategy implements a volatility breakout strategy
// Buys on upper band breakout with volume confirmation, sells on lower band cross
type BollingerBandsStrategy struct {
	// Configuration
	Symbol        string
	Period        int     // BB period (typically 20)
	StdDevs       float64 // Number of standard deviations (typically 2)
	PositionSize  float64 // Percentage of equity
	StopLossPct   float64
	TakeProfitPct float64
	VolumeFactor  float64 // Volume must be X times average for confirmation
	SqueezeThreshold float64 // Band width threshold for squeeze detection

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
	volumes       []float64
	upperBand     float64
	lowerBand     float64
	middleBand    float64
	bandwidth     float64
	avgVolume     float64
	inSqueeze     bool
	lastSignal    string
	hasPosition   bool
	entryPrice    float64
	positionQty   int64
	
	// Performance tracking
	logger        *log.Logger
	tradeCount    int
	winCount      int
	totalPnL      float64
	falseBreakouts int
}

// NewBollingerBandsStrategy creates a new Bollinger Bands strategy
func NewBollingerBandsStrategy(symbol string, period int) *BollingerBandsStrategy {
	return &BollingerBandsStrategy{
		Symbol:           symbol,
		Period:           period,
		StdDevs:          2.0,
		PositionSize:     0.01, // 1% of equity
		StopLossPct:      0.02, // 2% stop loss
		TakeProfitPct:    0.04, // 4% take profit
		VolumeFactor:     1.5,  // Volume must be 1.5x average
		SqueezeThreshold: 0.02, // 2% bandwidth for squeeze
		prices:           make([]float64, 0, period+1),
		volumes:          make([]float64, 0, period+1),
		logger:           log.New(log.Writer(), "[BB-BREAKOUT] ", log.LstdFlags),
	}
}

// Initialize sets up the Alpaca clients and loads historical data
func (s *BollingerBandsStrategy) Initialize(apiKey, apiSecret, baseURL string) error {
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

	s.logger.Printf("Bollinger Bands strategy initialized for %s (Period: %d, StdDev: %.1f)",
		s.Symbol, s.Period, s.StdDevs)
	return nil
}

// loadHistoricalData fetches enough bars to calculate initial Bollinger Bands
func (s *BollingerBandsStrategy) loadHistoricalData() error {
	end := time.Now()
	start := end.AddDate(0, 0, -(s.Period * 3)) // Get extra data for warmup

	barsReq := marketdata.GetBarsRequest{
		TimeFrame: marketdata.OneDay,
		Start:     start,
		End:       end,
		PageLimit: int(s.Period * 3),
	}

	bars, err := s.dataClient.GetBars(s.Symbol, barsReq)
	if err != nil {
		return err
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	// Store closing prices and volumes
	for _, bar := range bars {
		s.prices = append(s.prices, bar.Close)
		s.volumes = append(s.volumes, float64(bar.Volume))
	}

	// Trim to needed size
	if len(s.prices) > s.Period {
		s.prices = s.prices[len(s.prices)-s.Period:]
		s.volumes = s.volumes[len(s.volumes)-s.Period:]
	}

	// Calculate initial bands
	if len(s.prices) >= s.Period {
		s.calculateBands()
		s.avgVolume = s.calculateAverage(s.volumes)
	}

	s.logger.Printf("Loaded %d historical bars, initial bands: Upper=%.2f, Middle=%.2f, Lower=%.2f, Width=%.4f",
		len(s.prices), s.upperBand, s.middleBand, s.lowerBand, s.bandwidth)
	return nil
}

// syncPosition checks if we have an existing position
func (s *BollingerBandsStrategy) syncPosition() error {
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
func (s *BollingerBandsStrategy) ProcessBar(price float64, volume float64, timestamp time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Update price and volume history
	s.prices = append(s.prices, price)
	s.volumes = append(s.volumes, volume)

	// Keep only needed history
	if len(s.prices) > s.Period {
		s.prices = s.prices[1:]
		s.volumes = s.volumes[1:]
	}

	// Need full period for calculations
	if len(s.prices) < s.Period {
		return
	}

	// Calculate bands and indicators
	prevUpper := s.upperBand
	prevLower := s.lowerBand
	prevBandwidth := s.bandwidth
	
	s.calculateBands()
	s.avgVolume = s.calculateAverage(s.volumes)

	// Detect squeeze (bands contracting)
	wasInSqueeze := s.inSqueeze
	s.inSqueeze = s.bandwidth < s.SqueezeThreshold
	
	if wasInSqueeze && !s.inSqueeze {
		s.logger.Printf("Squeeze release detected! Bandwidth expanded from %.4f to %.4f", 
			prevBandwidth, s.bandwidth)
	}

	// Generate signal
	signal := s.generateSignal(price, volume, prevUpper, prevLower)
	
	if signal != "" {
		s.logger.Printf("Signal: %s | Price: %.2f | Bands: [%.2f, %.2f, %.2f] | Volume: %.0f (avg: %.0f)",
			signal, price, s.upperBand, s.middleBand, s.lowerBand, volume, s.avgVolume)
		
		// Execute trade asynchronously
		go s.executeTrade(signal, price)
	}
}

// calculateBands computes Bollinger Bands
func (s *BollingerBandsStrategy) calculateBands() {
	// Calculate SMA (middle band)
	s.middleBand = s.calculateAverage(s.prices)
	
	// Calculate standard deviation
	stdDev := s.calculateStdDev(s.prices, s.middleBand)
	
	// Calculate bands
	s.upperBand = s.middleBand + (s.StdDevs * stdDev)
	s.lowerBand = s.middleBand - (s.StdDevs * stdDev)
	
	// Calculate bandwidth (relative width)
	if s.middleBand > 0 {
		s.bandwidth = (s.upperBand - s.lowerBand) / s.middleBand
	}
}

// calculateAverage computes simple average
func (s *BollingerBandsStrategy) calculateAverage(values []float64) float64 {
	if len(values) == 0 {
		return 0
	}
	
	sum := 0.0
	for _, v := range values {
		sum += v
	}
	return sum / float64(len(values))
}

// calculateStdDev computes standard deviation
func (s *BollingerBandsStrategy) calculateStdDev(values []float64, mean float64) float64 {
	if len(values) == 0 {
		return 0
	}
	
	sumSquares := 0.0
	for _, v := range values {
		diff := v - mean
		sumSquares += diff * diff
	}
	
	variance := sumSquares / float64(len(values))
	return math.Sqrt(variance)
}

// generateSignal determines if we should buy/sell based on band breakouts
func (s *BollingerBandsStrategy) generateSignal(price, volume float64, prevUpper, prevLower float64) string {
	// Previous price (for crossover detection)
	if len(s.prices) < 2 {
		return ""
	}
	prevPrice := s.prices[len(s.prices)-2]
	
	// Buy signal: Upper band breakout with volume confirmation
	if !s.hasPosition {
		// Check for upper band breakout
		if prevPrice <= prevUpper && price > s.upperBand {
			// Confirm with volume (must be above average)
			if volume > s.avgVolume * s.VolumeFactor {
				// Additional filter: Not in squeeze (avoid false breakouts)
				if !s.inSqueeze {
					return "BUY"
				} else {
					s.logger.Printf("Upper band breakout during squeeze - waiting for expansion")
				}
			} else {
				s.logger.Printf("Upper band breakout without volume confirmation (%.0f < %.0f)", 
					volume, s.avgVolume * s.VolumeFactor)
				s.falseBreakouts++
			}
		}
		
		// Alternative buy: Bounce from lower band in uptrend
		if price > s.lowerBand && prevPrice <= prevLower && s.middleBand > s.prices[0] {
			return "BUY"
		}
	}
	
	// Sell signals
	if s.hasPosition {
		// Sell signal 1: Lower band cross
		if price < s.lowerBand {
			s.logger.Printf("Sell signal: Price crossed below lower band")
			return "SELL"
		}
		
		// Sell signal 2: Return to middle band after upper band breakout
		if s.lastSignal == "BUY" && price < s.middleBand {
			s.logger.Printf("Sell signal: Price returned to middle band")
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
func (s *BollingerBandsStrategy) executeTrade(signal string, currentPrice float64) {
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
func (s *BollingerBandsStrategy) validateTradeCompliance(account *alpaca.Account, signal string) bool {
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
func (s *BollingerBandsStrategy) GetStatistics() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()

	winRate := 0.0
	avgTrade := 0.0
	if s.tradeCount > 0 {
		winRate = float64(s.winCount) / float64(s.tradeCount) * 100
		avgTrade = s.totalPnL / float64(s.tradeCount)
	}

	falseBreakoutRate := 0.0
	if (s.tradeCount + s.falseBreakouts) > 0 {
		falseBreakoutRate = float64(s.falseBreakouts) / float64(s.tradeCount + s.falseBreakouts) * 100
	}

	return map[string]interface{}{
		"symbol":           s.Symbol,
		"strategy":         "Bollinger Bands Breakout",
		"period":           s.Period,
		"std_devs":         s.StdDevs,
		"trades":           s.tradeCount,
		"wins":             s.winCount,
		"win_rate":         winRate,
		"total_pnl":        s.totalPnL,
		"avg_trade_pnl":    avgTrade,
		"false_breakouts":  s.falseBreakouts,
		"false_breakout_rate": falseBreakoutRate,
		"current_bandwidth": s.bandwidth,
		"in_squeeze":       s.inSqueeze,
		"has_position":     s.hasPosition,
	}
}

// fetchAndProcessLatestBar fetches the latest bar and processes it
func (s *BollingerBandsStrategy) fetchAndProcessLatestBar() error {
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
		s.ProcessBar(latestBar.Close, float64(latestBar.Volume), latestBar.Timestamp)
	}

	return nil
}

// Run starts the strategy main loop with WebSocket streaming
func (s *BollingerBandsStrategy) Run(ctx context.Context) error {
	// Create proper WebSocket market data stream
	marketStream := NewMarketDataStream(s.apiKey, s.apiSecret, s.baseURL)
	
	// Set up bar handler
	marketStream.SetBarHandler(func(bar MarketBar) {
		if bar.Symbol == s.Symbol {
			s.ProcessBar(bar.Close, float64(bar.Volume), bar.Timestamp)
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

	s.logger.Printf("Bollinger Bands strategy running for %s", s.Symbol)

	// Periodic statistics reporting
	statsTicker := time.NewTicker(5 * time.Minute)
	defer statsTicker.Stop()

	s.logger.Printf("Bollinger Bands strategy running with WebSocket streaming for %s", s.Symbol)
	
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