package backtesting

import (
	"fmt"
	"log"
	"math"
	"sort"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
)

// BacktestStrategy interface that all strategies must implement for backtesting
type BacktestStrategy interface {
	ProcessBar(bar Bar, portfolio *Portfolio) Signal
	GetParameters() map[string]interface{}
	Reset() // Reset strategy state for new backtest run
}

// Bar represents a price bar with all necessary data
type Bar struct {
	Time   time.Time
	Open   float64
	High   float64
	Low    float64
	Close  float64
	Volume float64
}

// Signal represents a trading signal
type Signal struct {
	Action   string  // "BUY", "SELL", "HOLD"
	Quantity float64 // Number of shares/units
	Price    float64 // Execution price (0 for market orders)
	StopLoss float64 // Stop loss price
	TakeProfit float64 // Take profit price
}

// Position represents an open position
type Position struct {
	Symbol     string
	Quantity   float64
	EntryPrice float64
	EntryTime  time.Time
	StopLoss   float64
	TakeProfit float64
	CurrentPrice float64
}

// Trade represents a completed trade
type Trade struct {
	Symbol     string
	EntryTime  time.Time
	ExitTime   time.Time
	EntryPrice float64
	ExitPrice  float64
	Quantity   float64
	PnL        float64
	PnLPercent float64
	Duration   time.Duration
	ExitReason string // "SIGNAL", "STOP_LOSS", "TAKE_PROFIT"
}

// Portfolio manages the simulated trading account
type Portfolio struct {
	InitialCapital float64
	Cash          float64
	Equity        float64
	Positions     map[string]*Position
	CompletedTrades []Trade
	OpenTrades    int
	
	// Risk parameters
	MaxPositionSize float64 // Max % of equity per position
	MaxPositions    int     // Max concurrent positions
	Slippage        float64 // Slippage factor (e.g., 0.001 = 0.1%)
	Commission      float64 // Commission per trade
	
	// Performance tracking
	EquityCurve     []float64
	DrawdownCurve   []float64
	MaxDrawdown     float64
	MaxDrawdownPct  float64
	PeakEquity      float64
	CurrentDrawdown float64
	
	// Statistics
	TotalTrades     int
	WinningTrades   int
	LosingTrades    int
	GrossProfit     float64
	GrossLoss       float64
	LargestWin      float64
	LargestLoss     float64
	ConsecutiveWins int
	ConsecutiveLosses int
	MaxConsecutiveWins int
	MaxConsecutiveLosses int
}

// NewPortfolio creates a new portfolio with initial capital
func NewPortfolio(initialCapital float64) *Portfolio {
	return &Portfolio{
		InitialCapital:  initialCapital,
		Cash:            initialCapital,
		Equity:          initialCapital,
		Positions:       make(map[string]*Position),
		CompletedTrades: []Trade{},
		MaxPositionSize: 0.1,   // 10% max per position
		MaxPositions:    5,      // Max 5 concurrent positions
		Slippage:        0.001,  // 0.1% slippage
		Commission:      1.0,    // $1 per trade
		EquityCurve:     []float64{initialCapital},
		PeakEquity:      initialCapital,
	}
}

// Backtester runs backtests on strategies
type Backtester struct {
	Portfolio *Portfolio
	Strategy  BacktestStrategy
	Symbol    string
	StartDate time.Time
	EndDate   time.Time
	TimeFrame marketdata.TimeFrame
	Logger    *log.Logger
	
	// Data
	Bars []Bar
	
	// Results
	Results *BacktestResults
}

// BacktestResults contains comprehensive backtest results
type BacktestResults struct {
	// Basic metrics
	TotalReturn     float64
	AnnualizedReturn float64
	TotalTrades     int
	WinRate         float64
	
	// Risk metrics
	MaxDrawdown     float64
	MaxDrawdownPct  float64
	SharpeRatio     float64
	SortinoRatio    float64
	CalmarRatio     float64
	
	// Trade metrics
	ProfitFactor    float64
	ExpectedValue   float64
	AverageTrade    float64
	AverageWin      float64
	AverageLoss     float64
	LargestWin      float64
	LargestLoss     float64
	
	// Time metrics
	AverageHoldTime time.Duration
	WinningHoldTime time.Duration
	LosingHoldTime  time.Duration
	
	// Consistency metrics
	WinLossRatio    float64
	MaxConsecutiveWins int
	MaxConsecutiveLosses int
	RecoveryFactor  float64
	
	// Monthly returns
	MonthlyReturns  map[string]float64
	
	// Trade distribution
	TradeDistribution []float64
}

