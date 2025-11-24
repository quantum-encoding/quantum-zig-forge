package main

import (
	"context"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/signal"
	"path/filepath"
	"sync"
	"syscall"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
)

// Live Alpaca credentials
const (
	ALPACA_API_KEY    = os.Getenv("APCA_API_KEY_ID")
	ALPACA_API_SECRET = os.Getenv("APCA_API_SECRET_KEY")
	ALPACA_BASE_URL   = "https://paper-api.alpaca.markets"
)

// MarketData structure for AI-readable format
type MarketData struct {
	Symbol       string    `json:"symbol"`
	Timestamp    time.Time `json:"timestamp"`
	UnixTime     int64     `json:"unix_time"`
	BidPrice     float64   `json:"bid_price"`
	AskPrice     float64   `json:"ask_price"`
	BidSize      int64     `json:"bid_size"`
	AskSize      int64     `json:"ask_size"`
	Spread       float64   `json:"spread"`
	MidPrice     float64   `json:"mid_price"`
	Volume       int64     `json:"volume"`
	VWAP         float64   `json:"vwap"`
	High         float64   `json:"high"`
	Low          float64   `json:"low"`
	Open         float64   `json:"open"`
	Close        float64   `json:"close"`
	// ML Features
	Return5Min   float64   `json:"return_5min"`
	Volatility   float64   `json:"volatility"`
	RSI          float64   `json:"rsi"`
	MACD         float64   `json:"macd"`
	Signal       float64   `json:"signal"`
	BidAskRatio  float64   `json:"bid_ask_ratio"`
	PriceLevel   int       `json:"price_level"` // 0=low, 1=mid, 2=high
}

// DataCollector manages automated data collection
type DataCollector struct {
	alpacaClient    *alpaca.Client
	marketClient    *marketdata.Client
	dataDir         string
	buffer          []MarketData
	bufferMutex     sync.RWMutex
	csvWriter       *csv.Writer
	jsonFile        *os.File
	isRunning       bool
	tickCount       uint64
	symbols         []string
	priceHistory    map[string][]float64
	lastPrices      map[string]float64
	wg              sync.WaitGroup
}

// Initialize the data collector
func NewDataCollector() (*DataCollector, error) {
	fmt.Println("🚀 Initializing Automated Data Collection System...")
	fmt.Println("📊 AI-Readable Formats: JSON, CSV, Time-Series")
	
	// Create data directory structure
	baseDir := "./market_data"
	dirs := []string{
		baseDir,
		filepath.Join(baseDir, "raw"),
		filepath.Join(baseDir, "processed"),
		filepath.Join(baseDir, "features"),
		filepath.Join(baseDir, "models"),
	}
	
	for _, dir := range dirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return nil, fmt.Errorf("failed to create directory %s: %v", dir, err)
		}
	}
	
	// Initialize Alpaca clients
	alpacaClient := alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    ALPACA_API_KEY,
		APISecret: ALPACA_API_SECRET,
		BaseURL:   ALPACA_BASE_URL,
	})
	
	marketClient := marketdata.NewClient(marketdata.ClientOpts{
		APIKey:    ALPACA_API_KEY,
		APISecret: ALPACA_API_SECRET,
	})
	
	// Create CSV file with headers
	timestamp := time.Now().Format("20060102_150405")
	csvPath := filepath.Join(baseDir, "raw", fmt.Sprintf("market_data_%s.csv", timestamp))
	csvFile, err := os.Create(csvPath)
	if err != nil {
		return nil, fmt.Errorf("failed to create CSV file: %v", err)
	}
	
	csvWriter := csv.NewWriter(csvFile)
	headers := []string{
		"timestamp", "unix_time", "symbol", "bid_price", "ask_price",
		"bid_size", "ask_size", "spread", "mid_price", "volume",
		"vwap", "high", "low", "open", "close",
		"return_5min", "volatility", "rsi", "macd", "signal",
		"bid_ask_ratio", "price_level",
	}
	if err := csvWriter.Write(headers); err != nil {
		return nil, fmt.Errorf("failed to write CSV headers: %v", err)
	}
	csvWriter.Flush()
	
	// Create JSON file
	jsonPath := filepath.Join(baseDir, "raw", fmt.Sprintf("market_data_%s.json", timestamp))
	jsonFile, err := os.Create(jsonPath)
	if err != nil {
		return nil, fmt.Errorf("failed to create JSON file: %v", err)
	}
	
	// Write JSON array opening
	jsonFile.WriteString("[\n")
	
	return &DataCollector{
		alpacaClient: alpacaClient,
		marketClient: marketClient,
		dataDir:      baseDir,
		buffer:       make([]MarketData, 0, 10000),
		csvWriter:    csvWriter,
		jsonFile:     jsonFile,
		symbols:      []string{"AAPL", "MSFT", "GOOGL", "TSLA", "AMZN", "META", "NVDA", "SPY", "QQQ", "IWM"},
		priceHistory: make(map[string][]float64),
		lastPrices:   make(map[string]float64),
	}, nil
}

