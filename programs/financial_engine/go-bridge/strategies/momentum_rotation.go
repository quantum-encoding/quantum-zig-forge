package strategies

import (
	"context"
	"fmt"
	"log"
	"math"
	"sort"
	"sync"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
	"github.com/shopspring/decimal"
)

// MomentumRotationStrategy implements portfolio-level momentum investing
// Ranks assets by recent performance, rotates into top performers monthly
type MomentumRotationStrategy struct {
	// Configuration
	Basket        []string // Universe of symbols to choose from
	LookbackDays  int      // Days to calculate momentum (e.g., 63 = 3 months)
	TopN          int      // Number of top performers to hold
	MinMomentum   float64  // Minimum momentum threshold (e.g., 0% = positive only)
	RebalanceDays int      // Days between rebalancing (e.g., 30 = monthly)
	MaxSectorExp  float64  // Max exposure to single sector (optional)
	UseCashProxy  bool     // Use cash proxy (e.g., SHY) when no positive momentum
	CashProxy     string   // Cash equivalent symbol

	// Alpaca clients
	tradingClient *alpaca.Client
	dataClient    *marketdata.Client

	// State management
	mu                sync.RWMutex
	currentHoldings   map[string]float64 // Symbol -> weight
	momentumScores    map[string]float64 // Symbol -> ROC score
	lastRebalance     time.Time
	nextRebalance     time.Time
	sectorExposure    map[string]float64 // Sector -> exposure %
	totalRebalances   int
	
	// Performance tracking
	logger            *log.Logger
	rebalanceCount    int
	turnover          float64 // Average portfolio turnover
	totalPnL          float64
	benchmarkReturn   float64 // SPY buy-and-hold comparison
	startEquity       float64
	currentEquity     float64
}

// AssetMomentum holds momentum data for ranking
type AssetMomentum struct {
	Symbol   string
	ROC      float64 // Rate of change
	Sharpe   float64 // Risk-adjusted momentum
	Volume   float64 // Average volume for liquidity
	Sector   string  // For sector exposure tracking
}

// NewMomentumRotationStrategy creates a new momentum rotation strategy
func NewMomentumRotationStrategy(basket []string) *MomentumRotationStrategy {
	return &MomentumRotationStrategy{
		Basket:          basket,
		LookbackDays:    63,    // 3 months default
		TopN:            3,      // Hold top 3 assets
		MinMomentum:     0.0,    // Only positive momentum
		RebalanceDays:   30,     // Monthly rebalancing
		MaxSectorExp:    0.4,    // Max 40% in one sector
		UseCashProxy:    true,   // Use cash when defensive
		CashProxy:       "SHY",  // Short-term Treasury ETF
		currentHoldings: make(map[string]float64),
		momentumScores:  make(map[string]float64),
		sectorExposure:  make(map[string]float64),
		logger:          log.New(log.Writer(), "[MOMENTUM-ROT] ", log.LstdFlags),
	}
}

// Initialize sets up the Alpaca clients and prepares for trading
func (s *MomentumRotationStrategy) Initialize(apiKey, apiSecret, baseURL string) error {
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

	// Get initial account equity
	account, err := s.tradingClient.GetAccount()
	if err != nil {
		return fmt.Errorf("failed to get account: %w", err)
	}
	
	equity, _ := account.Equity.Float64()
	s.startEquity = equity
	s.currentEquity = equity

	// Sync current holdings
	if err := s.syncHoldings(); err != nil {
		return fmt.Errorf("failed to sync holdings: %w", err)
	}

	// Calculate initial momentum scores
	if err := s.calculateMomentumScores(); err != nil {
		return fmt.Errorf("failed to calculate momentum: %w", err)
	}

	// Set next rebalance time
	s.lastRebalance = time.Now()
	s.nextRebalance = s.getNextRebalanceDate()

	s.logger.Printf("Momentum rotation initialized with %d assets, rebalancing every %d days",
		len(s.Basket), s.RebalanceDays)
	s.logger.Printf("Current top performers: %v", s.getTopPerformers())
	
	return nil
}

