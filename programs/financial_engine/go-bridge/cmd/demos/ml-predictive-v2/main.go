package main

import (
	"fmt"
	"log"
	"math"
	"strings"
	"time"

	onnxruntime "github.com/yalue/onnxruntime_go"
)

// SynapseNeuralPredictor - The Great Synapse LSTM Predictor
type SynapseNeuralPredictor struct {
	session      *onnxruntime.AdvancedSession
	inputShape   []int64
	featureCount int
	seqLength    int
}

// NewSynapseNeuralPredictor creates a new neural predictor
func NewSynapseNeuralPredictor(modelPath string) (*SynapseNeuralPredictor, error) {
	// Initialize ONNX Runtime
	onnxruntime.SetSharedLibraryPath("/usr/local/lib/libonnxruntime.so")
	
	err := onnxruntime.InitializeEnvironment()
	if err != nil {
		return nil, fmt.Errorf("failed to initialize ONNX runtime: %w", err)
	}

	// Create session with CPU provider
	session, err := onnxruntime.NewAdvancedSession(
		modelPath,
		[]string{"CPUExecutionProvider"},
		[]string{}, nil, nil, nil,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create ONNX session: %w", err)
	}

	return &SynapseNeuralPredictor{
		session:      session,
		inputShape:   []int64{1, 60, 50}, // batch=1, seq=60, features=50
		featureCount: 50,
		seqLength:    60,
	}, nil
}

// PredictReturns predicts future returns for multiple horizons
func (p *SynapseNeuralPredictor) PredictReturns(features [][]float32) (map[string]float32, error) {
	if len(features) != p.seqLength {
		return nil, fmt.Errorf("expected %d sequences, got %d", p.seqLength, len(features))
	}

	// Flatten features for ONNX input
	flatFeatures := make([]float32, p.seqLength*p.featureCount)
	for i, seq := range features {
		for j, val := range seq {
			flatFeatures[i*p.featureCount+j] = val
		}
	}

	// Create input tensor
	inputTensor, err := onnxruntime.NewTensor(p.inputShape, flatFeatures)
	if err != nil {
		return nil, fmt.Errorf("failed to create input tensor: %w", err)
	}
	defer inputTensor.Destroy()

	// Run inference
	outputs, err := p.session.Run([]onnxruntime.ArbitraryTensor{inputTensor})
	if err != nil {
		return nil, fmt.Errorf("inference failed: %w", err)
	}
	defer outputs[0].Destroy()

	// Extract predictions
	outputData, err := outputs[0].GetFloatData()
	if err != nil {
		return nil, fmt.Errorf("failed to get output data: %w", err)
	}

	// Map to horizons (model outputs single value for now)
	predictions := map[string]float32{
		"horizon_1": outputData[0], // 1-step ahead
		"horizon_3": outputData[0], // Could be extended for multi-output
		"horizon_5": outputData[0],
	}

	return predictions, nil
}

// GenerateSignal converts predictions to trading signal
func (p *SynapseNeuralPredictor) GenerateSignal(predictions map[string]float32, threshold float32) string {
	// Use horizon_1 for immediate signal
	pred := predictions["horizon_1"]

	if pred > threshold {
		return "BUY"
	} else if pred < -threshold {
		return "SELL"
	}
	return "HOLD"
}

// Benchmark runs performance benchmarks
func (p *SynapseNeuralPredictor) Benchmark(numRuns int) {
	// Generate random test data
	testFeatures := make([][]float32, p.seqLength)
	for i := range testFeatures {
		testFeatures[i] = make([]float32, p.featureCount)
		for j := range testFeatures[i] {
			testFeatures[i][j] = float32(math.Sin(float64(i+j)) * 0.1)
		}
	}

	// Warmup
	for i := 0; i < 10; i++ {
		_, _ = p.PredictReturns(testFeatures)
	}

	// Benchmark
	times := make([]float64, numRuns)
	for i := 0; i < numRuns; i++ {
		start := time.Now()
		_, err := p.PredictReturns(testFeatures)
		elapsed := time.Since(start)
		if err != nil {
			log.Printf("Benchmark error: %v", err)
			continue
		}
		times[i] = elapsed.Seconds() * 1000 // Convert to ms
	}

	// Calculate stats
	var sum, min, max float64
	min = times[0]
	max = times[0]
	for _, t := range times {
		sum += t
		if t < min {
			min = t
		}
		if t > max {
			max = t
		}
	}
	mean := sum / float64(numRuns)

	// Calculate percentiles
	var under10ms int
	for _, t := range times {
		if t < 10.0 {
			under10ms++
		}
	}

	fmt.Printf("🔥 Go ONNX Inference Benchmark (%d runs):\n", numRuns)
	fmt.Printf("   Mean: %.2fms\n", mean)
	fmt.Printf("   Min: %.2fms\n", min)
	fmt.Printf("   Max: %.2fms\n", max)
	fmt.Printf("   Under 10ms: %.1f%%\n", float64(under10ms)/float64(numRuns)*100)
}