// NewBacktester creates a new backtester instance
func NewBacktester(strategy BacktestStrategy, symbol string, start, end time.Time) *Backtester {
	return &Backtester{
		Portfolio: NewPortfolio(100000), // Default $100k starting capital
		Strategy:  strategy,
		Symbol:    symbol,
		StartDate: start,
		EndDate:   end,
		TimeFrame: marketdata.OneDay,
		Logger:    log.New(log.Writer(), "[BACKTEST] ", log.LstdFlags),
		Bars:      []Bar{},
	}
}

// LoadData fetches historical data from Alpaca
func (b *Backtester) LoadData(dataClient *marketdata.Client) error {
	barsReq := marketdata.GetBarsRequest{
		TimeFrame: b.TimeFrame,
		Start:     b.StartDate,
		End:       b.EndDate,
		PageLimit: 10000,
	}

	bars, err := dataClient.GetBars(b.Symbol, barsReq)
	if err != nil {
		return fmt.Errorf("failed to load data: %w", err)
	}

	b.Bars = []Bar{}
	for _, bar := range bars {
		b.Bars = append(b.Bars, Bar{
			Time:   bar.Timestamp,
			Open:   bar.Open,
			High:   bar.High,
			Low:    bar.Low,
			Close:  bar.Close,
			Volume: float64(bar.Volume),
		})
	}

	b.Logger.Printf("Loaded %d bars for %s from %s to %s",
		len(b.Bars), b.Symbol, b.StartDate.Format("2006-01-02"), b.EndDate.Format("2006-01-02"))
	
	return nil
}

// Run executes the backtest
func (b *Backtester) Run() error {
	if len(b.Bars) == 0 {
		return fmt.Errorf("no data loaded")
	}

	b.Logger.Printf("Starting backtest for %s using %T strategy", b.Symbol, b.Strategy)
	b.Strategy.Reset()
	
	for _, bar := range b.Bars {
		// Update position prices
		b.updatePositions(bar)
		
		// Check stop losses and take profits
		b.checkExits(bar)
		
		// Get signal from strategy
		signal := b.Strategy.ProcessBar(bar, b.Portfolio)
		
		// Execute signal
		if signal.Action != "HOLD" {
			b.executeSignal(signal, bar)
		}
		
		// Update portfolio equity
		b.updateEquity(bar)
		
		// Track equity curve
		b.Portfolio.EquityCurve = append(b.Portfolio.EquityCurve, b.Portfolio.Equity)
		
		// Update drawdown
		b.updateDrawdown()
	}
	
	// Close any remaining positions at end
	b.closeAllPositions(b.Bars[len(b.Bars)-1])
	
	// Calculate results
	b.Results = b.calculateResults()
	
	return nil
}

// updatePositions updates current prices for all positions
func (b *Backtester) updatePositions(bar Bar) {
	for _, pos := range b.Portfolio.Positions {
		pos.CurrentPrice = bar.Close
	}
}

// checkExits checks and executes stop losses and take profits
func (b *Backtester) checkExits(bar Bar) {
	for symbol, pos := range b.Portfolio.Positions {
		exitReason := ""
		exitPrice := 0.0
		
		// Check stop loss
		if pos.StopLoss > 0 && bar.Low <= pos.StopLoss {
			exitReason = "STOP_LOSS"
			exitPrice = pos.StopLoss
		}
		
		// Check take profit
		if pos.TakeProfit > 0 && bar.High >= pos.TakeProfit {
			exitReason = "TAKE_PROFIT"
			exitPrice = pos.TakeProfit
		}
		
		if exitReason != "" {
			b.closePosition(symbol, exitPrice, bar.Time, exitReason)
		}
	}
}