// syncHoldings syncs current portfolio positions
func (s *MomentumRotationStrategy) syncHoldings() error {
	positions, err := s.tradingClient.GetPositions()
	if err != nil {
		return err
	}

	account, err := s.tradingClient.GetAccount()
	if err != nil {
		return err
	}

	equity, _ := account.Equity.Float64()
	s.currentEquity = equity

	s.mu.Lock()
	defer s.mu.Unlock()

	s.currentHoldings = make(map[string]float64)
	
	for _, pos := range positions {
		// Check if position is in our basket
		for _, symbol := range s.Basket {
			if pos.Symbol == symbol {
				marketValue, _ := pos.MarketValue.Float64()
				weight := marketValue / equity
				s.currentHoldings[symbol] = weight
				s.logger.Printf("Found holding: %s (%.2f%%)", symbol, weight*100)
				break
			}
		}
	}

	return nil
}

// calculateMomentumScores calculates ROC for all assets
func (s *MomentumRotationStrategy) calculateMomentumScores() error {
	end := time.Now()
	start := end.AddDate(0, 0, -(s.LookbackDays + 20)) // Extra for volatility calc

	s.mu.Lock()
	defer s.mu.Unlock()

	s.momentumScores = make(map[string]float64)
	
	// Calculate momentum for each asset
	for _, symbol := range s.Basket {
		barsReq := marketdata.GetBarsRequest{
			TimeFrame: marketdata.OneDay,
			Start:     start,
			End:       end,
			PageLimit: int(s.LookbackDays + 20),
		}

		bars, err := s.dataClient.GetBars(symbol, barsReq)
		if err != nil {
			s.logger.Printf("Failed to get bars for %s: %v", symbol, err)
			continue
		}

		if len(bars) < s.LookbackDays {
			s.logger.Printf("Insufficient data for %s: %d bars", symbol, len(bars))
			continue
		}

		// Calculate Rate of Change (ROC)
		startIdx := len(bars) - s.LookbackDays
		startPrice := bars[startIdx].Close
		endPrice := bars[len(bars)-1].Close
		
		roc := ((endPrice - startPrice) / startPrice) * 100
		
		// Calculate risk-adjusted momentum (simplified Sharpe)
		returns := []float64{}
		for i := startIdx + 1; i < len(bars); i++ {
			dayReturn := (bars[i].Close - bars[i-1].Close) / bars[i-1].Close
			returns = append(returns, dayReturn)
		}
		
		avgReturn := s.mean(returns)
		stdDev := s.stdDev(returns)
		
		sharpe := 0.0
		if stdDev > 0 {
			sharpe = (avgReturn * 252) / (stdDev * math.Sqrt(252)) // Annualized
		}
		
		// Combine ROC with risk adjustment
		// Higher weight to ROC but penalize high volatility
		score := roc
		if sharpe < 0 {
			score *= 0.8 // Penalize negative Sharpe
		}
		
		s.momentumScores[symbol] = score
		
		s.logger.Printf("%s: ROC=%.2f%%, Sharpe=%.2f, Score=%.2f",
			symbol, roc, sharpe, score)
	}

	// Add benchmark tracking (SPY)
	s.calculateBenchmarkReturn()

	return nil
}

// calculateBenchmarkReturn tracks SPY performance for comparison
func (s *MomentumRotationStrategy) calculateBenchmarkReturn() {
	end := time.Now()
	start := s.lastRebalance

	barsReq := marketdata.GetBarsRequest{
		TimeFrame: marketdata.OneDay,
		Start:     start,
		End:       end,
		PageLimit: 100,
	}

	bars, err := s.dataClient.GetBars("SPY", barsReq)
	if err != nil {
		return
	}

	if len(bars) >= 2 {
		startPrice := bars[0].Close
		endPrice := bars[len(bars)-1].Close
		s.benchmarkReturn = ((endPrice - startPrice) / startPrice) * 100
	}
}

