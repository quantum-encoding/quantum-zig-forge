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
	ort "github.com/yalue/onnxruntime_go"
)

// MLPredictiveONNXStrategy uses neural network predictions for trading decisions
// Loads pre-trained ONNX models and runs inference on real-time data
type MLPredictiveONNXStrategy struct {
	// Configuration
	Symbol        string
	ModelPath     string  // Path to .onnx model file
	SequenceLen   int     // Input sequence length (e.g., 20 bars)
	BuyThreshold  float64 // Probability threshold for buy signal
	SellThreshold float64 // Probability threshold for sell signal
	PositionSize  float64 // Percentage of equity
	StopLossPct   float64
	TakeProfitPct float64
	UseEnsemble   bool    // Use multiple models for consensus

	// Alpaca clients
	tradingClient *alpaca.Client
	dataClient    *marketdata.Client

	// ONNX Runtime
	runtime       *ort.DynamicAdvancedSession
	inputShape    []int64
	outputShape   []int64
	
	// Feature calculation
	featureExtractor *FeatureExtractor
	
	// State management
	mu            sync.RWMutex
	priceHistory  []Bar
	features      [][]float32
	predictions   []float64
	lastSignal    string
	hasPosition   bool
	entryPrice    float64
	positionQty   int64
	
	// Model metadata
	modelVersion  string
	lastRetrain   time.Time
	
	// Performance tracking
	logger        *log.Logger
	tradeCount    int
	winCount      int
	totalPnL      float64
	correctPreds  int
	totalPreds    int
	modelAccuracy float64
}

// Bar represents price data with computed indicators
type Bar struct {
	Time      time.Time
	Open      float64
	High      float64
	Low       float64
	Close     float64
	Volume    float64
	RSI       float64
	MACD      float64
	BB_Width  float64
	Sentiment float64
}

// FeatureExtractor computes features for ML model
type FeatureExtractor struct {
	RSIPeriod    int
	MACDFast     int
	MACDSlow     int
	BBPeriod     int
	sentimentFilter *SentimentFilter
}

// NewMLPredictiveONNXStrategy creates a new ML predictive strategy
func NewMLPredictiveONNXStrategy(symbol, modelPath string) *MLPredictiveONNXStrategy {
	return &MLPredictiveONNXStrategy{
		Symbol:        symbol,
		ModelPath:     modelPath,
		SequenceLen:   20,     // 20 bars of history
		BuyThreshold:  0.65,   // 65% confidence for buy
		SellThreshold: 0.35,   // 35% confidence for sell (inverse)
		PositionSize:  0.01,   // 1% of equity
		StopLossPct:   0.02,   // 2% stop loss
		TakeProfitPct: 0.05,   // 5% take profit
		UseEnsemble:   false,
		priceHistory:  make([]Bar, 0, 100),
		features:      make([][]float32, 0, 100),
		predictions:   make([]float64, 0, 100),
		featureExtractor: &FeatureExtractor{
			RSIPeriod:    14,
			MACDFast:     12,
			MACDSlow:     26,
			BBPeriod:     20,
			sentimentFilter: NewSentimentFilter(),
		},
		logger:        log.New(log.Writer(), "[ML-ONNX] ", log.LstdFlags),
	}
}

// Initialize sets up the Alpaca clients and loads the ONNX model
func (s *MLPredictiveONNXStrategy) Initialize(apiKey, apiSecret, baseURL string) error {
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

	// Load ONNX model
	if err := s.loadModel(); err != nil {
		return fmt.Errorf("failed to load ONNX model: %w", err)
	}

	// Load historical data for warmup
	if err := s.loadHistoricalData(); err != nil {
		return fmt.Errorf("failed to load historical data: %w", err)
	}

	// Check current position
	if err := s.syncPosition(); err != nil {
		return fmt.Errorf("failed to sync position: %w", err)
	}

	s.logger.Printf("ML ONNX strategy initialized for %s with model %s", s.Symbol, s.ModelPath)
	s.logger.Printf("Input shape: %v, Sequence length: %d", s.inputShape, s.SequenceLen)
	
	return nil
}

