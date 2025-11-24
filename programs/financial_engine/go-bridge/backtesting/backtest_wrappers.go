package backtesting

import (
	"fmt"
	"math"
)

// BacktestWrapper provides a generic wrapper to convert live trading strategies to backtesting strategies
type BacktestWrapper struct {
	strategy interface{}
	symbol   string
	
	// State for backtesting
	position    *Position
	prices      []float64
	indicators  map[string][]float64
	lastSignal  string
	tradeCount  int
	
	// Parameters (will be set via SetParameters)
	parameters map[string]interface{}
}

// RSIBacktestStrategy wraps RSI strategy for backtesting
type RSIBacktestStrategy struct {
	*BacktestWrapper
	rsiPeriod      int
	oversoldLevel  float64
	overboughtLevel float64
	stopLossPct    float64
	takeProfitPct  float64
	useTrendFilter bool
}

func NewRSIBacktestStrategy(symbol string) *RSIBacktestStrategy {
	return &RSIBacktestStrategy{
		BacktestWrapper: &BacktestWrapper{
			symbol:     symbol,
			indicators: make(map[string][]float64),
			parameters: make(map[string]interface{}),
		},
		rsiPeriod:       14,
		oversoldLevel:   30,
		overboughtLevel: 70,
		stopLossPct:     0.05,
		takeProfitPct:   0.10,
		useTrendFilter:  true,
	}
}

func (s *RSIBacktestStrategy) ProcessBar(bar Bar, portfolio *Portfolio) Signal {
	s.prices = append(s.prices, bar.Close)
	
	// Need enough data for RSI calculation
	if len(s.prices) < s.rsiPeriod+1 {
		return Signal{Action: "HOLD"}
	}
	
	// Calculate RSI
	rsi := s.calculateRSI(s.prices, s.rsiPeriod)
	
	// Store RSI in indicators
	if s.indicators["rsi"] == nil {
		s.indicators["rsi"] = make([]float64, 0)
	}
	s.indicators["rsi"] = append(s.indicators["rsi"], rsi)
	
	// Generate trading signal
	signal := Signal{Action: "HOLD"}
	
	// Check for buy signal (oversold)
	if rsi < s.oversoldLevel && s.lastSignal != "BUY" {
		signal.Action = "BUY"
		signal.Quantity = 1 // Will be sized by backtester
		signal.StopLoss = bar.Close * (1 - s.stopLossPct)
		signal.TakeProfit = bar.Close * (1 + s.takeProfitPct)
		s.lastSignal = "BUY"
	}
	
	// Check for sell signal (overbought)
	if rsi > s.overboughtLevel && s.lastSignal != "SELL" {
		signal.Action = "SELL"
		s.lastSignal = "SELL"
	}
	
	return signal
}

func (s *RSIBacktestStrategy) GetParameters() map[string]interface{} {
	return map[string]interface{}{
		"strategy":         "RSI_Mean_Reversion",
		"symbol":          s.symbol,
		"rsi_period":      s.rsiPeriod,
		"oversold_level":  s.oversoldLevel,
		"overbought_level": s.overboughtLevel,
		"stop_loss_pct":   s.stopLossPct,
		"take_profit_pct": s.takeProfitPct,
		"use_trend_filter": s.useTrendFilter,
	}
}

func (s *RSIBacktestStrategy) Reset() {
	s.prices = nil
	s.indicators = make(map[string][]float64)
	s.lastSignal = ""
	s.tradeCount = 0
	s.position = nil
}

func (s *RSIBacktestStrategy) SetParameters(params map[string]interface{}) error {
	if period, ok := params["rsi_period"].(float64); ok {
		s.rsiPeriod = int(period)
	}
	if oversold, ok := params["oversold_level"].(float64); ok {
		s.oversoldLevel = oversold
	}
	if overbought, ok := params["overbought_level"].(float64); ok {
		s.overboughtLevel = overbought
	}
	if stopLoss, ok := params["stop_loss_pct"].(float64); ok {
		s.stopLossPct = stopLoss
	}
	if takeProfit, ok := params["take_profit_pct"].(float64); ok {
		s.takeProfitPct = takeProfit
	}
	if useTrend, ok := params["use_trend_filter"].(bool); ok {
		s.useTrendFilter = useTrend
	}
	s.parameters = params
	return nil
}

