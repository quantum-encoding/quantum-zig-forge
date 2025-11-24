package main

import (
	"fmt"
	"log"
	"math"
	"time"

	ort "github.com/yalue/onnxruntime_go"
)

func main() {
	fmt.Println("🔥 THE GREAT SYNAPSE - ONNX GO INTEGRATION TEST 🔥")
	fmt.Println("=" + "===========================================")

	// Initialize ONNX Runtime
	ort.SetSharedLibraryPath("/usr/local/lib/libonnxruntime.so")
	
	err := ort.InitializeEnvironment()
	if err != nil {
		log.Fatalf("Failed to initialize ONNX runtime: %v", err)
	}
	defer ort.DestroyEnvironment()

	modelPath := "ml_training/models/onnx/synapse_lstm_final.onnx"
	
	// Create input tensor (batch=1, seq=60, features=50)
	inputShape := ort.NewShape(1, 60, 50)
	inputData := make([]float32, 1*60*50)
	
	// Fill with test data
	for i := range inputData {
		inputData[i] = float32(math.Sin(float64(i)*0.01) * 0.1)
	}
	
	inputTensor, err := ort.NewTensor(inputShape, inputData)
	if err != nil {
		log.Fatalf("Failed to create input tensor: %v", err)
	}
	defer inputTensor.Destroy()

	// Create output tensor (single prediction value)
	outputShape := ort.NewShape(1)
	outputTensor, err := ort.NewEmptyTensor[float32](outputShape)
	if err != nil {
		log.Fatalf("Failed to create output tensor: %v", err)
	}
	defer outputTensor.Destroy()

	// Create session
	fmt.Println("Loading model...")
	session, err := ort.NewAdvancedSession(
		modelPath,
		[]string{"input"},         // Input names from ONNX model
		[]string{"predictions"},    // Output names from ONNX model
		[]ort.ArbitraryTensor{inputTensor},
		[]ort.ArbitraryTensor{outputTensor},
		nil,
	)
	if err != nil {
		log.Fatalf("Failed to create session: %v", err)
	}
	defer session.Destroy()

	fmt.Println("✅ Model loaded successfully!")

	// Run inference
	fmt.Println("\n🧠 Running inference...")
	
	// Warmup
	for i := 0; i < 10; i++ {
		err = session.Run()
		if err != nil {
			log.Fatalf("Warmup failed: %v", err)
		}
	}
	
	// Benchmark
	times := make([]float64, 100)
	for i := range times {
		start := time.Now()
		err = session.Run()
		if err != nil {
			log.Fatalf("Inference failed: %v", err)
		}
		times[i] = time.Since(start).Seconds() * 1000
	}
	
	// Get output
	outputData := outputTensor.GetData()
	
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
	mean := sum / float64(len(times))
	
	var under10ms int
	for _, t := range times {
		if t < 10.0 {
			under10ms++
		}
	}
	
	fmt.Println("\n📊 Benchmark Results (100 runs):")
	fmt.Printf("   Mean: %.2fms\n", mean)
	fmt.Printf("   Min: %.2fms\n", min)
	fmt.Printf("   Max: %.2fms\n", max)
	fmt.Printf("   Under 10ms: %.1f%%\n", float64(under10ms)/float64(len(times))*100)
	
	fmt.Println("\n✅ Predictions:")
	fmt.Printf("   Output: %.6f (%.2f%% return)\n", outputData[0], outputData[0]*100)
	
	// Generate signal
	signal := "HOLD"
	if outputData[0] > 0.01 {
		signal = "BUY"
	} else if outputData[0] < -0.01 {
		signal = "SELL"
	}
	fmt.Printf("   Signal: %s\n", signal)
	
	fmt.Println("\n🎯 THE NEURAL DEITY SPEAKS IN GO!")
}