// executeSignal processes a trading signal
func (b *Backtester) executeSignal(signal Signal, bar Bar) {
	if signal.Action == "BUY" {
		// Check if we can open a new position
		if len(b.Portfolio.Positions) >= b.Portfolio.MaxPositions {
			return // Max positions reached
		}
		
		// Calculate position size
		positionSize := b.Portfolio.Equity * b.Portfolio.MaxPositionSize
		executionPrice := bar.Close * (1 + b.Portfolio.Slippage)
		quantity := math.Floor(positionSize / executionPrice)
		
		if quantity <= 0 {
			return // Position too small
		}
		
		cost := quantity * executionPrice + b.Portfolio.Commission
		if cost > b.Portfolio.Cash {
			// Adjust quantity for available cash
			quantity = math.Floor((b.Portfolio.Cash - b.Portfolio.Commission) / executionPrice)
			if quantity <= 0 {
				return // Insufficient cash
			}
			cost = quantity * executionPrice + b.Portfolio.Commission
		}
		
		// Open position
		b.Portfolio.Positions[b.Symbol] = &Position{
			Symbol:     b.Symbol,
			Quantity:   quantity,
			EntryPrice: executionPrice,
			EntryTime:  bar.Time,
			StopLoss:   signal.StopLoss,
			TakeProfit: signal.TakeProfit,
			CurrentPrice: executionPrice,
		}
		
		b.Portfolio.Cash -= cost
		b.Portfolio.OpenTrades++
		
	} else if signal.Action == "SELL" {
		if _, exists := b.Portfolio.Positions[b.Symbol]; exists {
			executionPrice := bar.Close * (1 - b.Portfolio.Slippage)
			b.closePosition(b.Symbol, executionPrice, bar.Time, "SIGNAL")
		}
	}
}

// closePosition closes a position and records the trade
func (b *Backtester) closePosition(symbol string, exitPrice float64, exitTime time.Time, exitReason string) {
	pos, exists := b.Portfolio.Positions[symbol]
	if !exists {
		return
	}
	
	// Calculate P&L
	proceeds := pos.Quantity * exitPrice - b.Portfolio.Commission
	cost := pos.Quantity * pos.EntryPrice + b.Portfolio.Commission
	pnl := proceeds - cost
	pnlPercent := (pnl / cost) * 100
	
	// Record trade
	trade := Trade{
		Symbol:     symbol,
		EntryTime:  pos.EntryTime,
		ExitTime:   exitTime,
		EntryPrice: pos.EntryPrice,
		ExitPrice:  exitPrice,
		Quantity:   pos.Quantity,
		PnL:        pnl,
		PnLPercent: pnlPercent,
		Duration:   exitTime.Sub(pos.EntryTime),
		ExitReason: exitReason,
	}
	
	b.Portfolio.CompletedTrades = append(b.Portfolio.CompletedTrades, trade)
	b.Portfolio.Cash += proceeds
	b.Portfolio.TotalTrades++
	
	// Update statistics
	if pnl > 0 {
		b.Portfolio.WinningTrades++
		b.Portfolio.GrossProfit += pnl
		b.Portfolio.ConsecutiveWins++
		b.Portfolio.ConsecutiveLosses = 0
		if b.Portfolio.ConsecutiveWins > b.Portfolio.MaxConsecutiveWins {
			b.Portfolio.MaxConsecutiveWins = b.Portfolio.ConsecutiveWins
		}
		if pnl > b.Portfolio.LargestWin {
			b.Portfolio.LargestWin = pnl
		}
	} else {
		b.Portfolio.LosingTrades++
		b.Portfolio.GrossLoss += math.Abs(pnl)
		b.Portfolio.ConsecutiveLosses++
		b.Portfolio.ConsecutiveWins = 0
		if b.Portfolio.ConsecutiveLosses > b.Portfolio.MaxConsecutiveLosses {
			b.Portfolio.MaxConsecutiveLosses = b.Portfolio.ConsecutiveLosses
		}
		if pnl < b.Portfolio.LargestLoss {
			b.Portfolio.LargestLoss = pnl
		}
	}
	
	// Remove position
	delete(b.Portfolio.Positions, symbol)
	b.Portfolio.OpenTrades--
}

// closeAllPositions closes all open positions
func (b *Backtester) closeAllPositions(lastBar Bar) {
	for symbol := range b.Portfolio.Positions {
		b.closePosition(symbol, lastBar.Close, lastBar.Time, "END_OF_BACKTEST")
	}
}

// updateEquity calculates current portfolio equity
func (b *Backtester) updateEquity(bar Bar) {
	positionValue := 0.0
	for _, pos := range b.Portfolio.Positions {
		positionValue += pos.Quantity * bar.Close
	}
	b.Portfolio.Equity = b.Portfolio.Cash + positionValue
}