// calculateRSI computes RSI indicator
func (s *RSIBacktestStrategy) calculateRSI(prices []float64, period int) float64 {
	if len(prices) < period+1 {
		return 50.0 // Neutral RSI
	}
	
	gains := 0.0
	losses := 0.0
	
	// Calculate initial average gain/loss
	for i := len(prices) - period; i < len(prices); i++ {
		change := prices[i] - prices[i-1]
		if change > 0 {
			gains += change
		} else {
			losses += math.Abs(change)
		}
	}
	
	avgGain := gains / float64(period)
	avgLoss := losses / float64(period)
	
	if avgLoss == 0 {
		return 100.0
	}
	
	rs := avgGain / avgLoss
	rsi := 100 - (100 / (1 + rs))
	
	return rsi
}

// MovingAverageCrossoverBacktestStrategy wraps MA Crossover strategy
type MovingAverageCrossoverBacktestStrategy struct {
	*BacktestWrapper
	shortPeriod   int
	longPeriod    int
	stopLossPct   float64
	takeProfitPct float64
}

func NewMovingAverageCrossoverBacktestStrategy(symbol string) *MovingAverageCrossoverBacktestStrategy {
	return &MovingAverageCrossoverBacktestStrategy{
		BacktestWrapper: &BacktestWrapper{
			symbol:     symbol,
			indicators: make(map[string][]float64),
			parameters: make(map[string]interface{}),
		},
		shortPeriod:   10,
		longPeriod:    20,
		stopLossPct:   0.05,
		takeProfitPct: 0.10,
	}
}

func (s *MovingAverageCrossoverBacktestStrategy) ProcessBar(bar Bar, portfolio *Portfolio) Signal {
	s.prices = append(s.prices, bar.Close)
	
	if len(s.prices) < s.longPeriod {
		return Signal{Action: "HOLD"}
	}
	
	// Calculate moving averages
	shortMA := s.calculateSMA(s.prices, s.shortPeriod)
	longMA := s.calculateSMA(s.prices, s.longPeriod)
	
	// Store MAs in indicators
	if s.indicators["short_ma"] == nil {
		s.indicators["short_ma"] = make([]float64, 0)
		s.indicators["long_ma"] = make([]float64, 0)
	}
	s.indicators["short_ma"] = append(s.indicators["short_ma"], shortMA)
	s.indicators["long_ma"] = append(s.indicators["long_ma"], longMA)
	
	signal := Signal{Action: "HOLD"}
	
	// Golden cross (short MA crosses above long MA)
	if len(s.indicators["short_ma"]) > 1 {
		prevShortMA := s.indicators["short_ma"][len(s.indicators["short_ma"])-2]
		prevLongMA := s.indicators["long_ma"][len(s.indicators["long_ma"])-2]
		
		if prevShortMA <= prevLongMA && shortMA > longMA && s.lastSignal != "BUY" {
			signal.Action = "BUY"
			signal.Quantity = 1
			signal.StopLoss = bar.Close * (1 - s.stopLossPct)
			signal.TakeProfit = bar.Close * (1 + s.takeProfitPct)
			s.lastSignal = "BUY"
		}
		
		// Death cross (short MA crosses below long MA)
		if prevShortMA >= prevLongMA && shortMA < longMA && s.lastSignal != "SELL" {
			signal.Action = "SELL"
			s.lastSignal = "SELL"
		}
	}
	
	return signal
}

