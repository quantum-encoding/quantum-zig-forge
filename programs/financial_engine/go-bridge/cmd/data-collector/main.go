package main

import (
	"context"
	"encoding/csv"
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sync"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata/stream"
	"github.com/xitongsys/parquet-go-source/local"
	"github.com/xitongsys/parquet-go/parquet"
	"github.com/xitongsys/parquet-go/writer"
)

// Configuration
const (
	ALPACA_API_KEY    = os.Getenv("APCA_API_KEY_ID")
	ALPACA_API_SECRET = os.Getenv("APCA_API_SECRET_KEY")
	DATA_DIR          = "./market_data"
)

// AI-readable data structures
type MarketTick struct {
	Symbol    string    `parquet:"name=symbol, type=BYTE_ARRAY, convertedtype=UTF8"`
	Timestamp int64     `parquet:"name=timestamp, type=INT64"`
	BidPrice  float64   `parquet:"name=bid_price, type=DOUBLE"`
	AskPrice  float64   `parquet:"name=ask_price, type=DOUBLE"`
	BidSize   int32     `parquet:"name=bid_size, type=INT32"`
	AskSize   int32     `parquet:"name=ask_size, type=INT32"`
	Spread    float64   `parquet:"name=spread, type=DOUBLE"`
	MidPrice  float64   `parquet:"name=mid_price, type=DOUBLE"`
	Volume    int64     `parquet:"name=volume, type=INT64"`
	VWAP      float64   `parquet:"name=vwap, type=DOUBLE"`
}

type TradeData struct {
	Symbol    string    `parquet:"name=symbol, type=BYTE_ARRAY, convertedtype=UTF8"`
	Timestamp int64     `parquet:"name=timestamp, type=INT64"`
	Price     float64   `parquet:"name=price, type=DOUBLE"`
	Size      int32     `parquet:"name=size, type=INT32"`
	Exchange  string    `parquet:"name=exchange, type=BYTE_ARRAY, convertedtype=UTF8"`
	ID        string    `parquet:"name=id, type=BYTE_ARRAY, convertedtype=UTF8"`
	Condition string    `parquet:"name=condition, type=BYTE_ARRAY, convertedtype=UTF8"`
}

type BarData struct {
	Symbol     string    `parquet:"name=symbol, type=BYTE_ARRAY, convertedtype=UTF8"`
	Timestamp  int64     `parquet:"name=timestamp, type=INT64"`
	Open       float64   `parquet:"name=open, type=DOUBLE"`
	High       float64   `parquet:"name=high, type=DOUBLE"`
	Low        float64   `parquet:"name=low, type=DOUBLE"`
	Close      float64   `parquet:"name=close, type=DOUBLE"`
	Volume     int64     `parquet:"name=volume, type=INT64"`
	TradeCount int32     `parquet:"name=trade_count, type=INT32"`
	VWAP       float64   `parquet:"name=vwap, type=DOUBLE"`
}

// Feature engineering for ML
type MLFeatures struct {
	Symbol          string    `parquet:"name=symbol, type=BYTE_ARRAY, convertedtype=UTF8"`
	Timestamp       int64     `parquet:"name=timestamp, type=INT64"`
	Price           float64   `parquet:"name=price, type=DOUBLE"`
	Returns1Min     float64   `parquet:"name=returns_1min, type=DOUBLE"`
	Returns5Min     float64   `parquet:"name=returns_5min, type=DOUBLE"`
	Returns15Min    float64   `parquet:"name=returns_15min, type=DOUBLE"`
	Volatility      float64   `parquet:"name=volatility, type=DOUBLE"`
	RSI             float64   `parquet:"name=rsi, type=DOUBLE"`
	MACD            float64   `parquet:"name=macd, type=DOUBLE"`
	BollingerUpper  float64   `parquet:"name=bollinger_upper, type=DOUBLE"`
	BollingerLower  float64   `parquet:"name=bollinger_lower, type=DOUBLE"`
	Volume          int64     `parquet:"name=volume, type=INT64"`
	VolumeMA        float64   `parquet:"name=volume_ma, type=DOUBLE"`
	SpreadBPS       float64   `parquet:"name=spread_bps, type=DOUBLE"`
	ImbalanceRatio  float64   `parquet:"name=imbalance_ratio, type=DOUBLE"`
	Label           int32     `parquet:"name=label, type=INT32"` // -1=sell, 0=hold, 1=buy
}