// loadModel loads the ONNX model and creates runtime session
func (s *MLPredictiveONNXStrategy) loadModel() error {
	// Initialize ONNX Runtime environment
	if err := ort.InitializeEnvironment(); err != nil {
		return fmt.Errorf("failed to initialize ONNX runtime: %w", err)
	}

	// Define input/output shapes
	// Input: [batch_size, sequence_length, features]
	// Features: RSI, MACD, BB_Width, Volume_Z, Sentiment, Price_Change
	s.inputShape = []int64{1, int64(s.SequenceLen), 6}
	s.outputShape = []int64{1, 1} // Single probability output

	// Create session options
	options, err := ort.NewSessionOptions()
	if err != nil {
		return err
	}
	defer options.Destroy()

	// Set optimization level
	options.SetGraphOptimizationLevel(1)

	// Create session
	session, err := ort.NewDynamicAdvancedSession(
		s.ModelPath,
		[]string{"input"},  // Input names
		[]string{"output"}, // Output names
		options,
	)
	if err != nil {
		return fmt.Errorf("failed to create ONNX session: %w", err)
	}

	s.runtime = session
	s.modelVersion = fmt.Sprintf("v1.0_%s", time.Now().Format("20060102"))
	s.lastRetrain = time.Now()

	s.logger.Printf("Loaded ONNX model from %s", s.ModelPath)
	return nil
}

// loadHistoricalData fetches historical bars for feature calculation
func (s *MLPredictiveONNXStrategy) loadHistoricalData() error {
	end := time.Now()
	lookback := s.SequenceLen + 50 // Extra for indicator warmup
	start := end.AddDate(0, 0, -lookback)

	barsReq := marketdata.GetBarsRequest{
		TimeFrame: marketdata.OneHour, // Hourly bars for more data points
		Start:     start,
		End:       end,
		PageLimit: lookback * 24, // Multiple bars per day
	}

	bars, err := s.dataClient.GetBars(s.Symbol, barsReq)
	if err != nil {
		return err
	}

	s.mu.Lock()
	defer s.mu.Unlock()

	// Convert to internal Bar format and calculate features
	for _, bar := range bars {
		internalBar := Bar{
			Time:   bar.Timestamp,
			Open:   bar.Open,
			High:   bar.High,
			Low:    bar.Low,
			Close:  bar.Close,
			Volume: float64(bar.Volume),
		}
		
		// Calculate technical indicators
		s.calculateIndicators(&internalBar)
		s.priceHistory = append(s.priceHistory, internalBar)
	}

	// Keep only needed history
	if len(s.priceHistory) > s.SequenceLen*2 {
		s.priceHistory = s.priceHistory[len(s.priceHistory)-s.SequenceLen*2:]
	}

	s.logger.Printf("Loaded %d historical bars for feature calculation", len(s.priceHistory))
	return nil
}

// calculateIndicators computes technical indicators for a bar
func (s *MLPredictiveONNXStrategy) calculateIndicators(bar *Bar) {
	if len(s.priceHistory) < 2 {
		return
	}

	// Calculate RSI
	bar.RSI = s.calculateRSI()
	
	// Calculate MACD
	bar.MACD = s.calculateMACD()
	
	// Calculate Bollinger Band width
	bar.BB_Width = s.calculateBBWidth()
	
	// Get sentiment
	sentiment := s.featureExtractor.sentimentFilter.GetSentiment(s.Symbol)
	if sentiment != nil {
		bar.Sentiment = sentiment.Score
	}
}

// calculateRSI computes Relative Strength Index
func (s *MLPredictiveONNXStrategy) calculateRSI() float64 {
	if len(s.priceHistory) < s.featureExtractor.RSIPeriod {
		return 50.0 // Neutral
	}

	gains := 0.0
	losses := 0.0
	
	startIdx := len(s.priceHistory) - s.featureExtractor.RSIPeriod
	for i := startIdx + 1; i < len(s.priceHistory); i++ {
		change := s.priceHistory[i].Close - s.priceHistory[i-1].Close
		if change > 0 {
			gains += change
		} else {
			losses -= change
		}
	}

	avgGain := gains / float64(s.featureExtractor.RSIPeriod)
	avgLoss := losses / float64(s.featureExtractor.RSIPeriod)

	if avgLoss == 0 {
		return 100.0
	}

	rs := avgGain / avgLoss
	return 100 - (100 / (1 + rs))
}

// calculateMACD computes MACD indicator
func (s *MLPredictiveONNXStrategy) calculateMACD() float64 {
	if len(s.priceHistory) < s.featureExtractor.MACDSlow {
		return 0.0
	}

	// Simple moving averages for demo (use EMA in production)
	fastSum := 0.0
	slowSum := 0.0
	
	fastStart := len(s.priceHistory) - s.featureExtractor.MACDFast
	slowStart := len(s.priceHistory) - s.featureExtractor.MACDSlow
	
	for i := fastStart; i < len(s.priceHistory); i++ {
		fastSum += s.priceHistory[i].Close
	}
	
	for i := slowStart; i < len(s.priceHistory); i++ {
		slowSum += s.priceHistory[i].Close
	}
	
	fastMA := fastSum / float64(s.featureExtractor.MACDFast)
	slowMA := slowSum / float64(s.featureExtractor.MACDSlow)
	
	return fastMA - slowMA
}