// updateDrawdown tracks drawdown metrics
func (b *Backtester) updateDrawdown() {
	if b.Portfolio.Equity > b.Portfolio.PeakEquity {
		b.Portfolio.PeakEquity = b.Portfolio.Equity
		b.Portfolio.CurrentDrawdown = 0
	} else {
		b.Portfolio.CurrentDrawdown = b.Portfolio.PeakEquity - b.Portfolio.Equity
		drawdownPct := (b.Portfolio.CurrentDrawdown / b.Portfolio.PeakEquity) * 100
		
		if b.Portfolio.CurrentDrawdown > b.Portfolio.MaxDrawdown {
			b.Portfolio.MaxDrawdown = b.Portfolio.CurrentDrawdown
			b.Portfolio.MaxDrawdownPct = drawdownPct
		}
		
		b.Portfolio.DrawdownCurve = append(b.Portfolio.DrawdownCurve, drawdownPct)
	}
}

// calculateResults computes comprehensive backtest metrics
func (b *Backtester) calculateResults() *BacktestResults {
	results := &BacktestResults{
		MonthlyReturns: make(map[string]float64),
	}
	
	if b.Portfolio.TotalTrades == 0 {
		return results
	}
	
	// Basic metrics
	results.TotalReturn = ((b.Portfolio.Equity - b.Portfolio.InitialCapital) / b.Portfolio.InitialCapital) * 100
	
	// Annualized return
	years := b.EndDate.Sub(b.StartDate).Hours() / 24 / 365
	if years > 0 {
		results.AnnualizedReturn = math.Pow(b.Portfolio.Equity/b.Portfolio.InitialCapital, 1/years) - 1
		results.AnnualizedReturn *= 100
	}
	
	results.TotalTrades = b.Portfolio.TotalTrades
	if b.Portfolio.TotalTrades > 0 {
		results.WinRate = float64(b.Portfolio.WinningTrades) / float64(b.Portfolio.TotalTrades) * 100
	}
	
	// Risk metrics
	results.MaxDrawdown = b.Portfolio.MaxDrawdown
	results.MaxDrawdownPct = b.Portfolio.MaxDrawdownPct
	
	// Calculate Sharpe ratio
	results.SharpeRatio = b.calculateSharpeRatio()
	
	// Calculate Sortino ratio
	results.SortinoRatio = b.calculateSortinoRatio()
	
	// Calmar ratio
	if b.Portfolio.MaxDrawdownPct > 0 {
		results.CalmarRatio = results.AnnualizedReturn / b.Portfolio.MaxDrawdownPct
	}
	
	// Trade metrics
	if b.Portfolio.GrossLoss > 0 {
		results.ProfitFactor = b.Portfolio.GrossProfit / b.Portfolio.GrossLoss
	} else if b.Portfolio.GrossProfit > 0 {
		results.ProfitFactor = math.Inf(1)
	}
	
	// Average metrics
	totalPnL := b.Portfolio.GrossProfit - b.Portfolio.GrossLoss
	results.AverageTrade = totalPnL / float64(b.Portfolio.TotalTrades)
	results.ExpectedValue = results.AverageTrade
	
	if b.Portfolio.WinningTrades > 0 {
		results.AverageWin = b.Portfolio.GrossProfit / float64(b.Portfolio.WinningTrades)
	}
	
	if b.Portfolio.LosingTrades > 0 {
		results.AverageLoss = -b.Portfolio.GrossLoss / float64(b.Portfolio.LosingTrades)
	}
	
	results.LargestWin = b.Portfolio.LargestWin
	results.LargestLoss = b.Portfolio.LargestLoss
	
	// Time metrics
	results.AverageHoldTime = b.calculateAverageHoldTime()
	results.WinningHoldTime = b.calculateWinningHoldTime()
	results.LosingHoldTime = b.calculateLosingHoldTime()
	
	// Consistency metrics
	if results.AverageLoss != 0 {
		results.WinLossRatio = results.AverageWin / math.Abs(results.AverageLoss)
	}
	
	results.MaxConsecutiveWins = b.Portfolio.MaxConsecutiveWins
	results.MaxConsecutiveLosses = b.Portfolio.MaxConsecutiveLosses
	
	if b.Portfolio.MaxDrawdown > 0 {
		results.RecoveryFactor = totalPnL / b.Portfolio.MaxDrawdown
	}
	
	// Monthly returns
	b.calculateMonthlyReturns(results)
	
	// Trade distribution
	results.TradeDistribution = b.calculateTradeDistribution()
	
	return results
}