// Data collector manages all data streams
type DataCollector struct {
	alpacaClient   *alpaca.Client
	marketClient   *marketdata.Client
	streamClient   *stream.StocksClient
	symbols        []string
	dataDir        string
	tickBuffer     []MarketTick
	tradeBuffer    []TradeData
	barBuffer      []BarData
	featureBuffer  []MLFeatures
	mu             sync.Mutex
	wg             sync.WaitGroup
	ctx            context.Context
	cancel         context.CancelFunc
}

// Initialize data collector
func NewDataCollector(symbols []string) (*DataCollector, error) {
	// Create data directory structure
	dirs := []string{
		filepath.Join(DATA_DIR, "ticks"),
		filepath.Join(DATA_DIR, "trades"),
		filepath.Join(DATA_DIR, "bars"),
		filepath.Join(DATA_DIR, "features"),
		filepath.Join(DATA_DIR, "csv"),
		filepath.Join(DATA_DIR, "json"),
	}
	
	for _, dir := range dirs {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return nil, fmt.Errorf("failed to create directory %s: %v", dir, err)
		}
	}

	// Initialize clients
	alpacaClient := alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    ALPACA_API_KEY,
		APISecret: ALPACA_API_SECRET,
		BaseURL:   "https://paper-api.alpaca.markets",
	})

	marketClient := marketdata.NewClient(marketdata.ClientOpts{
		APIKey:    ALPACA_API_KEY,
		APISecret: ALPACA_API_SECRET,
	})

	streamClient := stream.NewStocksClient(
		marketdata.IEX,
		stream.WithCredentials(ALPACA_API_KEY, ALPACA_API_SECRET),
	)

	ctx, cancel := context.WithCancel(context.Background())

	return &DataCollector{
		alpacaClient:  &alpacaClient,
		marketClient:  &marketClient,
		streamClient:  streamClient,
		symbols:       symbols,
		dataDir:       DATA_DIR,
		tickBuffer:    make([]MarketTick, 0, 10000),
		tradeBuffer:   make([]TradeData, 0, 10000),
		barBuffer:     make([]BarData, 0, 1000),
		featureBuffer: make([]MLFeatures, 0, 1000),
		ctx:           ctx,
		cancel:        cancel,
	}, nil
}

// Start WebSocket streaming
func (dc *DataCollector) StartStreaming() error {
	fmt.Println("🌊 Starting real-time data streaming...")

	// Subscribe to quotes
	if err := dc.streamClient.SubscribeToQuotes(dc.handleQuote, dc.symbols...); err != nil {
		return fmt.Errorf("failed to subscribe to quotes: %v", err)
	}

	// Subscribe to trades
	if err := dc.streamClient.SubscribeToTrades(dc.handleTrade, dc.symbols...); err != nil {
		return fmt.Errorf("failed to subscribe to trades: %v", err)
	}

	// Subscribe to bars
	if err := dc.streamClient.SubscribeToBars(dc.handleBar, dc.symbols...); err != nil {
		return fmt.Errorf("failed to subscribe to bars: %v", err)
	}

	// Start the stream in a goroutine
	dc.wg.Add(1)
	go func() {
		defer dc.wg.Done()
		if err := dc.streamClient.Connect(dc.ctx); err != nil {
			log.Printf("Stream error: %v", err)
		}
	}()

	fmt.Println("✅ Streaming connected!")
	return nil
}

// Handle incoming quotes
func (dc *DataCollector) handleQuote(quote stream.Quote) {
	dc.mu.Lock()
	defer dc.mu.Unlock()

	tick := MarketTick{
		Symbol:    quote.Symbol,
		Timestamp: quote.Timestamp.Unix(),
		BidPrice:  quote.BidPrice,
		AskPrice:  quote.AskPrice,
		BidSize:   int32(quote.BidSize),
		AskSize:   int32(quote.AskSize),
		Spread:    quote.AskPrice - quote.BidPrice,
		MidPrice:  (quote.BidPrice + quote.AskPrice) / 2,
	}

	dc.tickBuffer = append(dc.tickBuffer, tick)

	// Flush buffer if it gets too large
	if len(dc.tickBuffer) >= 1000 {
		go dc.flushTickBuffer()
	}
}