// Close cleans up the ONNX session
func (p *SynapseNeuralPredictor) Close() {
	if p.session != nil {
		p.session.Destroy()
	}
	onnxruntime.DestroyEnvironment()
}

// MLEnhancedStrategy combines classical indicators with neural predictions
type MLEnhancedStrategy struct {
	predictor    *SynapseNeuralPredictor
	threshold    float32
	minProb      float32
	featureQueue [][]float32
}

// NewMLEnhancedStrategy creates ML-enhanced trading strategy
func NewMLEnhancedStrategy(modelPath string) (*MLEnhancedStrategy, error) {
	predictor, err := NewSynapseNeuralPredictor(modelPath)
	if err != nil {
		return nil, err
	}

	return &MLEnhancedStrategy{
		predictor:    predictor,
		threshold:    0.01,  // 1% return threshold
		minProb:      0.65,  // 65% confidence threshold
		featureQueue: make([][]float32, 0, 60),
	}, nil
}

// ProcessBar processes a new market bar and generates signal
func (s *MLEnhancedStrategy) ProcessBar(features []float32) (string, float32, error) {
	// Add to feature queue
	s.featureQueue = append(s.featureQueue, features)

	// Keep only last 60 sequences
	if len(s.featureQueue) > 60 {
		s.featureQueue = s.featureQueue[len(s.featureQueue)-60:]
	}

	// Need full sequence for prediction
	if len(s.featureQueue) < 60 {
		return "HOLD", 0.0, nil
	}

	// Get predictions
	predictions, err := s.predictor.PredictReturns(s.featureQueue)
	if err != nil {
		return "HOLD", 0.0, err
	}

	// Generate signal
	signal := s.predictor.GenerateSignal(predictions, s.threshold)
	confidence := math.Abs(float64(predictions["horizon_1"]))

	return signal, float32(confidence), nil
}

func main() {
	fmt.Println("🔥 THE GREAT SYNAPSE - NEURAL DEITY GO INTEGRATION 🔥")
	fmt.Println("=" + strings.Repeat("=", 60))

	// Load the ONNX model
	modelPath := "ml_training/models/onnx/synapse_lstm_final.onnx"
	
	predictor, err := NewSynapseNeuralPredictor(modelPath)
	if err != nil {
		log.Fatalf("Failed to load model: %v", err)
	}
	defer predictor.Close()

	fmt.Println("✅ Neural Deity loaded successfully!")

	// Run benchmark
	fmt.Println("\n📊 Running inference benchmark...")
	predictor.Benchmark(100)

	// Test prediction
	fmt.Println("\n🧠 Testing prediction...")
	testFeatures := make([][]float32, 60)
	for i := range testFeatures {
		testFeatures[i] = make([]float32, 50)
		for j := range testFeatures[i] {
			// Simulate normalized features
			testFeatures[i][j] = float32(math.Sin(float64(i*j)) * 0.1)
		}
	}

	predictions, err := predictor.PredictReturns(testFeatures)
	if err != nil {
		log.Fatalf("Prediction failed: %v", err)
	}

	fmt.Println("✅ Predictions:")
	for horizon, pred := range predictions {
		fmt.Printf("   %s: %.6f (%.2f%% return)\n", horizon, pred, pred*100)
	}

	signal := predictor.GenerateSignal(predictions, 0.005)
	fmt.Printf("\n📈 Trading Signal: %s\n", signal)

	// Test ML-enhanced strategy
	fmt.Println("\n🚀 Testing ML-Enhanced Strategy...")
	strategy, err := NewMLEnhancedStrategy(modelPath)
	if err != nil {
		log.Fatalf("Failed to create strategy: %v", err)
	}
	defer strategy.predictor.Close()

	// Simulate processing bars
	for i := 0; i < 65; i++ {
		features := make([]float32, 50)
		for j := range features {
			features[j] = float32(math.Sin(float64(i+j)*0.1) * 0.2)
		}

		signal, confidence, err := strategy.ProcessBar(features)
		if err != nil {
			log.Printf("Error processing bar %d: %v", i, err)
			continue
		}

		if i >= 59 { // Only show when we have full sequence
			fmt.Printf("Bar %d: Signal=%s, Confidence=%.4f\n", i, signal, confidence)
		}
	}

	fmt.Println("\n🎯 THE NEURAL DEITY SPEAKS PROPHECIES IN GO!")
	fmt.Println("⚡ Ready for backtesting and live deployment!")
}