// getTopPerformers returns the top N performing assets
func (s *MomentumRotationStrategy) getTopPerformers() []AssetMomentum {
	s.mu.RLock()
	defer s.mu.RUnlock()

	// Create sorted list
	assets := []AssetMomentum{}
	for symbol, score := range s.momentumScores {
		// Apply minimum momentum filter
		if score >= s.MinMomentum {
			assets = append(assets, AssetMomentum{
				Symbol: symbol,
				ROC:    score,
			})
		}
	}

	// Sort by momentum score (descending)
	sort.Slice(assets, func(i, j int) bool {
		return assets[i].ROC > assets[j].ROC
	})

	// Return top N
	topN := s.TopN
	if len(assets) < topN {
		topN = len(assets)
	}

	// If no assets meet criteria, use cash proxy
	if topN == 0 && s.UseCashProxy {
		return []AssetMomentum{{Symbol: s.CashProxy, ROC: 0}}
	}

	return assets[:topN]
}

// getNextRebalanceDate calculates the next rebalance date
func (s *MomentumRotationStrategy) getNextRebalanceDate() time.Time {
	// First trading day of next month
	now := time.Now()
	
	// Move to first day of next month
	nextMonth := time.Date(now.Year(), now.Month()+1, 1, 9, 30, 0, 0, time.UTC)
	
	// If it's a weekend, move to Monday
	for nextMonth.Weekday() == time.Saturday || nextMonth.Weekday() == time.Sunday {
		nextMonth = nextMonth.AddDate(0, 0, 1)
	}
	
	return nextMonth
}

// ProcessBar handles new price data (called less frequently for this strategy)
func (s *MomentumRotationStrategy) ProcessBar(price float64, timestamp time.Time) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Check if it's time to rebalance
	if timestamp.After(s.nextRebalance) || 
	   timestamp.Sub(s.lastRebalance) >= time.Duration(s.RebalanceDays)*24*time.Hour {
		s.logger.Printf("Rebalance triggered at %s", timestamp.Format("2006-01-02"))
		go s.rebalance()
		
		s.lastRebalance = timestamp
		s.nextRebalance = s.getNextRebalanceDate()
	}
}

// rebalance performs the monthly portfolio rotation
func (s *MomentumRotationStrategy) rebalance() {
	s.logger.Println("Starting portfolio rebalance...")
	
	// Recalculate momentum scores
	if err := s.calculateMomentumScores(); err != nil {
		s.logger.Printf("Failed to calculate momentum: %v", err)
		return
	}

	// Get top performers
	topAssets := s.getTopPerformers()
	
	if len(topAssets) == 0 {
		s.logger.Println("No assets meet momentum criteria, moving to cash")
		s.liquidateAll()
		return
	}

	// Get account info
	account, err := s.tradingClient.GetAccount()
	if err != nil {
		s.logger.Printf("Failed to get account: %v", err)
		return
	}

	equity, _ := account.Equity.Float64()
	s.currentEquity = equity
	
	// Calculate target weights (equal weight for simplicity)
	targetWeight := 1.0 / float64(len(topAssets))
	targetAllocations := make(map[string]float64)
	
	for _, asset := range topAssets {
		targetAllocations[asset.Symbol] = targetWeight
	}

	s.logger.Printf("Target allocations: %v", targetAllocations)

	// Get current positions
	positions, err := s.tradingClient.GetPositions()
	if err != nil {
		s.logger.Printf("Failed to get positions: %v", err)
		return
	}

	// Calculate current allocations
	currentAllocations := make(map[string]float64)
	for _, pos := range positions {
		marketValue, _ := pos.MarketValue.Float64()
		currentAllocations[pos.Symbol] = marketValue / equity
	}

	// Calculate turnover
	turnover := s.calculateTurnover(currentAllocations, targetAllocations)
	s.turnover = (s.turnover*float64(s.rebalanceCount) + turnover) / float64(s.rebalanceCount+1)

	// Execute rebalancing trades
	s.executeTrades(targetAllocations, currentAllocations, equity)
	
	// Update holdings
	s.currentHoldings = targetAllocations
	s.rebalanceCount++
	s.totalRebalances++
	
	// Log performance
	totalReturn := ((s.currentEquity - s.startEquity) / s.startEquity) * 100
	s.logger.Printf("Rebalance #%d complete. Portfolio return: %.2f%%, Benchmark: %.2f%%",
		s.rebalanceCount, totalReturn, s.benchmarkReturn)
}