// Handle incoming trades
func (dc *DataCollector) handleTrade(trade stream.Trade) {
	dc.mu.Lock()
	defer dc.mu.Unlock()

	t := TradeData{
		Symbol:    trade.Symbol,
		Timestamp: trade.Timestamp.Unix(),
		Price:     trade.Price,
		Size:      int32(trade.Size),
		Exchange:  string(trade.Exchange),
		ID:        fmt.Sprintf("%d", trade.ID),
		Condition: string(trade.Conditions[0]),
	}

	dc.tradeBuffer = append(dc.tradeBuffer, t)

	if len(dc.tradeBuffer) >= 1000 {
		go dc.flushTradeBuffer()
	}
}

// Handle incoming bars
func (dc *DataCollector) handleBar(bar stream.Bar) {
	dc.mu.Lock()
	defer dc.mu.Unlock()

	b := BarData{
		Symbol:     bar.Symbol,
		Timestamp:  bar.Timestamp.Unix(),
		Open:       bar.Open,
		High:       bar.High,
		Low:        bar.Low,
		Close:      bar.Close,
		Volume:     int64(bar.Volume),
		TradeCount: int32(bar.TradeCount),
		VWAP:       bar.VWAP,
	}

	dc.barBuffer = append(dc.barBuffer, b)

	if len(dc.barBuffer) >= 100 {
		go dc.flushBarBuffer()
	}
}

// Save tick buffer to Parquet
func (dc *DataCollector) flushTickBuffer() error {
	dc.mu.Lock()
	buffer := make([]MarketTick, len(dc.tickBuffer))
	copy(buffer, dc.tickBuffer)
	dc.tickBuffer = dc.tickBuffer[:0]
	dc.mu.Unlock()

	if len(buffer) == 0 {
		return nil
	}

	// Save as Parquet
	filename := fmt.Sprintf("%s/ticks/ticks_%d.parquet", dc.dataDir, time.Now().Unix())
	fw, err := local.NewLocalFileWriter(filename)
	if err != nil {
		return err
	}
	defer fw.Close()

	pw, err := writer.NewParquetWriter(fw, new(MarketTick), 4)
	if err != nil {
		return err
	}
	pw.CompressionType = parquet.CompressionCodec_SNAPPY

	for _, tick := range buffer {
		if err := pw.Write(tick); err != nil {
			return err
		}
	}

	if err := pw.WriteStop(); err != nil {
		return err
	}

	// Also save as CSV for easy viewing
	csvFile := fmt.Sprintf("%s/csv/ticks_%d.csv", dc.dataDir, time.Now().Unix())
	dc.saveTicksAsCSV(buffer, csvFile)

	fmt.Printf("💾 Saved %d ticks to %s\n", len(buffer), filename)
	return nil
}

// Save trades buffer to Parquet
func (dc *DataCollector) flushTradeBuffer() error {
	dc.mu.Lock()
	buffer := make([]TradeData, len(dc.tradeBuffer))
	copy(buffer, dc.tradeBuffer)
	dc.tradeBuffer = dc.tradeBuffer[:0]
	dc.mu.Unlock()

	if len(buffer) == 0 {
		return nil
	}

	filename := fmt.Sprintf("%s/trades/trades_%d.parquet", dc.dataDir, time.Now().Unix())
	fw, err := local.NewLocalFileWriter(filename)
	if err != nil {
		return err
	}
	defer fw.Close()

	pw, err := writer.NewParquetWriter(fw, new(TradeData), 4)
	if err != nil {
		return err
	}
	pw.CompressionType = parquet.CompressionCodec_SNAPPY

	for _, trade := range buffer {
		if err := pw.Write(trade); err != nil {
			return err
		}
	}

	if err := pw.WriteStop(); err != nil {
		return err
	}

	fmt.Printf("💾 Saved %d trades to %s\n", len(buffer), filename)
	return nil
}

// Save bars buffer to Parquet
func (dc *DataCollector) flushBarBuffer() error {
	dc.mu.Lock()
	buffer := make([]BarData, len(dc.barBuffer))
	copy(buffer, dc.barBuffer)
	dc.barBuffer = dc.barBuffer[:0]
	dc.mu.Unlock()

	if len(buffer) == 0 {
		return nil
	}

	filename := fmt.Sprintf("%s/bars/bars_%d.parquet", dc.dataDir, time.Now().Unix())
	fw, err := local.NewLocalFileWriter(filename)
	if err != nil {
		return err
	}
	defer fw.Close()

	pw, err := writer.NewParquetWriter(fw, new(BarData), 4)
	if err != nil {
		return err
	}
	pw.CompressionType = parquet.CompressionCodec_SNAPPY

	for _, bar := range buffer {
		if err := pw.Write(bar); err != nil {
			return err
		}
	}

	if err := pw.WriteStop(); err != nil {
		return err
	}

	// Generate ML features from bars
	go dc.generateMLFeatures(buffer)

	fmt.Printf("💾 Saved %d bars to %s\n", len(buffer), filename)
	return nil
}

