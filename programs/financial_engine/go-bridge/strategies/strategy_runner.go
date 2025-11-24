package strategies

import (
	"context"
	"fmt"
	"log"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"
)

// StrategyRunner manages multiple trading strategies concurrently
type StrategyRunner struct {
	strategies []Strategy
	wg         sync.WaitGroup
	logger     *log.Logger
	ctx        context.Context
	cancel     context.CancelFunc
}

// Strategy interface that all strategies must implement
type Strategy interface {
	Initialize(apiKey, apiSecret, baseURL string) error
	Run(ctx context.Context) error
	GetStatistics() map[string]interface{}
}

// NewStrategyRunner creates a new strategy runner
func NewStrategyRunner() *StrategyRunner {
	ctx, cancel := context.WithCancel(context.Background())
	return &StrategyRunner{
		strategies: make([]Strategy, 0),
		logger:     log.New(log.Writer(), "[RUNNER] ", log.LstdFlags),
		ctx:        ctx,
		cancel:     cancel,
	}
}

// AddStrategy adds a strategy to the runner
func (r *StrategyRunner) AddStrategy(strategy Strategy) {
	r.strategies = append(r.strategies, strategy)
	r.logger.Printf("Added strategy: %T", strategy)
}

// Initialize all strategies
func (r *StrategyRunner) Initialize() error {
	// Get API credentials from environment
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	baseURL := os.Getenv("APCA_API_BASE_URL")

	if apiKey == "" || apiSecret == "" {
		return fmt.Errorf("missing API credentials in environment")
	}

	if baseURL == "" {
		baseURL = "https://paper-api.alpaca.markets" // Default to paper trading
		r.logger.Printf("Using default paper trading URL: %s", baseURL)
	}

	// Initialize each strategy
	for _, strategy := range r.strategies {
		if err := strategy.Initialize(apiKey, apiSecret, baseURL); err != nil {
			return fmt.Errorf("failed to initialize strategy %T: %w", strategy, err)
		}
	}

	r.logger.Printf("Initialized %d strategies", len(r.strategies))
	return nil
}

// Run starts all strategies concurrently
func (r *StrategyRunner) Run() error {
	if len(r.strategies) == 0 {
		return fmt.Errorf("no strategies to run")
	}

	// Setup signal handling for graceful shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	// Start each strategy in its own goroutine
	for _, strategy := range r.strategies {
		r.wg.Add(1)
		go func(s Strategy) {
			defer r.wg.Done()
			
			r.logger.Printf("Starting strategy: %T", s)
			if err := s.Run(r.ctx); err != nil {
				r.logger.Printf("Strategy %T error: %v", s, err)
			}
			r.logger.Printf("Strategy %T stopped", s)
		}(strategy)
	}

	// Start statistics reporter
	go r.reportStatistics()

	// Wait for shutdown signal
	<-sigChan
	r.logger.Println("Shutdown signal received, stopping strategies...")

	// Cancel context to stop all strategies
	r.cancel()

	// Wait for all strategies to finish
	done := make(chan struct{})
	go func() {
		r.wg.Wait()
		close(done)
	}()

	// Wait with timeout
	select {
	case <-done:
		r.logger.Println("All strategies stopped successfully")
	case <-time.After(30 * time.Second):
		r.logger.Println("Timeout waiting for strategies to stop")
	}

	// Print final statistics
	r.printFinalStatistics()

	return nil
}

// reportStatistics periodically logs strategy performance
func (r *StrategyRunner) reportStatistics() {
	ticker := time.NewTicker(5 * time.Minute)
	defer ticker.Stop()

	for {
		select {
		case <-r.ctx.Done():
			return
		case <-ticker.C:
			r.logger.Println("=== Strategy Performance Report ===")
			for _, strategy := range r.strategies {
				stats := strategy.GetStatistics()
				r.logger.Printf("%s: %+v", stats["strategy"], stats)
			}
			r.logger.Println("===================================")
		}
	}
}

// printFinalStatistics prints final performance metrics
func (r *StrategyRunner) printFinalStatistics() {
	r.logger.Println("\n=== FINAL STRATEGY PERFORMANCE ===")
	
	totalTrades := 0
	totalWins := 0
	totalPnL := 0.0

	for _, strategy := range r.strategies {
		stats := strategy.GetStatistics()
		
		r.logger.Printf("\n%s (%s):", stats["strategy"], stats["symbol"])
		r.logger.Printf("  Trades: %v", stats["trades"])
		r.logger.Printf("  Win Rate: %.2f%%", stats["win_rate"])
		r.logger.Printf("  Total P&L: $%.2f", stats["total_pnl"])
		
		// Aggregate statistics
		if trades, ok := stats["trades"].(int); ok {
			totalTrades += trades
		}
		if wins, ok := stats["wins"].(int); ok {
			totalWins += wins
		}
		if pnl, ok := stats["total_pnl"].(float64); ok {
			totalPnL += pnl
		}
	}

	r.logger.Println("\n=== AGGREGATE PERFORMANCE ===")
	r.logger.Printf("Total Strategies: %d", len(r.strategies))
	r.logger.Printf("Total Trades: %d", totalTrades)
	if totalTrades > 0 {
		r.logger.Printf("Overall Win Rate: %.2f%%", float64(totalWins)/float64(totalTrades)*100)
	}
	r.logger.Printf("Total P&L: $%.2f", totalPnL)
	r.logger.Println("===============================")
}