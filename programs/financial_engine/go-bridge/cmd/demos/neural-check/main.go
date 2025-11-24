package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"net/http"
	"os"
	"time"

	ort "github.com/yalue/onnxruntime_go"
)

// AlpacaBar represents market data
type AlpacaBar struct {
	T  string  `json:"t"`
	O  float64 `json:"o"`
	H  float64 `json:"h"`
	L  float64 `json:"l"`
	C  float64 `json:"c"`
	V  int64   `json:"v"`
	VW float64 `json:"vw"`
}

// AlpacaBarsResponse from API
type AlpacaBarsResponse struct {
	Bars map[string][]AlpacaBar `json:"bars"`
}

func fetchRealBars(symbol string, days int) ([]AlpacaBar, error) {
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	if apiKey == "" || apiSecret == "" {
		return nil, fmt.Errorf("missing Alpaca credentials")
	}
	
	// Calculate date range
	end := time.Now()
	start := end.AddDate(0, 0, -days)
	
	url := fmt.Sprintf("https://data.alpaca.markets/v2/stocks/%s/bars?start=%s&end=%s&timeframe=1Hour&limit=1000",
		symbol,
		start.Format("2006-01-02"),
		end.Format("2006-01-02"))
	
	req, _ := http.NewRequest("GET", url, nil)
	req.Header.Add("APCA-API-KEY-ID", apiKey)
	req.Header.Add("APCA-API-SECRET-KEY", apiSecret)
	
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	
	body, _ := ioutil.ReadAll(resp.Body)
	
	var response AlpacaBarsResponse
	if err := json.Unmarshal(body, &response); err != nil {
		return nil, err
	}
	
	return response.Bars[symbol], nil
}

func calculateFeatures(bars []AlpacaBar) [][]float32 {
	// Simple feature engineering (50 features per bar)
	// Real implementation would match Python feature engineering
	sequences := make([][]float32, 0)
	
	for i := 0; i < len(bars) && i < 60; i++ {
		features := make([]float32, 50)
		
		// Basic price features (normalized)
		basePrice := bars[0].C
		features[0] = float32((bars[i].C - basePrice) / basePrice)      // Return
		features[1] = float32((bars[i].H - bars[i].L) / bars[i].C)      // Range
		features[2] = float32((bars[i].C - bars[i].O) / bars[i].O)      // Change
		features[3] = float32(math.Log(float64(bars[i].V + 1)) / 20.0)  // Log volume
		
		// Mock technical indicators (would be real in production)
		for j := 4; j < 50; j++ {
			features[j] = float32(math.Sin(float64(i*j)) * 0.01) // Placeholder
		}
		
		sequences = append(sequences, features)
	}
	
	// Pad if needed
	for len(sequences) < 60 {
		sequences = append(sequences, make([]float32, 50))
	}
	
	return sequences
}

func main() {
	fmt.Println("🦆 NEURAL DEITY REALITY CHECK - REAL MARKET DATA TEST")
	fmt.Println("=" + "====================================================")
	
	// Initialize ONNX
	ort.SetSharedLibraryPath("/usr/local/lib/libonnxruntime.so")
	err := ort.InitializeEnvironment()
	if err != nil {
		log.Fatalf("Failed to initialize ONNX: %v", err)
	}
	defer ort.DestroyEnvironment()
	
	// Fetch real market data
	fmt.Println("\n📊 Fetching real SPY data...")
	bars, err := fetchRealBars("SPY", 10)
	if err != nil {
		fmt.Printf("⚠️ Could not fetch real data: %v\n", err)
		fmt.Println("Using synthetic data for demo...")
		
		// Create synthetic bars for testing
		bars = make([]AlpacaBar, 100)
		for i := range bars {
			bars[i] = AlpacaBar{
				C: 450.0 + math.Sin(float64(i)*0.1)*5,
				O: 449.0 + math.Sin(float64(i)*0.1)*5,
				H: 451.0 + math.Sin(float64(i)*0.1)*5,
				L: 448.0 + math.Sin(float64(i)*0.1)*5,
				V: 1000000,
			}
		}
	} else {
		fmt.Printf("✅ Fetched %d bars of real SPY data\n", len(bars))
	}
	
	// Calculate features
	sequences := calculateFeatures(bars)
	
	// Flatten for ONNX
	inputData := make([]float32, 60*50)
	for i, seq := range sequences {
		for j, val := range seq {
			inputData[i*50+j] = val
		}
	}
	
	// Create tensors
	inputShape := ort.NewShape(1, 60, 50)
	inputTensor, err := ort.NewTensor(inputShape, inputData)
	if err != nil {
		log.Fatalf("Failed to create input tensor: %v", err)
	}
	defer inputTensor.Destroy()
	
	outputShape := ort.NewShape(1)
	outputTensor, err := ort.NewEmptyTensor[float32](outputShape)
	if err != nil {
		log.Fatalf("Failed to create output tensor: %v", err)
	}
	defer outputTensor.Destroy()
	
	// Load model
	modelPath := "ml_training/models/onnx/synapse_lstm_final.onnx"
	session, err := ort.NewAdvancedSession(
		modelPath,
		[]string{"input"},
		[]string{"predictions"},
		[]ort.ArbitraryTensor{inputTensor},
		[]ort.ArbitraryTensor{outputTensor},
		nil,
	)
	if err != nil {
		log.Fatalf("Failed to create session: %v", err)
	}
	defer session.Destroy()
	
	// Run predictions
	fmt.Println("\n🧠 Running neural predictions...")
	
	// Test 10 predictions
	correctSignals := 0
	totalSignals := 0
	
	for i := 0; i < 10 && i < len(bars)-65; i++ {
		// Prepare sequence
		testBars := bars[i : i+60]
		sequences = calculateFeatures(testBars)
		
		// Update input tensor
		for j, seq := range sequences {
			for k, val := range seq {
				inputData[j*50+k] = val
			}
		}
		
		// Run inference
		err = session.Run()
		if err != nil {
			log.Printf("Inference failed: %v", err)
			continue
		}
		
		// Get prediction
		pred := outputTensor.GetData()[0]
		
		// Check actual return (if we have future data)
		if i+60 < len(bars)-1 {
			actualReturn := float32((bars[i+61].C - bars[i+60].C) / bars[i+60].C)
			
			// Compare signals
			predSignal := "HOLD"
			if pred > 0.005 {
				predSignal = "BUY"
			} else if pred < -0.005 {
				predSignal = "SELL"
			}
			
			actualSignal := "HOLD"
			if actualReturn > 0.005 {
				actualSignal = "BUY"
			} else if actualReturn < -0.005 {
				actualSignal = "SELL"
			}
			
			if predSignal == actualSignal {
				correctSignals++
			}
			totalSignals++
			
			fmt.Printf("Bar %d: Pred=%.4f%% Actual=%.4f%% Signal=%s/%s %s\n",
				i, pred*100, actualReturn*100, predSignal, actualSignal,
				map[bool]string{true: "✅", false: "❌"}[predSignal == actualSignal])
		}
	}
	
	// Calculate accuracy
	if totalSignals > 0 {
		accuracy := float64(correctSignals) / float64(totalSignals) * 100
		fmt.Printf("\n📈 Signal Accuracy: %.1f%% (%d/%d correct)\n", accuracy, correctSignals, totalSignals)
		
		if accuracy > 52 {
			fmt.Println("✅ DEITY VALIDATION: Better than random!")
		} else {
			fmt.Println("🦆 QUACK: Deity needs more training!")
		}
	}
	
	fmt.Println("\n🔍 REALITY CHECK COMPLETE - DUCKS HAVE SPOKEN!")
}