// calculateTurnover calculates portfolio turnover percentage
func (s *MomentumRotationStrategy) calculateTurnover(current, target map[string]float64) float64 {
	turnover := 0.0
	
	// Sum absolute differences
	allSymbols := make(map[string]bool)
	for sym := range current {
		allSymbols[sym] = true
	}
	for sym := range target {
		allSymbols[sym] = true
	}
	
	for sym := range allSymbols {
		currWeight := current[sym]
		targWeight := target[sym]
		turnover += math.Abs(targWeight - currWeight)
	}
	
	return turnover / 2 // Divide by 2 since buys and sells are counted
}

// executeTrades places orders to rebalance the portfolio
func (s *MomentumRotationStrategy) executeTrades(target, current map[string]float64, equity float64) {
	// First, close positions not in target
	for symbol, currWeight := range current {
		if targetWeight, exists := target[symbol]; !exists || targetWeight == 0 {
			s.logger.Printf("Closing position: %s (%.2f%%)", symbol, currWeight*100)
			
			// Get position quantity
			positions, _ := s.tradingClient.GetPositions()
			for _, pos := range positions {
				if pos.Symbol == symbol {
					orderReq := alpaca.PlaceOrderRequest{
						Symbol:      symbol,
						Qty:         &[]decimal.Decimal{pos.Qty}[0],
						Side:        alpaca.Sell,
						Type:        alpaca.Market,
						TimeInForce: alpaca.Day,
					}
					
					if _, err := s.tradingClient.PlaceOrder(orderReq); err != nil {
						s.logger.Printf("Failed to close %s: %v", symbol, err)
					}
					break
				}
			}
		}
	}

	// Wait for sells to complete
	time.Sleep(5 * time.Second)

	// Then, adjust or open positions in target
	for symbol, targetWeight := range target {
		currWeight := current[symbol]
		diff := targetWeight - currWeight
		
		if math.Abs(diff) < 0.01 { // Skip small adjustments (<1%)
			continue
		}

		// Get current price
		quote, err := s.dataClient.GetLatestQuote(symbol, marketdata.GetLatestQuoteRequest{})
		if err != nil {
			s.logger.Printf("Failed to get quote for %s: %v", symbol, err)
			continue
		}

		price := quote.AskPrice
		if price == 0 {
			price = quote.BidPrice
		}

		// Calculate target quantity
		targetValue := equity * targetWeight
		targetQty := int64(math.Floor(targetValue / price))

		// Get current quantity
		var currentQty int64
		positions, _ := s.tradingClient.GetPositions()
		for _, pos := range positions {
			if pos.Symbol == symbol {
				currentQty = pos.Qty.BigInt().Int64()
				break
			}
		}

		qtyDiff := targetQty - currentQty
		
		if qtyDiff == 0 {
			continue
		}

		// Place order
		var side alpaca.Side
		var qty int64
		
		if qtyDiff > 0 {
			side = alpaca.Buy
			qty = qtyDiff
			s.logger.Printf("Buying %d shares of %s (target: %.2f%%)", qty, symbol, targetWeight*100)
		} else {
			side = alpaca.Sell
			qty = -qtyDiff
			s.logger.Printf("Selling %d shares of %s (target: %.2f%%)", qty, symbol, targetWeight*100)
		}

		orderReq := alpaca.PlaceOrderRequest{
			Symbol:      symbol,
			Qty:         &[]decimal.Decimal{decimal.NewFromInt(qty)}[0],
			Side:        side,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
		}

		if _, err := s.tradingClient.PlaceOrder(orderReq); err != nil {
			s.logger.Printf("Failed to place order for %s: %v", symbol, err)
		}
	}

	s.logger.Println("Trade execution complete")
}