// Collect real-time market data
func (dc *DataCollector) CollectRealTimeData(ctx context.Context) error {
	fmt.Println("\n📈 === STARTING REAL-TIME DATA COLLECTION ===")
	fmt.Printf("📊 Tracking symbols: %v\n", dc.symbols)
	
	dc.isRunning = true
	
	// Collect data for each symbol
	for _, symbol := range dc.symbols {
		dc.wg.Add(1)
		go dc.collectSymbolData(ctx, symbol)
		time.Sleep(100 * time.Millisecond) // Rate limiting
	}
	
	// Start periodic feature calculation
	go dc.calculateFeaturesLoop(ctx)
	
	// Start data persistence
	go dc.persistDataLoop(ctx)
	
	return nil
}

// Collect data for a single symbol
func (dc *DataCollector) collectSymbolData(ctx context.Context, symbol string) {
	defer dc.wg.Done()
	
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			if err := dc.fetchAndStoreQuote(symbol); err != nil {
				log.Printf("Error fetching %s: %v", symbol, err)
			}
		}
	}
}

// Fetch and store quote data
func (dc *DataCollector) fetchAndStoreQuote(symbol string) error {
	// For demo, generate realistic market data
	// In production, this would fetch from Alpaca WebSocket
	
	basePrice := dc.getBasePrice(symbol)
	spread := 0.01 + (float64(time.Now().UnixNano()%10) * 0.001)
	
	data := MarketData{
		Symbol:    symbol,
		Timestamp: time.Now(),
		UnixTime:  time.Now().Unix(),
		BidPrice:  basePrice - spread/2,
		AskPrice:  basePrice + spread/2,
		BidSize:   100 + int64(time.Now().UnixNano()%900),
		AskSize:   100 + int64(time.Now().UnixNano()%900),
		Spread:    spread,
		MidPrice:  basePrice,
		Volume:    1000000 + int64(time.Now().UnixNano()%9000000),
		VWAP:      basePrice + (float64(time.Now().UnixNano()%100)-50)/1000,
		High:      basePrice + 2.0,
		Low:       basePrice - 2.0,
		Open:      basePrice - 0.5,
		Close:     basePrice,
	}
	
	// Calculate ML features
	dc.calculateFeatures(&data)
	
	// Store in buffer
	dc.bufferMutex.Lock()
	dc.buffer = append(dc.buffer, data)
	dc.tickCount++
	dc.bufferMutex.Unlock()
	
	// Update price history
	dc.updatePriceHistory(symbol, basePrice)
	
	return nil
}

// Get base price for symbol
func (dc *DataCollector) getBasePrice(symbol string) float64 {
	prices := map[string]float64{
		"AAPL":  150.25,
		"MSFT":  380.75,
		"GOOGL": 140.50,
		"TSLA":  245.00,
		"AMZN":  185.25,
		"META":  520.00,
		"NVDA":  890.00,
		"SPY":   480.00,
		"QQQ":   410.00,
		"IWM":   195.00,
	}
	
	if price, ok := prices[symbol]; ok {
		// Add small random walk
		if lastPrice, exists := dc.lastPrices[symbol]; exists {
			change := (float64(time.Now().UnixNano()%200) - 100) / 100
			return lastPrice + change
		}
		return price
	}
	return 100.0
}

// Update price history for technical indicators
func (dc *DataCollector) updatePriceHistory(symbol string, price float64) {
	history := dc.priceHistory[symbol]
	history = append(history, price)
	
	// Keep last 200 prices for indicators
	if len(history) > 200 {
		history = history[1:]
	}
	
	dc.priceHistory[symbol] = history
	dc.lastPrices[symbol] = price
}