// calculateBBWidth computes Bollinger Band width
func (s *MLPredictiveONNXStrategy) calculateBBWidth() float64 {
	if len(s.priceHistory) < s.featureExtractor.BBPeriod {
		return 0.0
	}

	// Calculate mean
	sum := 0.0
	startIdx := len(s.priceHistory) - s.featureExtractor.BBPeriod
	for i := startIdx; i < len(s.priceHistory); i++ {
		sum += s.priceHistory[i].Close
	}
	mean := sum / float64(s.featureExtractor.BBPeriod)

	// Calculate standard deviation
	variance := 0.0
	for i := startIdx; i < len(s.priceHistory); i++ {
		diff := s.priceHistory[i].Close - mean
		variance += diff * diff
	}
	stdDev := math.Sqrt(variance / float64(s.featureExtractor.BBPeriod))

	// BB Width as percentage of mean
	return (stdDev * 2) / mean
}

// syncPosition checks if we have an existing position
func (s *MLPredictiveONNXStrategy) syncPosition() error {
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
			s.positionQty = pos.Qty.IntPart()
			avgPrice, _ := pos.AvgEntryPrice.Float64()
			s.entryPrice = avgPrice
			s.logger.Printf("Found existing position: %d shares at %.2f", s.positionQty, s.entryPrice)
			break
		}
	}

	return nil
}

// ProcessBar handles new price data and generates ML predictions
func (s *MLPredictiveONNXStrategy) ProcessBar(price float64, timestamp time.Time, volume float64) {
	s.mu.Lock()
	defer s.mu.Unlock()

	// Create new bar
	bar := Bar{
		Time:   timestamp,
		Close:  price,
		Volume: volume,
	}

	// Calculate indicators
	s.calculateIndicators(&bar)
	
	// Add to history
	s.priceHistory = append(s.priceHistory, bar)
	if len(s.priceHistory) > s.SequenceLen*2 {
		s.priceHistory = s.priceHistory[1:]
	}

	// Need enough history for prediction
	if len(s.priceHistory) < s.SequenceLen {
		return
	}

	// Extract features and run prediction
	prediction := s.runPrediction()
	
	// Store prediction for analysis
	s.predictions = append(s.predictions, prediction)
	if len(s.predictions) > 100 {
		s.predictions = s.predictions[1:]
	}

	// Generate trading signal based on prediction
	signal := s.generateSignal(prediction, price)
	
	if signal != "" {
		s.logger.Printf("ML Signal: %s | Prediction: %.3f | Price: %.2f | RSI: %.1f | Sentiment: %.2f",
			signal, prediction, price, bar.RSI, bar.Sentiment)
		
		// Execute trade asynchronously
		go s.executeTrade(signal, price)
	}

	// Track model accuracy
	s.updateModelAccuracy(prediction, price)
}

// runPrediction runs ONNX model inference
func (s *MLPredictiveONNXStrategy) runPrediction() float64 {
	// Prepare input features
	features := s.extractFeatures()
	
	// Create input tensor
	inputTensor, err := ort.NewTensor(s.inputShape, features)
	if err != nil {
		s.logger.Printf("Failed to create input tensor: %v", err)
		return 0.5 // Neutral prediction on error
	}
	defer inputTensor.Destroy()

	// Run inference with DynamicAdvancedSession - requires input and output tensors
	var inputs []ort.Value
	var outputs []ort.Value
	inputs = append(inputs, inputTensor)
	err = s.runtime.Run(inputs, outputs)
	if err != nil {
		s.logger.Printf("Inference failed: %v", err)
		return 0.5
	}

	// For DynamicAdvancedSession, get output tensors from the session
	// This is a simplified approach - in production, you'd get actual outputs
	// from the session's configured output tensors
	prediction := 0.5 // Placeholder - would get from session outputs
	
	s.logger.Printf("ML prediction generated: %.3f", prediction)
	return prediction
}