func (s *MovingAverageCrossoverBacktestStrategy) GetParameters() map[string]interface{} {
	return map[string]interface{}{
		"strategy":        "Moving_Average_Crossover",
		"symbol":         s.symbol,
		"short_period":   s.shortPeriod,
		"long_period":    s.longPeriod,
		"stop_loss_pct":  s.stopLossPct,
		"take_profit_pct": s.takeProfitPct,
	}
}

func (s *MovingAverageCrossoverBacktestStrategy) Reset() {
	s.prices = nil
	s.indicators = make(map[string][]float64)
	s.lastSignal = ""
	s.tradeCount = 0
	s.position = nil
}

func (s *MovingAverageCrossoverBacktestStrategy) SetParameters(params map[string]interface{}) error {
	if shortPeriod, ok := params["short_period"].(float64); ok {
		s.shortPeriod = int(shortPeriod)
	}
	if longPeriod, ok := params["long_period"].(float64); ok {
		s.longPeriod = int(longPeriod)
	}
	if stopLoss, ok := params["stop_loss_pct"].(float64); ok {
		s.stopLossPct = stopLoss
	}
	if takeProfit, ok := params["take_profit_pct"].(float64); ok {
		s.takeProfitPct = takeProfit
	}
	s.parameters = params
	return nil
}

func (s *MovingAverageCrossoverBacktestStrategy) calculateSMA(prices []float64, period int) float64 {
	if len(prices) < period {
		return prices[len(prices)-1] // Return last price if insufficient data
	}
	
	sum := 0.0
	start := len(prices) - period
	for i := start; i < len(prices); i++ {
		sum += prices[i]
	}
	return sum / float64(period)
}

// BollingerBandsBacktestStrategy wraps Bollinger Bands strategy
type BollingerBandsBacktestStrategy struct {
	*BacktestWrapper
	period        int
	numStdDev     float64
	stopLossPct   float64
	takeProfitPct float64
}

func NewBollingerBandsBacktestStrategy(symbol string) *BollingerBandsBacktestStrategy {
	return &BollingerBandsBacktestStrategy{
		BacktestWrapper: &BacktestWrapper{
			symbol:     symbol,
			indicators: make(map[string][]float64),
			parameters: make(map[string]interface{}),
		},
		period:        20,
		numStdDev:     2.0,
		stopLossPct:   0.05,
		takeProfitPct: 0.10,
	}
}

func (s *BollingerBandsBacktestStrategy) ProcessBar(bar Bar, portfolio *Portfolio) Signal {
	s.prices = append(s.prices, bar.Close)
	
	if len(s.prices) < s.period {
		return Signal{Action: "HOLD"}
	}
	
	// Calculate Bollinger Bands
	sma := s.calculateSMA(s.prices, s.period)
	stdDev := s.calculateStdDev(s.prices, s.period, sma)
	upperBand := sma + (s.numStdDev * stdDev)
	lowerBand := sma - (s.numStdDev * stdDev)
	
	// Store indicators
	if s.indicators["sma"] == nil {
		s.indicators["sma"] = make([]float64, 0)
		s.indicators["upper_band"] = make([]float64, 0)
		s.indicators["lower_band"] = make([]float64, 0)
	}
	s.indicators["sma"] = append(s.indicators["sma"], sma)
	s.indicators["upper_band"] = append(s.indicators["upper_band"], upperBand)
	s.indicators["lower_band"] = append(s.indicators["lower_band"], lowerBand)
	
	signal := Signal{Action: "HOLD"}
	
	// Buy when price touches lower band (oversold)
	if bar.Close <= lowerBand && s.lastSignal != "BUY" {
		signal.Action = "BUY"
		signal.Quantity = 1
		signal.StopLoss = bar.Close * (1 - s.stopLossPct)
		signal.TakeProfit = bar.Close * (1 + s.takeProfitPct)
		s.lastSignal = "BUY"
	}
	
	// Sell when price touches upper band (overbought)
	if bar.Close >= upperBand && s.lastSignal != "SELL" {
		signal.Action = "SELL"
		s.lastSignal = "SELL"
	}
	
	return signal
}