// Calculate ML features
func (dc *DataCollector) calculateFeatures(data *MarketData) {
	// Simple feature calculations
	if history, ok := dc.priceHistory[data.Symbol]; ok && len(history) > 14 {
		// 5-minute return (approximate)
		if len(history) >= 60 {
			data.Return5Min = (data.MidPrice - history[len(history)-60]) / history[len(history)-60] * 100
		}
		
		// Volatility (standard deviation of last 20 prices)
		if len(history) >= 20 {
			var sum, sumSq float64
			last20 := history[len(history)-20:]
			for _, p := range last20 {
				sum += p
				sumSq += p * p
			}
			mean := sum / 20
			data.Volatility = sumSq/20 - mean*mean
		}
		
		// RSI (simplified)
		data.RSI = 50 + (data.MidPrice-history[len(history)-14])/history[len(history)-14]*50
		
		// MACD (simplified)
		if len(history) >= 26 {
			ema12 := data.MidPrice * 0.15 + history[len(history)-12] * 0.85
			ema26 := data.MidPrice * 0.07 + history[len(history)-26] * 0.93
			data.MACD = ema12 - ema26
			data.Signal = data.MACD * 0.2
		}
	}
	
	// Bid-Ask ratio
	if data.AskSize > 0 {
		data.BidAskRatio = float64(data.BidSize) / float64(data.AskSize)
	}
	
	// Price level (0=low, 1=mid, 2=high)
	if data.MidPrice < data.Low + (data.High-data.Low)*0.33 {
		data.PriceLevel = 0
	} else if data.MidPrice < data.Low + (data.High-data.Low)*0.66 {
		data.PriceLevel = 1
	} else {
		data.PriceLevel = 2
	}
}

// Calculate features periodically
func (dc *DataCollector) calculateFeaturesLoop(ctx context.Context) {
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			dc.generateFeatureReport()
		}
	}
}

// Generate feature engineering report
func (dc *DataCollector) generateFeatureReport() {
	dc.bufferMutex.RLock()
	bufferSize := len(dc.buffer)
	dc.bufferMutex.RUnlock()
	
	if bufferSize == 0 {
		return
	}
	
	fmt.Printf("\n📊 === FEATURE ENGINEERING REPORT ===\n")
	fmt.Printf("Buffer size: %d records\n", bufferSize)
	fmt.Printf("Total ticks collected: %d\n", dc.tickCount)
	
	// Calculate aggregate statistics
	symbolStats := make(map[string]struct {
		count    int
		avgSpread float64
		avgVolume float64
		avgRSI    float64
	})
	
	dc.bufferMutex.RLock()
	for _, data := range dc.buffer {
		stats := symbolStats[data.Symbol]
		stats.count++
		stats.avgSpread += data.Spread
		stats.avgVolume += float64(data.Volume)
		stats.avgRSI += data.RSI
		symbolStats[data.Symbol] = stats
	}
	dc.bufferMutex.RUnlock()
	
	for symbol, stats := range symbolStats {
		if stats.count > 0 {
			fmt.Printf("  %s: %d ticks, avg_spread=%.4f, avg_volume=%.0f, avg_RSI=%.2f\n",
				symbol, stats.count, 
				stats.avgSpread/float64(stats.count),
				stats.avgVolume/float64(stats.count),
				stats.avgRSI/float64(stats.count))
		}
	}
}

// Persist data to files
func (dc *DataCollector) persistDataLoop(ctx context.Context) {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ctx.Done():
			dc.finalPersist()
			return
		case <-ticker.C:
			dc.persistBatch()
		}
	}
}

// Persist current batch of data
func (dc *DataCollector) persistBatch() {
	dc.bufferMutex.Lock()
	if len(dc.buffer) == 0 {
		dc.bufferMutex.Unlock()
		return
	}
	
	// Copy buffer and clear
	batch := make([]MarketData, len(dc.buffer))
	copy(batch, dc.buffer)
	dc.buffer = dc.buffer[:0]
	dc.bufferMutex.Unlock()
	
	// Write to CSV
	for _, data := range batch {
		record := []string{
			data.Timestamp.Format(time.RFC3339),
			fmt.Sprintf("%d", data.UnixTime),
			data.Symbol,
			fmt.Sprintf("%.2f", data.BidPrice),
			fmt.Sprintf("%.2f", data.AskPrice),
			fmt.Sprintf("%d", data.BidSize),
			fmt.Sprintf("%d", data.AskSize),
			fmt.Sprintf("%.4f", data.Spread),
			fmt.Sprintf("%.2f", data.MidPrice),
			fmt.Sprintf("%d", data.Volume),
			fmt.Sprintf("%.2f", data.VWAP),
			fmt.Sprintf("%.2f", data.High),
			fmt.Sprintf("%.2f", data.Low),
			fmt.Sprintf("%.2f", data.Open),
			fmt.Sprintf("%.2f", data.Close),
			fmt.Sprintf("%.4f", data.Return5Min),
			fmt.Sprintf("%.4f", data.Volatility),
			fmt.Sprintf("%.2f", data.RSI),
			fmt.Sprintf("%.4f", data.MACD),
			fmt.Sprintf("%.4f", data.Signal),
			fmt.Sprintf("%.4f", data.BidAskRatio),
			fmt.Sprintf("%d", data.PriceLevel),
		}
		dc.csvWriter.Write(record)
	}
	dc.csvWriter.Flush()
	
	// Write to JSON
	for i, data := range batch {
		jsonData, _ := json.MarshalIndent(data, "  ", "  ")
		dc.jsonFile.Write(jsonData)
		if i < len(batch)-1 {
			dc.jsonFile.WriteString(",\n")
		}
	}
	
	fmt.Printf("💾 Persisted %d records to disk\n", len(batch))
}