// Generate ML features from bar data
func (dc *DataCollector) generateMLFeatures(bars []BarData) {
	// This is a simplified example - real feature engineering would be more complex
	for i, bar := range bars {
		feature := MLFeatures{
			Symbol:    bar.Symbol,
			Timestamp: bar.Timestamp,
			Price:     bar.Close,
			Volume:    bar.Volume,
		}

		// Calculate returns
		if i > 0 {
			feature.Returns1Min = (bar.Close - bars[i-1].Close) / bars[i-1].Close * 100
		}

		// Simple volatility (would use rolling window in production)
		if i > 5 {
			var sum float64
			for j := i - 5; j < i; j++ {
				sum += bars[j].High - bars[j].Low
			}
			feature.Volatility = sum / 5
		}

		// Label for supervised learning (simplified)
		if i < len(bars)-1 {
			futureReturn := (bars[i+1].Close - bar.Close) / bar.Close * 100
			if futureReturn > 0.1 {
				feature.Label = 1 // Buy signal
			} else if futureReturn < -0.1 {
				feature.Label = -1 // Sell signal
			} else {
				feature.Label = 0 // Hold
			}
		}

		dc.mu.Lock()
		dc.featureBuffer = append(dc.featureBuffer, feature)
		dc.mu.Unlock()
	}

	// Flush features if buffer is large
	if len(dc.featureBuffer) >= 100 {
		dc.flushFeatureBuffer()
	}
}

// Save ML features to Parquet
func (dc *DataCollector) flushFeatureBuffer() error {
	dc.mu.Lock()
	buffer := make([]MLFeatures, len(dc.featureBuffer))
	copy(buffer, dc.featureBuffer)
	dc.featureBuffer = dc.featureBuffer[:0]
	dc.mu.Unlock()

	if len(buffer) == 0 {
		return nil
	}

	filename := fmt.Sprintf("%s/features/features_%d.parquet", dc.dataDir, time.Now().Unix())
	fw, err := local.NewLocalFileWriter(filename)
	if err != nil {
		return err
	}
	defer fw.Close()

	pw, err := writer.NewParquetWriter(fw, new(MLFeatures), 4)
	if err != nil {
		return err
	}
	pw.CompressionType = parquet.CompressionCodec_SNAPPY

	for _, feature := range buffer {
		if err := pw.Write(feature); err != nil {
			return err
		}
	}

	if err := pw.WriteStop(); err != nil {
		return err
	}

	fmt.Printf("🤖 Saved %d ML features to %s\n", len(buffer), filename)
	return nil
}

// Save ticks as CSV for easy viewing
func (dc *DataCollector) saveTicksAsCSV(ticks []MarketTick, filename string) error {
	file, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer file.Close()

	writer := csv.NewWriter(file)
	defer writer.Flush()

	// Write header
	header := []string{"Symbol", "Timestamp", "BidPrice", "AskPrice", "BidSize", "AskSize", "Spread", "MidPrice"}
	if err := writer.Write(header); err != nil {
		return err
	}

	// Write data
	for _, tick := range ticks {
		record := []string{
			tick.Symbol,
			fmt.Sprintf("%d", tick.Timestamp),
			fmt.Sprintf("%.2f", tick.BidPrice),
			fmt.Sprintf("%.2f", tick.AskPrice),
			fmt.Sprintf("%d", tick.BidSize),
			fmt.Sprintf("%d", tick.AskSize),
			fmt.Sprintf("%.4f", tick.Spread),
			fmt.Sprintf("%.2f", tick.MidPrice),
		}
		if err := writer.Write(record); err != nil {
			return err
		}
	}

	return nil
}