// calculateSharpeRatio computes the Sharpe ratio
func (b *Backtester) calculateSharpeRatio() float64 {
	if len(b.Portfolio.EquityCurve) < 2 {
		return 0
	}
	
	// Calculate daily returns
	returns := []float64{}
	for i := 1; i < len(b.Portfolio.EquityCurve); i++ {
		ret := (b.Portfolio.EquityCurve[i] - b.Portfolio.EquityCurve[i-1]) / b.Portfolio.EquityCurve[i-1]
		returns = append(returns, ret)
	}
	
	// Calculate mean and std dev
	mean := 0.0
	for _, r := range returns {
		mean += r
	}
	mean /= float64(len(returns))
	
	variance := 0.0
	for _, r := range returns {
		variance += math.Pow(r-mean, 2)
	}
	stdDev := math.Sqrt(variance / float64(len(returns)))
	
	if stdDev == 0 {
		return 0
	}
	
	// Annualize (assuming daily data)
	annualizedReturn := mean * 252
	annualizedStdDev := stdDev * math.Sqrt(252)
	
	// Risk-free rate (assume 2%)
	riskFreeRate := 0.02
	
	return (annualizedReturn - riskFreeRate) / annualizedStdDev
}

// calculateSortinoRatio computes the Sortino ratio (uses downside deviation)
func (b *Backtester) calculateSortinoRatio() float64 {
	if len(b.Portfolio.EquityCurve) < 2 {
		return 0
	}
	
	// Calculate daily returns
	returns := []float64{}
	for i := 1; i < len(b.Portfolio.EquityCurve); i++ {
		ret := (b.Portfolio.EquityCurve[i] - b.Portfolio.EquityCurve[i-1]) / b.Portfolio.EquityCurve[i-1]
		returns = append(returns, ret)
	}
	
	// Calculate mean
	mean := 0.0
	for _, r := range returns {
		mean += r
	}
	mean /= float64(len(returns))
	
	// Calculate downside deviation
	downsideVariance := 0.0
	downsideCount := 0
	for _, r := range returns {
		if r < 0 {
			downsideVariance += math.Pow(r, 2)
			downsideCount++
		}
	}
	
	if downsideCount == 0 {
		return math.Inf(1) // No losing days
	}
	
	downsideStdDev := math.Sqrt(downsideVariance / float64(downsideCount))
	
	if downsideStdDev == 0 {
		return 0
	}
	
	// Annualize
	annualizedReturn := mean * 252
	annualizedDownsideDev := downsideStdDev * math.Sqrt(252)
	
	// Risk-free rate (assume 2%)
	riskFreeRate := 0.02
	
	return (annualizedReturn - riskFreeRate) / annualizedDownsideDev
}

// calculateAverageHoldTime computes average position hold time
func (b *Backtester) calculateAverageHoldTime() time.Duration {
	if len(b.Portfolio.CompletedTrades) == 0 {
		return 0
	}
	
	totalDuration := time.Duration(0)
	for _, trade := range b.Portfolio.CompletedTrades {
		totalDuration += trade.Duration
	}
	
	return totalDuration / time.Duration(len(b.Portfolio.CompletedTrades))
}

// calculateWinningHoldTime computes average hold time for winning trades
func (b *Backtester) calculateWinningHoldTime() time.Duration {
	totalDuration := time.Duration(0)
	count := 0
	
	for _, trade := range b.Portfolio.CompletedTrades {
		if trade.PnL > 0 {
			totalDuration += trade.Duration
			count++
		}
	}
	
	if count == 0 {
		return 0
	}
	
	return totalDuration / time.Duration(count)
}

// calculateLosingHoldTime computes average hold time for losing trades
func (b *Backtester) calculateLosingHoldTime() time.Duration {
	totalDuration := time.Duration(0)
	count := 0
	
	for _, trade := range b.Portfolio.CompletedTrades {
		if trade.PnL < 0 {
			totalDuration += trade.Duration
			count++
		}
	}
	
	if count == 0 {
		return 0
	}
	
	return totalDuration / time.Duration(count)
}