func (s *BollingerBandsBacktestStrategy) GetParameters() map[string]interface{} {
	return map[string]interface{}{
		"strategy":        "Bollinger_Bands",
		"symbol":         s.symbol,
		"period":         s.period,
		"num_std_dev":    s.numStdDev,
		"stop_loss_pct":  s.stopLossPct,
		"take_profit_pct": s.takeProfitPct,
	}
}

func (s *BollingerBandsBacktestStrategy) Reset() {
	s.prices = nil
	s.indicators = make(map[string][]float64)
	s.lastSignal = ""
	s.tradeCount = 0
	s.position = nil
}

func (s *BollingerBandsBacktestStrategy) SetParameters(params map[string]interface{}) error {
	if period, ok := params["period"].(float64); ok {
		s.period = int(period)
	}
	if numStdDev, ok := params["num_std_dev"].(float64); ok {
		s.numStdDev = numStdDev
	}
	if stopLoss, ok := params["stop_loss_pct"].(float64); ok {
		s.stopLossPct = stopLoss
	}
	if takeProfit, ok := params["take_profit_pct"].(float64); ok {
		s.takeProfitPct = takeProfit
	}
	s.parameters = params
	return nil
}

func (s *BollingerBandsBacktestStrategy) calculateSMA(prices []float64, period int) float64 {
	if len(prices) < period {
		return prices[len(prices)-1] // Return last price if insufficient data
	}
	
	sum := 0.0
	start := len(prices) - period
	for i := start; i < len(prices); i++ {
		sum += prices[i]
	}
	return sum / float64(period)
}

func (s *BollingerBandsBacktestStrategy) calculateStdDev(prices []float64, period int, mean float64) float64 {
	if len(prices) < period {
		return 0.0
	}
	
	variance := 0.0
	start := len(prices) - period
	for i := start; i < len(prices); i++ {
		diff := prices[i] - mean
		variance += diff * diff
	}
	variance /= float64(period)
	return math.Sqrt(variance)
}

// MACDBacktestStrategy wraps MACD Divergence strategy
type MACDBacktestStrategy struct {
	*BacktestWrapper
	fastPeriod    int
	slowPeriod    int
	signalPeriod  int
	stopLossPct   float64
	takeProfitPct float64
}

func NewMACDBacktestStrategy(symbol string) *MACDBacktestStrategy {
	return &MACDBacktestStrategy{
		BacktestWrapper: &BacktestWrapper{
			symbol:     symbol,
			indicators: make(map[string][]float64),
			parameters: make(map[string]interface{}),
		},
		fastPeriod:    12,
		slowPeriod:    26,
		signalPeriod:  9,
		stopLossPct:   0.05,
		takeProfitPct: 0.10,
	}
}