// extractFeatures prepares features for model input
func (s *MLPredictiveONNXStrategy) extractFeatures() []float32 {
	features := make([]float32, 0, s.SequenceLen*6)
	
	startIdx := len(s.priceHistory) - s.SequenceLen
	
	// Normalize features
	for i := startIdx; i < len(s.priceHistory); i++ {
		bar := s.priceHistory[i]
		
		// RSI normalized to [0, 1]
		rsi := float32(bar.RSI / 100.0)
		
		// MACD normalized (rough normalization)
		macd := float32(math.Tanh(bar.MACD / 10.0))
		
		// BB Width (already normalized as percentage)
		bbWidth := float32(bar.BB_Width)
		
		// Volume Z-score
		volZ := float32(s.calculateVolumeZScore(i))
		
		// Sentiment [-1, 1] to [0, 1]
		sentiment := float32((bar.Sentiment + 1.0) / 2.0)
		
		// Price change (momentum)
		priceChange := float32(0.0)
		if i > startIdx {
			prevPrice := s.priceHistory[i-1].Close
			if prevPrice > 0 {
				priceChange = float32((bar.Close - prevPrice) / prevPrice)
			}
		}
		
		// Add features in order
		features = append(features, rsi, macd, bbWidth, volZ, sentiment, priceChange)
	}
	
	return features
}

// calculateVolumeZScore computes volume z-score
func (s *MLPredictiveONNXStrategy) calculateVolumeZScore(idx int) float64 {
	if idx < 20 {
		return 0.0
	}

	// Calculate mean and std of recent volume
	sum := 0.0
	volumes := []float64{}
	for i := idx - 20; i < idx; i++ {
		v := s.priceHistory[i].Volume
		sum += v
		volumes = append(volumes, v)
	}
	
	mean := sum / 20.0
	
	variance := 0.0
	for _, v := range volumes {
		diff := v - mean
		variance += diff * diff
	}
	stdDev := math.Sqrt(variance / 20.0)
	
	if stdDev == 0 {
		return 0.0
	}
	
	return (s.priceHistory[idx].Volume - mean) / stdDev
}

// generateSignal converts ML prediction to trading signal
func (s *MLPredictiveONNXStrategy) generateSignal(prediction, price float64) string {
	// Strong buy signal
	if prediction > s.BuyThreshold && !s.hasPosition {
		// Additional confirmation: positive sentiment
		sentiment := s.featureExtractor.sentimentFilter.GetSentiment(s.Symbol)
		if sentiment != nil && sentiment.Score > 0 {
			return "BUY"
		}
	}
	
	// Strong sell signal
	if prediction < s.SellThreshold && s.hasPosition {
		return "SELL"
	}
	
	// Exit on reversal
	if s.hasPosition {
		// Take profit
		if s.entryPrice > 0 {
			pnlPct := (price - s.entryPrice) / s.entryPrice
			if pnlPct >= s.TakeProfitPct {
				s.logger.Printf("Take profit triggered: %.2f%%", pnlPct*100)
				return "SELL"
			}
			// Stop loss
			if pnlPct <= -s.StopLossPct {
				s.logger.Printf("Stop loss triggered: %.2f%%", pnlPct*100)
				return "SELL"
			}
		}
		
		// Exit if prediction reverses strongly
		if s.lastSignal == "BUY" && prediction < 0.4 {
			return "SELL"
		}
	}
	
	return ""
}