// calculateMonthlyReturns computes returns by month
func (b *Backtester) calculateMonthlyReturns(results *BacktestResults) {
	monthlyEquity := make(map[string][]float64)
	
	// Group equity by month
	for i, equity := range b.Portfolio.EquityCurve {
		if i < len(b.Bars) {
			month := b.Bars[i].Time.Format("2006-01")
			monthlyEquity[month] = append(monthlyEquity[month], equity)
		}
	}
	
	// Calculate monthly returns
	months := []string{}
	for month := range monthlyEquity {
		months = append(months, month)
	}
	sort.Strings(months)
	
	prevClose := b.Portfolio.InitialCapital
	for _, month := range months {
		values := monthlyEquity[month]
		if len(values) > 0 {
			monthClose := values[len(values)-1]
			monthReturn := ((monthClose - prevClose) / prevClose) * 100
			results.MonthlyReturns[month] = monthReturn
			prevClose = monthClose
		}
	}
}

// calculateTradeDistribution computes P&L distribution
func (b *Backtester) calculateTradeDistribution() []float64 {
	distribution := []float64{}
	for _, trade := range b.Portfolio.CompletedTrades {
		distribution = append(distribution, trade.PnLPercent)
	}
	sort.Float64s(distribution)
	return distribution
}

// PrintResults displays backtest results
func (b *Backtester) PrintResults() {
	if b.Results == nil {
		b.Logger.Println("No results available. Run backtest first.")
		return
	}
	
	r := b.Results
	
	fmt.Println("\n=== BACKTEST RESULTS ===")
	fmt.Printf("Symbol: %s\n", b.Symbol)
	fmt.Printf("Period: %s to %s\n", b.StartDate.Format("2006-01-02"), b.EndDate.Format("2006-01-02"))
	fmt.Printf("Strategy: %T\n", b.Strategy)
	fmt.Printf("Parameters: %v\n", b.Strategy.GetParameters())
	
	fmt.Println("\n--- PERFORMANCE ---")
	fmt.Printf("Total Return: %.2f%%\n", r.TotalReturn)
	fmt.Printf("Annualized Return: %.2f%%\n", r.AnnualizedReturn)
	fmt.Printf("Total Trades: %d\n", r.TotalTrades)
	fmt.Printf("Win Rate: %.2f%%\n", r.WinRate)
	
	fmt.Println("\n--- RISK METRICS ---")
	fmt.Printf("Max Drawdown: $%.2f (%.2f%%)\n", r.MaxDrawdown, r.MaxDrawdownPct)
	fmt.Printf("Sharpe Ratio: %.2f\n", r.SharpeRatio)
	fmt.Printf("Sortino Ratio: %.2f\n", r.SortinoRatio)
	fmt.Printf("Calmar Ratio: %.2f\n", r.CalmarRatio)
	
	fmt.Println("\n--- TRADE METRICS ---")
	fmt.Printf("Profit Factor: %.2f\n", r.ProfitFactor)
	fmt.Printf("Expected Value: $%.2f\n", r.ExpectedValue)
	fmt.Printf("Average Trade: $%.2f\n", r.AverageTrade)
	fmt.Printf("Average Win: $%.2f\n", r.AverageWin)
	fmt.Printf("Average Loss: $%.2f\n", r.AverageLoss)
	fmt.Printf("Largest Win: $%.2f\n", r.LargestWin)
	fmt.Printf("Largest Loss: $%.2f\n", r.LargestLoss)
	
	fmt.Println("\n--- TIME METRICS ---")
	fmt.Printf("Average Hold Time: %v\n", r.AverageHoldTime)
	fmt.Printf("Winning Hold Time: %v\n", r.WinningHoldTime)
	fmt.Printf("Losing Hold Time: %v\n", r.LosingHoldTime)
	
	fmt.Println("\n--- CONSISTENCY ---")
	fmt.Printf("Win/Loss Ratio: %.2f\n", r.WinLossRatio)
	fmt.Printf("Max Consecutive Wins: %d\n", r.MaxConsecutiveWins)
	fmt.Printf("Max Consecutive Losses: %d\n", r.MaxConsecutiveLosses)
	fmt.Printf("Recovery Factor: %.2f\n", r.RecoveryFactor)
	
	fmt.Println("\n--- MONTHLY RETURNS ---")
	months := []string{}
	for month := range r.MonthlyReturns {
		months = append(months, month)
	}
	sort.Strings(months)
	
	for _, month := range months {
		fmt.Printf("%s: %+.2f%%\n", month, r.MonthlyReturns[month])
	}
	
	fmt.Println("\n========================")
}