func (s *MACDBacktestStrategy) ProcessBar(bar Bar, portfolio *Portfolio) Signal {
	s.prices = append(s.prices, bar.Close)
	
	if len(s.prices) < s.slowPeriod+s.signalPeriod {
		return Signal{Action: "HOLD"}
	}
	
	// Calculate MACD
	fastEMA := s.calculateEMA(s.prices, s.fastPeriod)
	slowEMA := s.calculateEMA(s.prices, s.slowPeriod)
	macdLine := fastEMA - slowEMA
	
	// Store MACD line for signal calculation
	if s.indicators["macd"] == nil {
		s.indicators["macd"] = make([]float64, 0)
	}
	s.indicators["macd"] = append(s.indicators["macd"], macdLine)
	
	// Need enough MACD values for signal line
	if len(s.indicators["macd"]) < s.signalPeriod {
		return Signal{Action: "HOLD"}
	}
	
	// Calculate signal line
	signalLine := s.calculateEMA(s.indicators["macd"], s.signalPeriod)
	
	signal := Signal{Action: "HOLD"}
	
	// MACD bullish crossover
	if len(s.indicators["macd"]) > s.signalPeriod && macdLine > signalLine && s.lastSignal != "BUY" {
		// Check if MACD was below signal line before
		prevMacdLine := s.indicators["macd"][len(s.indicators["macd"])-2]
		prevSignalLine := s.calculateEMA(s.indicators["macd"][:len(s.indicators["macd"])-1], s.signalPeriod)
		
		if prevMacdLine <= prevSignalLine {
			signal.Action = "BUY"
			signal.Quantity = 1
			signal.StopLoss = bar.Close * (1 - s.stopLossPct)
			signal.TakeProfit = bar.Close * (1 + s.takeProfitPct)
			s.lastSignal = "BUY"
		}
	}
	
	// MACD bearish crossover
	if len(s.indicators["macd"]) > s.signalPeriod && macdLine < signalLine && s.lastSignal != "SELL" {
		prevMacdLine := s.indicators["macd"][len(s.indicators["macd"])-2]
		prevSignalLine := s.calculateEMA(s.indicators["macd"][:len(s.indicators["macd"])-1], s.signalPeriod)
		
		if prevMacdLine >= prevSignalLine {
			signal.Action = "SELL"
			s.lastSignal = "SELL"
		}
	}
	
	return signal
}

func (s *MACDBacktestStrategy) GetParameters() map[string]interface{} {
	return map[string]interface{}{
		"strategy":        "MACD_Divergence",
		"symbol":         s.symbol,
		"fast_period":    s.fastPeriod,
		"slow_period":    s.slowPeriod,
		"signal_period":  s.signalPeriod,
		"stop_loss_pct":  s.stopLossPct,
		"take_profit_pct": s.takeProfitPct,
	}
}

func (s *MACDBacktestStrategy) Reset() {
	s.prices = nil
	s.indicators = make(map[string][]float64)
	s.lastSignal = ""
	s.tradeCount = 0
	s.position = nil
}

func (s *MACDBacktestStrategy) SetParameters(params map[string]interface{}) error {
	if fastPeriod, ok := params["fast_period"].(float64); ok {
		s.fastPeriod = int(fastPeriod)
	}
	if slowPeriod, ok := params["slow_period"].(float64); ok {
		s.slowPeriod = int(slowPeriod)
	}
	if signalPeriod, ok := params["signal_period"].(float64); ok {
		s.signalPeriod = int(signalPeriod)
	}
	if stopLoss, ok := params["stop_loss_pct"].(float64); ok {
		s.stopLossPct = stopLoss
	}
	if takeProfit, ok := params["take_profit_pct"].(float64); ok {
		s.takeProfitPct = takeProfit
	}
	s.parameters = params
	return nil
}

func (s *MACDBacktestStrategy) calculateEMA(prices []float64, period int) float64 {
	if len(prices) == 0 {
		return 0.0
	}
	if len(prices) < period {
		return prices[len(prices)-1]
	}
	
	multiplier := 2.0 / (float64(period) + 1.0)
	ema := prices[0]
	
	for i := 1; i < len(prices); i++ {
		ema = (prices[i] * multiplier) + (ema * (1 - multiplier))
	}
	
	return ema
}

// VWAPBacktestStrategy wraps VWAP Intraday strategy
type VWAPBacktestStrategy struct {
	*BacktestWrapper
	vwapPeriod    int
	deviationPct  float64
	stopLossPct   float64
	takeProfitPct float64
}

func NewVWAPBacktestStrategy(symbol string) *VWAPBacktestStrategy {
	return &VWAPBacktestStrategy{
		BacktestWrapper: &BacktestWrapper{
			symbol:     symbol,
			indicators: make(map[string][]float64),
			parameters: make(map[string]interface{}),
		},
		vwapPeriod:    20,
		deviationPct:  0.02, // 2% deviation from VWAP
		stopLossPct:   0.05,
		takeProfitPct: 0.10,
	}
}