// Collect historical data
func (dc *DataCollector) CollectHistoricalData(symbols []string, days int) error {
	fmt.Printf("📚 Collecting %d days of historical data for %v...\n", days, symbols)

	end := time.Now()
	start := end.AddDate(0, 0, -days)

	for _, symbol := range symbols {
		fmt.Printf("📊 Fetching bars for %s...\n", symbol)

		bars, err := dc.marketClient.GetBars(symbol, marketdata.GetBarsRequest{
			TimeFrame: marketdata.OneMin,
			Start:     start,
			End:       end,
			PageLimit: 10000,
		})

		if err != nil {
			log.Printf("Error fetching bars for %s: %v", symbol, err)
			continue
		}

		// Convert to our format and save
		var barData []BarData
		for _, bar := range bars {
			b := BarData{
				Symbol:     symbol,
				Timestamp:  bar.Timestamp.Unix(),
				Open:       bar.Open,
				High:       bar.High,
				Low:        bar.Low,
				Close:      bar.Close,
				Volume:     int64(bar.Volume),
				TradeCount: int32(bar.TradeCount),
				VWAP:       bar.VWAP,
			}
			barData = append(barData, b)
		}

		// Save historical data
		filename := fmt.Sprintf("%s/bars/historical_%s_%d.parquet", dc.dataDir, symbol, time.Now().Unix())
		if err := dc.saveHistoricalBars(barData, filename); err != nil {
			log.Printf("Error saving historical data: %v", err)
		}

		fmt.Printf("✅ Saved %d historical bars for %s\n", len(barData), symbol)

		// Generate features
		dc.generateMLFeatures(barData)
	}

	// Flush any remaining features
	dc.flushFeatureBuffer()

	return nil
}

// Save historical bars
func (dc *DataCollector) saveHistoricalBars(bars []BarData, filename string) error {
	fw, err := local.NewLocalFileWriter(filename)
	if err != nil {
		return err
	}
	defer fw.Close()

	pw, err := writer.NewParquetWriter(fw, new(BarData), 4)
	if err != nil {
		return err
	}
	pw.CompressionType = parquet.CompressionCodec_SNAPPY

	for _, bar := range bars {
		if err := pw.Write(bar); err != nil {
			return err
		}
	}

	return pw.WriteStop()
}

// Stop data collection
func (dc *DataCollector) Stop() {
	fmt.Println("🛑 Stopping data collection...")

	// Cancel context
	dc.cancel()

	// Flush remaining buffers
	dc.flushTickBuffer()
	dc.flushTradeBuffer()
	dc.flushBarBuffer()
	dc.flushFeatureBuffer()

	// Wait for goroutines
	dc.wg.Wait()

	fmt.Println("✅ Data collection stopped")
}

// Print statistics
func (dc *DataCollector) PrintStats() {
	dc.mu.Lock()
	defer dc.mu.Unlock()

	fmt.Println("\n📊 === DATA COLLECTION STATISTICS ===")
	fmt.Printf("Ticks in buffer: %d\n", len(dc.tickBuffer))
	fmt.Printf("Trades in buffer: %d\n", len(dc.tradeBuffer))
	fmt.Printf("Bars in buffer: %d\n", len(dc.barBuffer))
	fmt.Printf("Features in buffer: %d\n", len(dc.featureBuffer))

	// Check saved files
	files, _ := filepath.Glob(filepath.Join(dc.dataDir, "**/*.parquet"))
	fmt.Printf("Total Parquet files saved: %d\n", len(files))

	// Calculate total size
	var totalSize int64
	for _, file := range files {
		info, _ := os.Stat(file)
		totalSize += info.Size()
	}
	fmt.Printf("Total data size: %.2f MB\n", float64(totalSize)/1024/1024)
}

func main() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║        AI-READY DATA COLLECTION SYSTEM        ║")
	fmt.Println("║         Automated Market Data Pipeline        ║")
	fmt.Println("╚════════════════════════════════════════════════╝")

	// Symbols to collect
	symbols := []string{"AAPL", "MSFT", "GOOGL", "TSLA", "AMZN", "META", "NVDA"}

	// Initialize collector
	collector, err := NewDataCollector(symbols)
	if err != nil {
		log.Fatalf("Failed to initialize collector: %v", err)
	}

	// Collect historical data
	if err := collector.CollectHistoricalData(symbols[:3], 7); err != nil {
		log.Printf("Historical data error: %v", err)
	}

	// Start real-time streaming
	if err := collector.StartStreaming(); err != nil {
		log.Printf("Streaming error: %v", err)
	}

	// Run for specified duration
	fmt.Println("\n🚀 Collecting live market data...")
	fmt.Println("Press Ctrl+C to stop")

	// Print stats periodically
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			collector.PrintStats()
		case <-time.After(5 * time.Minute):
			fmt.Println("\n⏰ Collection period complete")
			collector.Stop()
			collector.PrintStats()
			return
		}
	}
}