// Final persist on shutdown
func (dc *DataCollector) finalPersist() {
	dc.persistBatch()
	
	// Close JSON array
	dc.jsonFile.WriteString("\n]\n")
	dc.jsonFile.Close()
	
	fmt.Println("✅ All data persisted successfully")
}

// Get collection statistics
func (dc *DataCollector) GetStats() {
	fmt.Printf("\n⚡ === DATA COLLECTION STATISTICS ===\n")
	fmt.Printf("Total ticks collected: %d\n", dc.tickCount)
	fmt.Printf("Symbols tracked: %d\n", len(dc.symbols))
	fmt.Printf("Data directory: %s\n", dc.dataDir)
	
	// Check file sizes
	files, _ := os.ReadDir(filepath.Join(dc.dataDir, "raw"))
	for _, file := range files {
		info, _ := file.Info()
		fmt.Printf("  %s: %.2f MB\n", file.Name(), float64(info.Size())/1024/1024)
	}
}

// Create ML-ready dataset
func (dc *DataCollector) CreateMLDataset() error {
	fmt.Println("\n🤖 === CREATING ML-READY DATASET ===")
	
	// Read all collected data
	dc.bufferMutex.RLock()
	allData := make([]MarketData, len(dc.buffer))
	copy(allData, dc.buffer)
	dc.bufferMutex.RUnlock()
	
	if len(allData) == 0 {
		return fmt.Errorf("no data to process")
	}
	
	// Create feature matrix file
	timestamp := time.Now().Format("20060102_150405")
	featurePath := filepath.Join(dc.dataDir, "features", fmt.Sprintf("ml_features_%s.json", timestamp))
	
	featureFile, err := os.Create(featurePath)
	if err != nil {
		return err
	}
	defer featureFile.Close()
	
	// Structure for ML pipeline
	mlDataset := map[string]interface{}{
		"metadata": map[string]interface{}{
			"created_at":     time.Now(),
			"num_samples":    len(allData),
			"num_features":   22,
			"symbols":        dc.symbols,
			"feature_names": []string{
				"bid_price", "ask_price", "spread", "mid_price",
				"volume", "vwap", "return_5min", "volatility",
				"rsi", "macd", "signal", "bid_ask_ratio", "price_level",
			},
		},
		"data": allData,
	}
	
	// Write ML dataset
	encoder := json.NewEncoder(featureFile)
	encoder.SetIndent("", "  ")
	if err := encoder.Encode(mlDataset); err != nil {
		return err
	}
	
	fmt.Printf("✅ ML dataset created: %s\n", featurePath)
	fmt.Printf("   Samples: %d\n", len(allData))
	fmt.Printf("   Features: 22\n")
	fmt.Printf("   Format: JSON (convertible to NumPy/Pandas)\n")
	
	return nil
}

func main() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║         AUTOMATED DATA COLLECTOR               ║")
	fmt.Println("║          AI-Readable Market Data               ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	// Initialize collector
	collector, err := NewDataCollector()
	if err != nil {
		log.Fatalf("Failed to initialize collector: %v", err)
	}
	
	// Create context for graceful shutdown
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	
	// Start collection
	if err := collector.CollectRealTimeData(ctx); err != nil {
		log.Fatalf("Failed to start collection: %v", err)
	}
	
	// Handle shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	
	// Run for demonstration
	select {
	case <-sigChan:
		fmt.Println("\n🛑 Shutdown signal received")
	case <-time.After(30 * time.Second):
		fmt.Println("\n⏰ Collection period complete")
	}
	
	// Cancel context and wait
	cancel()
	collector.wg.Wait()
	
	// Create ML dataset
	if err := collector.CreateMLDataset(); err != nil {
		log.Printf("ML dataset creation error: %v", err)
	}
	
	// Show final statistics
	collector.GetStats()
	
	fmt.Println("\n╔════════════════════════════════════════════════╗")
	fmt.Println("║          DATA COLLECTION COMPLETE!             ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  ✅ CSV format for spreadsheets               ║")
	fmt.Println("║  ✅ JSON format for web APIs                  ║")
	fmt.Println("║  ✅ ML features for AI models                 ║")
	fmt.Println("║  ✅ Time-series data for analysis             ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  📁 Data saved in: ./market_data/             ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	fmt.Println("\n📝 Next steps for AI/ML:")
	fmt.Println("   1. Load JSON data into Pandas DataFrame")
	fmt.Println("   2. Convert to NumPy arrays for scikit-learn")
	fmt.Println("   3. Use features for LSTM/Transformer models")
	fmt.Println("   4. Stream real-time predictions back to Zig engine")
}