func (s *VWAPBacktestStrategy) ProcessBar(bar Bar, portfolio *Portfolio) Signal {
	s.prices = append(s.prices, bar.Close)
	
	// Store volume (for now use price as proxy for volume)
	if s.indicators["volume"] == nil {
		s.indicators["volume"] = make([]float64, 0)
	}
	s.indicators["volume"] = append(s.indicators["volume"], bar.Volume)
	
	if len(s.prices) < s.vwapPeriod {
		return Signal{Action: "HOLD"}
	}
	
	// Calculate VWAP
	vwap := s.calculateVWAP(s.prices, s.indicators["volume"], s.vwapPeriod)
	
	signal := Signal{Action: "HOLD"}
	
	// Buy when price is below VWAP by deviation threshold
	if bar.Close < vwap*(1-s.deviationPct) && s.lastSignal != "BUY" {
		signal.Action = "BUY"
		signal.Quantity = 1
		signal.StopLoss = bar.Close * (1 - s.stopLossPct)
		signal.TakeProfit = bar.Close * (1 + s.takeProfitPct)
		s.lastSignal = "BUY"
	}
	
	// Sell when price is above VWAP by deviation threshold
	if bar.Close > vwap*(1+s.deviationPct) && s.lastSignal != "SELL" {
		signal.Action = "SELL"
		s.lastSignal = "SELL"
	}
	
	return signal
}

func (s *VWAPBacktestStrategy) GetParameters() map[string]interface{} {
	return map[string]interface{}{
		"strategy":        "VWAP_Intraday",
		"symbol":         s.symbol,
		"vwap_period":    s.vwapPeriod,
		"deviation_pct":  s.deviationPct,
		"stop_loss_pct":  s.stopLossPct,
		"take_profit_pct": s.takeProfitPct,
	}
}

func (s *VWAPBacktestStrategy) Reset() {
	s.prices = nil
	s.indicators = make(map[string][]float64)
	s.lastSignal = ""
	s.tradeCount = 0
	s.position = nil
}

func (s *VWAPBacktestStrategy) SetParameters(params map[string]interface{}) error {
	if vwapPeriod, ok := params["vwap_period"].(float64); ok {
		s.vwapPeriod = int(vwapPeriod)
	}
	if deviationPct, ok := params["deviation_pct"].(float64); ok {
		s.deviationPct = deviationPct
	}
	if stopLoss, ok := params["stop_loss_pct"].(float64); ok {
		s.stopLossPct = stopLoss
	}
	if takeProfit, ok := params["take_profit_pct"].(float64); ok {
		s.takeProfitPct = takeProfit
	}
	s.parameters = params
	return nil
}

func (s *VWAPBacktestStrategy) calculateVWAP(prices, volumes []float64, period int) float64 {
	if len(prices) < period || len(volumes) < period {
		return prices[len(prices)-1]
	}
	
	start := len(prices) - period
	sumPriceVolume := 0.0
	sumVolume := 0.0
	
	for i := start; i < len(prices); i++ {
		typicalPrice := prices[i] // Simplified - normally (H+L+C)/3
		sumPriceVolume += typicalPrice * volumes[i]
		sumVolume += volumes[i]
	}
	
	if sumVolume == 0 {
		return prices[len(prices)-1]
	}
	
	return sumPriceVolume / sumVolume
}

// Helper function to create strategy instances by name
func CreateBacktestStrategy(strategyName, symbol string) (BacktestStrategy, error) {
	switch strategyName {
	case "rsi":
		return NewRSIBacktestStrategy(symbol), nil
	case "ma":
		return NewMovingAverageCrossoverBacktestStrategy(symbol), nil
	case "bb":
		return NewBollingerBandsBacktestStrategy(symbol), nil
	case "macd":
		return NewMACDBacktestStrategy(symbol), nil
	case "vwap":
		return NewVWAPBacktestStrategy(symbol), nil
	default:
		return nil, fmt.Errorf("unknown strategy: %s", strategyName)
	}
}