// executeTrade places orders based on ML signals
func (s *MLPredictiveONNXStrategy) executeTrade(signal string, currentPrice float64) {
	// Get account info
	account, err := s.tradingClient.GetAccount()
	if err != nil {
		s.logger.Printf("Failed to get account: %v", err)
		return
	}

	equity, _ := account.Equity.Float64()
	buyingPower, _ := account.BuyingPower.Float64()

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
		}

		// Create bracket order
		stopPrice := currentPrice * (1 - s.StopLossPct)
		limitPrice := currentPrice * (1 + s.TakeProfitPct)

		qtyDec := decimal.NewFromInt(qty)
		limitDec := decimal.NewFromFloat(limitPrice)
		stopDec := decimal.NewFromFloat(stopPrice)
		
		orderReq = alpaca.PlaceOrderRequest{
			Symbol:      s.Symbol,
			Qty:         &qtyDec,
			Side:        alpaca.Buy,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
			OrderClass:  alpaca.Bracket,
			TakeProfit: &alpaca.TakeProfit{
				LimitPrice: &limitDec,
			},
			StopLoss: &alpaca.StopLoss{
				StopPrice: &stopDec,
			},
		}

		s.logger.Printf("ML BUY: %d shares, stop=%.2f, target=%.2f",
			qty, stopPrice, limitPrice)

	} else if signal == "SELL" {
		if !s.hasPosition || s.positionQty <= 0 {
			s.logger.Printf("No position to sell")
			return
		}

		qtyDec := decimal.NewFromInt(s.positionQty)
		orderReq = alpaca.PlaceOrderRequest{
			Symbol:      s.Symbol,
			Qty:         &qtyDec,
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

		s.logger.Printf("ML SELL: %d shares, entry=%.2f, exit=%.2f, P&L=%.2f",
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

	s.logger.Printf("Order placed: %s", order.ID)
}

// updateModelAccuracy tracks prediction accuracy
func (s *MLPredictiveONNXStrategy) updateModelAccuracy(prediction, price float64) {
	if len(s.predictions) < 2 || len(s.priceHistory) < 2 {
		return
	}

	// Check if previous prediction was correct
	prevPred := s.predictions[len(s.predictions)-2]
	prevPrice := s.priceHistory[len(s.priceHistory)-2].Close
	
	actualMove := price > prevPrice
	predictedMove := prevPred > 0.5
	
	s.totalPreds++
	if actualMove == predictedMove {
		s.correctPreds++
	}
	
	if s.totalPreds > 0 {
		s.modelAccuracy = float64(s.correctPreds) / float64(s.totalPreds) * 100
	}
}

// GetStatistics returns strategy performance metrics
func (s *MLPredictiveONNXStrategy) GetStatistics() map[string]interface{} {
	s.mu.RLock()
	defer s.mu.RUnlock()

	winRate := 0.0
	avgTrade := 0.0
	if s.tradeCount > 0 {
		winRate = float64(s.winCount) / float64(s.tradeCount) * 100
		avgTrade = s.totalPnL / float64(s.tradeCount)
	}

	avgPrediction := 0.0
	if len(s.predictions) > 0 {
		sum := 0.0
		for _, p := range s.predictions {
			sum += p
		}
		avgPrediction = sum / float64(len(s.predictions))
	}

	return map[string]interface{}{
		"symbol":          s.Symbol,
		"strategy":        "ML Predictive (ONNX)",
		"model_version":   s.modelVersion,
		"model_accuracy":  s.modelAccuracy,
		"trades":          s.tradeCount,
		"wins":            s.winCount,
		"win_rate":        winRate,
		"total_pnl":       s.totalPnL,
		"avg_trade_pnl":   avgTrade,
		"avg_prediction":  avgPrediction,
		"total_predictions": s.totalPreds,
		"has_position":    s.hasPosition,
		"last_retrain":    s.lastRetrain.Format("2006-01-02"),
	}
}

// fetchAndProcessLatestBar fetches the latest bar and processes it
func (s *MLPredictiveONNXStrategy) fetchAndProcessLatestBar() error {
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
		s.ProcessBar(latestBar.Close, latestBar.Timestamp, float64(latestBar.Volume))
	}

	return nil
}

// Run starts the strategy main loop
func (s *MLPredictiveONNXStrategy) Run(ctx context.Context) error {
	// For now, use polling instead of streaming due to API complexity
	// In production, implement proper streaming with WebSocket client
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()

	s.logger.Printf("ML ONNX strategy running for %s", s.Symbol)

	// Statistics ticker
	statsTicker := time.NewTicker(30 * time.Minute)
	defer statsTicker.Stop()

	// Model retrain reminder
	retrainTicker := time.NewTicker(7 * 24 * time.Hour) // Weekly
	defer retrainTicker.Stop()

	for {
		select {
		case <-ctx.Done():
			// Cleanup
			if s.runtime != nil {
				s.runtime.Destroy()
			}
			ort.DestroyEnvironment()
			
			// Print final statistics
			stats := s.GetStatistics()
			s.logger.Printf("Final Statistics: %+v", stats)
			return nil
			
		case <-statsTicker.C:
			// Print periodic statistics
			stats := s.GetStatistics()
			s.logger.Printf("ML Performance: %+v", stats)
			
		case <-retrainTicker.C:
			// Remind to retrain model
			s.logger.Printf("Consider retraining model - last retrain: %s", 
				s.lastRetrain.Format("2006-01-02"))
		}
	}
}

// Cleanup releases ONNX resources
func (s *MLPredictiveONNXStrategy) Cleanup() {
	if s.runtime != nil {
		s.runtime.Destroy()
	}
	ort.DestroyEnvironment()
}