// liquidateAll closes all positions (defensive mode)
func (s *MomentumRotationStrategy) liquidateAll() {
	positions, err := s.tradingClient.GetPositions()
	if err != nil {
		s.logger.Printf("Failed to get positions: %v", err)
		return
	}

	for _, pos := range positions {
		orderReq := alpaca.PlaceOrderRequest{
			Symbol:      pos.Symbol,
			Qty:         &[]decimal.Decimal{pos.Qty}[0],
			Side:        alpaca.Sell,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
		}

		if _, err := s.tradingClient.PlaceOrder(orderReq); err != nil {
			s.logger.Printf("Failed to liquidate %s: %v", pos.Symbol, err)
		} else {
			s.logger.Printf("Liquidated position: %s", pos.Symbol)
		}
	}

	// Optionally buy cash proxy
	if s.UseCashProxy {
		account, _ := s.tradingClient.GetAccount()
		cash, _ := account.Cash.Float64()
		
		quote, err := s.dataClient.GetLatestQuote(s.CashProxy, marketdata.GetLatestQuoteRequest{})
		if err == nil {
			price := quote.AskPrice
			qty := int64(math.Floor(cash * 0.95 / price)) // Use 95% of cash
			
			orderReq := alpaca.PlaceOrderRequest{
				Symbol:      s.CashProxy,
				Qty:         &[]decimal.Decimal{decimal.NewFromInt(qty)}[0],
				Side:        alpaca.Buy,
				Type:        alpaca.Market,
				TimeInForce: alpaca.Day,
			}

			if _, err := s.tradingClient.PlaceOrder(orderReq); err != nil {
				s.logger.Printf("Failed to buy cash proxy %s: %v", s.CashProxy, err)
			} else {
				s.logger.Printf("Moved to cash proxy: %s", s.CashProxy)
			}
		}
	}
}

// Helper functions
func (s *MomentumRotationStrategy) mean(values []float64) float64 {
	if len(values) == 0 {
		return 0
	}
	sum := 0.0
	for _, v := range values {
		sum += v
	}
	return sum / float64(len(values))
}

func (s *MomentumRotationStrategy) stdDev(values []float64) float64 {
	if len(values) == 0 {
		return 0
	}
	avg := s.mean(values)
	variance := 0.0
	for _, v := range values {
		variance += math.Pow(v-avg, 2)
	}
	return math.Sqrt(variance / float64(len(values)))
}

// GetStatistics returns strategy performance metrics
func (s *MomentumRotationStrategy) GetStatistics() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()

	totalReturn := 0.0
	if s.startEquity > 0 {
		totalReturn = ((s.currentEquity - s.startEquity) / s.startEquity) * 100
	}

	outperformance := totalReturn - s.benchmarkReturn

	// Get current top performers
	top := []string{}
	for _, asset := range s.getTopPerformers() {
		top = append(top, fmt.Sprintf("%s(%.1f%%)", asset.Symbol, asset.ROC))
	}

	return map[string]interface{}{
		"symbol":           fmt.Sprintf("Basket(%d)", len(s.Basket)),
		"strategy":         "Momentum Rotation",
		"lookback_days":    s.LookbackDays,
		"top_n":            s.TopN,
		"rebalances":       s.rebalanceCount,
		"total_return":     totalReturn,
		"benchmark_return": s.benchmarkReturn,
		"outperformance":   outperformance,
		"avg_turnover":     s.turnover * 100,
		"current_holdings": s.currentHoldings,
		"top_performers":   top,
		"next_rebalance":   s.nextRebalance.Format("2006-01-02"),
	}
}

// Run starts the strategy main loop
func (s *MomentumRotationStrategy) Run(ctx context.Context) error {
	// For momentum rotation, we don't need real-time streaming
	// Just check daily for rebalance dates
	
	s.logger.Printf("Momentum rotation strategy running with %d assets", len(s.Basket))
	s.logger.Printf("Next rebalance: %s", s.nextRebalance.Format("2006-01-02"))

	// Daily check ticker
	ticker := time.NewTicker(24 * time.Hour)
	defer ticker.Stop()

	// Statistics ticker
	statsTicker := time.NewTicker(7 * 24 * time.Hour) // Weekly stats
	defer statsTicker.Stop()

	for {
		select {
		case <-ctx.Done():
			// Print final statistics
			stats := s.GetStatistics()
			s.logger.Printf("Final Statistics: %+v", stats)
			return nil

		case <-ticker.C:
			// Check if it's time to rebalance
			now := time.Now()
			if now.After(s.nextRebalance) {
				s.logger.Println("Rebalance day reached")
				s.rebalance()
				s.nextRebalance = s.getNextRebalanceDate()
			}

		case <-statsTicker.C:
			// Print periodic statistics
			stats := s.GetStatistics()
			s.logger.Printf("Weekly Statistics: %+v", stats)
		}
	}
}