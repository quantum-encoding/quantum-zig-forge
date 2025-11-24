package crypto

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"sync/atomic"
	"time"

	"github.com/gorilla/websocket"
)

// Crypto Market Data WebSocket URLs  
const (
	CRYPTO_WS_PAPER = "wss://stream.data.alpaca.markets/v1beta3/crypto/us"
	CRYPTO_WS_LIVE  = "wss://stream.data.alpaca.markets/v1beta3/crypto/us"
)

// Crypto market data message types
type CryptoWSMessage struct {
	Action string          `json:"action,omitempty"`
	Key    string          `json:"key,omitempty"`
	Secret string          `json:"secret,omitempty"`
	Quotes []string        `json:"quotes,omitempty"`
	Trades []string        `json:"trades,omitempty"`
	Bars   []string        `json:"bars,omitempty"`
	OrderBooks []string    `json:"orderbooks,omitempty"`
}

type CryptoStatusMessage struct {
	T   string `json:"T"`   // Message type
	Msg string `json:"msg"` // Status message
}

type CryptoQuote struct {
	T  string  `json:"T"`  // Message type "q"
	S  string  `json:"S"`  // Symbol
	BP float64 `json:"bp"` // Best bid price
	BS float64 `json:"bs"` // Best bid size
	AP float64 `json:"ap"` // Best ask price
	AS float64 `json:"as"` // Best ask size
	TS string  `json:"t"`  // Timestamp
}

type CryptoTrade struct {
	T  string  `json:"T"`  // Message type "t"
	S  string  `json:"S"`  // Symbol
	P  float64 `json:"p"`  // Price
	S2 float64 `json:"s"`  // Size
	TS string  `json:"t"`  // Timestamp
	TKS string `json:"tks"` // Taker side
}

type CryptoStreamBar struct {
	T  string  `json:"T"`  // Message type "b"
	S  string  `json:"S"`  // Symbol
	O  float64 `json:"o"`  // Open
	H  float64 `json:"h"`  // High
	L  float64 `json:"l"`  // Low
	C  float64 `json:"c"`  // Close
	V  float64 `json:"v"`  // Volume
	TS string  `json:"t"`  // Timestamp
	N  int64   `json:"n"`  // Number of trades
	VW float64 `json:"vw"` // VWAP
}

type CryptoOrderBook struct {
	T string `json:"T"` // Message type "o"
	S string `json:"S"` // Symbol
	B []OrderBookLevel `json:"b"` // Bids
	A []OrderBookLevel `json:"a"` // Asks
	TS string `json:"t"` // Timestamp
}

type OrderBookLevel struct {
	P float64 `json:"p"` // Price
	S float64 `json:"s"` // Size
}

// Real-time market data cache
type CryptoMarketDataCache struct {
	quotes     map[string]*CryptoQuote
	trades     map[string]*CryptoTrade
	bars       map[string]*CryptoStreamBar
	orderbooks map[string]*CryptoOrderBook
	mu         sync.RWMutex
	
	// Statistics
	quotesReceived     uint64
	tradesReceived     uint64
	barsReceived       uint64
	orderbooksReceived uint64
}

func NewCryptoMarketDataCache() *CryptoMarketDataCache {
	return &CryptoMarketDataCache{
		quotes:     make(map[string]*CryptoQuote),
		trades:     make(map[string]*CryptoTrade),
		bars:       make(map[string]*CryptoStreamBar),
		orderbooks: make(map[string]*CryptoOrderBook),
	}
}

// CryptoMarketDataStreamer handles real-time crypto market data
type CryptoMarketDataStreamer struct {
	conn           *websocket.Conn
	apiKey         string
	apiSecret      string
	url            string
	isConnected    atomic.Bool
	isAuthenticated atomic.Bool
	
	// Data cache
	cache *CryptoMarketDataCache
	
	// Subscriptions
	subscribedQuotes     []string
	subscribedTrades     []string
	subscribedBars       []string
	subscribedOrderBooks []string
	
	// Handlers
	onQuote      func(*CryptoQuote)
	onTrade      func(*CryptoTrade)
	onBar        func(*CryptoStreamBar)
	onOrderBook  func(*CryptoOrderBook)
	onConnect    func()
	onDisconnect func()
	onError      func(error)
	
	// Control
	ctx    context.Context
	cancel context.CancelFunc
	wg     sync.WaitGroup
	
	// Channels
	sendChan    chan []byte
	receiveChan chan []byte
	
	logger *log.Logger
}

// NewCryptoMarketDataStreamer creates a new crypto market data streamer
func NewCryptoMarketDataStreamer(apiKey, apiSecret string, isPaper bool) *CryptoMarketDataStreamer {
	url := CRYPTO_WS_LIVE
	if isPaper {
		url = CRYPTO_WS_PAPER
	}
	
	ctx, cancel := context.WithCancel(context.Background())
	
	return &CryptoMarketDataStreamer{
		apiKey:    apiKey,
		apiSecret: apiSecret,
		url:       url,
		ctx:       ctx,
		cancel:    cancel,
		cache:     NewCryptoMarketDataCache(),
		sendChan:  make(chan []byte, 100),
		receiveChan: make(chan []byte, 1000),
		logger:    log.New(log.Writer(), "[CRYPTO-DATA] ", log.LstdFlags|log.Lmicroseconds),
	}
}

// Connect establishes connection to crypto market data stream
func (cms *CryptoMarketDataStreamer) Connect() error {
	cms.logger.Printf("Connecting to crypto market data stream: %s", cms.url)
	
	dialer := websocket.Dialer{
		HandshakeTimeout: 10 * time.Second,
	}
	
	conn, _, err := dialer.Dial(cms.url, nil)
	if err != nil {
		return fmt.Errorf("failed to connect: %v", err)
	}
	
	cms.conn = conn
	cms.isConnected.Store(true)
	
	// Start goroutines
	cms.wg.Add(3)
	go cms.readPump()
	go cms.writePump()
	go cms.messageProcessor()
	
	// Authenticate
	if err := cms.authenticate(); err != nil {
		cms.Close()
		return fmt.Errorf("authentication failed: %v", err)
	}
	
	if cms.onConnect != nil {
		cms.onConnect()
	}
	
	cms.logger.Println("✅ Crypto market data stream connected")
	return nil
}

// Authenticate with the crypto data stream
func (cms *CryptoMarketDataStreamer) authenticate() error {
	authMsg := CryptoWSMessage{
		Action: "auth",
		Key:    cms.apiKey,
		Secret: cms.apiSecret,
	}
	
	data, err := json.Marshal(authMsg)
	if err != nil {
		return err
	}
	
	select {
	case cms.sendChan <- data:
		cms.logger.Println("Authentication message sent")
	case <-time.After(5 * time.Second):
		return fmt.Errorf("authentication timeout")
	}
	
	// Wait for authentication
	timeout := time.After(10 * time.Second)
	for {
		select {
		case <-timeout:
			return fmt.Errorf("authentication timeout")
		case <-time.After(100 * time.Millisecond):
			if cms.isAuthenticated.Load() {
				return nil
			}
		}
	}
}

// SubscribeToQuotes subscribes to real-time crypto quotes
func (cms *CryptoMarketDataStreamer) SubscribeToQuotes(symbols []string) error {
	cms.subscribedQuotes = symbols
	
	subMsg := CryptoWSMessage{
		Action: "subscribe",
		Quotes: symbols,
	}
	
	data, err := json.Marshal(subMsg)
	if err != nil {
		return err
	}
	
	select {
	case cms.sendChan <- data:
		cms.logger.Printf("✅ Subscribed to quotes: %v", symbols)
		return nil
	case <-time.After(5 * time.Second):
		return fmt.Errorf("subscription timeout")
	}
}

// SubscribeToTrades subscribes to real-time crypto trades
func (cms *CryptoMarketDataStreamer) SubscribeToTrades(symbols []string) error {
	cms.subscribedTrades = symbols
	
	subMsg := CryptoWSMessage{
		Action: "subscribe",
		Trades: symbols,
	}
	
	data, err := json.Marshal(subMsg)
	if err != nil {
		return err
	}
	
	select {
	case cms.sendChan <- data:
		cms.logger.Printf("✅ Subscribed to trades: %v", symbols)
		return nil
	case <-time.After(5 * time.Second):
		return fmt.Errorf("subscription timeout")
	}
}

// SubscribeToOrderBooks subscribes to real-time orderbooks
func (cms *CryptoMarketDataStreamer) SubscribeToOrderBooks(symbols []string) error {
	cms.subscribedOrderBooks = symbols
	
	subMsg := CryptoWSMessage{
		Action: "subscribe",
		OrderBooks: symbols,
	}
	
	data, err := json.Marshal(subMsg)
	if err != nil {
		return err
	}
	
	select {
	case cms.sendChan <- data:
		cms.logger.Printf("✅ Subscribed to orderbooks: %v", symbols)
		return nil
	case <-time.After(5 * time.Second):
		return fmt.Errorf("subscription timeout")
	}
}

// Read pump
func (cms *CryptoMarketDataStreamer) readPump() {
	defer cms.wg.Done()
	
	cms.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	cms.conn.SetPongHandler(func(string) error {
		cms.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})
	
	for {
		select {
		case <-cms.ctx.Done():
			return
		default:
			_, message, err := cms.conn.ReadMessage()
			if err != nil {
				cms.logger.Printf("Read error: %v", err)
				cms.handleDisconnect()
				return
			}
			
			select {
			case cms.receiveChan <- message:
			default:
				cms.logger.Println("Receive channel full, dropping message")
			}
		}
	}
}

// Write pump
func (cms *CryptoMarketDataStreamer) writePump() {
	defer cms.wg.Done()
	
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-cms.ctx.Done():
			return
		case message := <-cms.sendChan:
			cms.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := cms.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				cms.logger.Printf("Write error: %v", err)
				return
			}
		case <-ticker.C:
			cms.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := cms.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				cms.logger.Printf("Ping error: %v", err)
				return
			}
		}
	}
}

// Message processor
func (cms *CryptoMarketDataStreamer) messageProcessor() {
	defer cms.wg.Done()
	
	for {
		select {
		case <-cms.ctx.Done():
			return
		case message := <-cms.receiveChan:
			cms.processMessage(message)
		}
	}
}

// Process message
func (cms *CryptoMarketDataStreamer) processMessage(data []byte) {
	// Try to parse as array of messages first
	var messages []json.RawMessage
	if err := json.Unmarshal(data, &messages); err != nil {
		// Single message
		cms.processSingleMessage(data)
		return
	}
	
	// Multiple messages
	for _, msg := range messages {
		cms.processSingleMessage(msg)
	}
}

// Process single message
func (cms *CryptoMarketDataStreamer) processSingleMessage(data []byte) {
	// Try to determine message type
	var msgType map[string]interface{}
	if err := json.Unmarshal(data, &msgType); err != nil {
		return
	}
	
	switch msgType["T"] {
	case "success":
		cms.handleSuccess(data)
	case "subscription":
		cms.handleSubscription(data)
	case "q":
		cms.handleQuote(data)
	case "t":
		cms.handleTrade(data)
	case "b":
		cms.handleBar(data)
	case "o":
		cms.handleOrderBook(data)
	}
}

// Handle success message
func (cms *CryptoMarketDataStreamer) handleSuccess(data []byte) {
	var status CryptoStatusMessage
	if err := json.Unmarshal(data, &status); err != nil {
		return
	}
	
	if status.Msg == "connected" {
		cms.logger.Println("✅ Connected to crypto data stream")
	} else if status.Msg == "authenticated" {
		cms.isAuthenticated.Store(true)
		cms.logger.Println("✅ Authenticated to crypto data stream")
	}
}

// Handle subscription confirmation
func (cms *CryptoMarketDataStreamer) handleSubscription(data []byte) {
	cms.logger.Println("✅ Subscription confirmed")
}

// Handle quote message
func (cms *CryptoMarketDataStreamer) handleQuote(data []byte) {
	var quote CryptoQuote
	if err := json.Unmarshal(data, &quote); err != nil {
		return
	}
	
	atomic.AddUint64(&cms.cache.quotesReceived, 1)
	
	// Update cache
	cms.cache.mu.Lock()
	cms.cache.quotes[quote.S] = &quote
	cms.cache.mu.Unlock()
	
	// Call handler
	if cms.onQuote != nil {
		cms.onQuote(&quote)
	}
}

// Handle trade message
func (cms *CryptoMarketDataStreamer) handleTrade(data []byte) {
	var trade CryptoTrade
	if err := json.Unmarshal(data, &trade); err != nil {
		return
	}
	
	atomic.AddUint64(&cms.cache.tradesReceived, 1)
	
	// Update cache
	cms.cache.mu.Lock()
	cms.cache.trades[trade.S] = &trade
	cms.cache.mu.Unlock()
	
	// Call handler
	if cms.onTrade != nil {
		cms.onTrade(&trade)
	}
}

// Handle bar message
func (cms *CryptoMarketDataStreamer) handleBar(data []byte) {
	var bar CryptoStreamBar
	if err := json.Unmarshal(data, &bar); err != nil {
		return
	}
	
	atomic.AddUint64(&cms.cache.barsReceived, 1)
	
	// Update cache
	cms.cache.mu.Lock()
	cms.cache.bars[bar.S] = &bar
	cms.cache.mu.Unlock()
	
	// Call handler
	if cms.onBar != nil {
		cms.onBar(&bar)
	}
}

// Handle orderbook message
func (cms *CryptoMarketDataStreamer) handleOrderBook(data []byte) {
	var orderbook CryptoOrderBook
	if err := json.Unmarshal(data, &orderbook); err != nil {
		return
	}
	
	atomic.AddUint64(&cms.cache.orderbooksReceived, 1)
	
	// Update cache
	cms.cache.mu.Lock()
	cms.cache.orderbooks[orderbook.S] = &orderbook
	cms.cache.mu.Unlock()
	
	// Call handler
	if cms.onOrderBook != nil {
		cms.onOrderBook(&orderbook)
	}
}

// Handle disconnection
func (cms *CryptoMarketDataStreamer) handleDisconnect() {
	cms.isConnected.Store(false)
	cms.isAuthenticated.Store(false)
	
	if cms.onDisconnect != nil {
		cms.onDisconnect()
	}
}

// Close connection
func (cms *CryptoMarketDataStreamer) Close() error {
	cms.logger.Println("Closing crypto market data stream...")
	
	cms.cancel()
	
	if cms.conn != nil {
		cms.conn.Close()
	}
	
	cms.wg.Wait()
	cms.logger.Println("Crypto market data stream closed")
	return nil
}

// Get latest quote for symbol
func (cms *CryptoMarketDataStreamer) GetLatestQuote(symbol string) *CryptoQuote {
	cms.cache.mu.RLock()
	defer cms.cache.mu.RUnlock()
	
	return cms.cache.quotes[symbol]
}

// Get latest trade for symbol
func (cms *CryptoMarketDataStreamer) GetLatestTrade(symbol string) *CryptoTrade {
	cms.cache.mu.RLock()
	defer cms.cache.mu.RUnlock()
	
	return cms.cache.trades[symbol]
}

// Get latest orderbook for symbol
func (cms *CryptoMarketDataStreamer) GetLatestOrderBook(symbol string) *CryptoOrderBook {
	cms.cache.mu.RLock()
	defer cms.cache.mu.RUnlock()
	
	return cms.cache.orderbooks[symbol]
}

// Get statistics
func (cms *CryptoMarketDataStreamer) GetStatistics() (quotes, trades, bars, orderbooks uint64) {
	return atomic.LoadUint64(&cms.cache.quotesReceived),
		atomic.LoadUint64(&cms.cache.tradesReceived),
		atomic.LoadUint64(&cms.cache.barsReceived),
		atomic.LoadUint64(&cms.cache.orderbooksReceived)
}

// Set handlers
func (cms *CryptoMarketDataStreamer) SetQuoteHandler(handler func(*CryptoQuote)) {
	cms.onQuote = handler
}

func (cms *CryptoMarketDataStreamer) SetTradeHandler(handler func(*CryptoTrade)) {
	cms.onTrade = handler
}

func (cms *CryptoMarketDataStreamer) SetBarHandler(handler func(*CryptoStreamBar)) {
	cms.onBar = handler
}

func (cms *CryptoMarketDataStreamer) SetOrderBookHandler(handler func(*CryptoOrderBook)) {
	cms.onOrderBook = handler
}

func (cms *CryptoMarketDataStreamer) SetConnectHandler(handler func()) {
	cms.onConnect = handler
}

func (cms *CryptoMarketDataStreamer) SetDisconnectHandler(handler func()) {
	cms.onDisconnect = handler
}

func (cms *CryptoMarketDataStreamer) SetErrorHandler(handler func(error)) {
	cms.onError = handler
}

// IsConnected returns connection status
func (cms *CryptoMarketDataStreamer) IsConnected() bool {
	return cms.isConnected.Load()
}

// Demo function for crypto market data streaming
func RunCryptoMarketDataDemo() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║        CRYPTO MARKET DATA STREAMING           ║")
	fmt.Println("║           Real-Time WebSocket Feed            ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	// Initialize market data streamer
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	streamer := NewCryptoMarketDataStreamer(apiKey, apiSecret, true)
	
	// Set up handlers
	streamer.SetQuoteHandler(func(quote *CryptoQuote) {
		fmt.Printf("📊 %s Quote: Bid $%.4f×%.4f | Ask $%.4f×%.4f\n",
			quote.S, quote.BP, quote.BS, quote.AP, quote.AS)
	})
	
	streamer.SetTradeHandler(func(trade *CryptoTrade) {
		fmt.Printf("💸 %s Trade: $%.4f × %.4f (%s)\n",
			trade.S, trade.P, trade.S2, trade.TKS)
	})
	
	streamer.SetOrderBookHandler(func(ob *CryptoOrderBook) {
		fmt.Printf("📖 %s OrderBook: %d bids, %d asks\n",
			ob.S, len(ob.B), len(ob.A))
	})
	
	// Connect to stream
	fmt.Println("\n🔌 Connecting to crypto market data stream...")
	if err := streamer.Connect(); err != nil {
		fmt.Printf("❌ Connection failed: %v\n", err)
		return
	}
	
	// Subscribe to major crypto pairs
	symbols := []string{"BTC/USD", "ETH/USD", "LTC/USD"}
	
	fmt.Println("\n📡 Subscribing to market data...")
	if err := streamer.SubscribeToQuotes(symbols); err != nil {
		fmt.Printf("❌ Quote subscription failed: %v\n", err)
	}
	
	if err := streamer.SubscribeToTrades(symbols); err != nil {
		fmt.Printf("❌ Trade subscription failed: %v\n", err)
	}
	
	if err := streamer.SubscribeToOrderBooks(symbols); err != nil {
		fmt.Printf("❌ OrderBook subscription failed: %v\n", err)
	}
	
	// Stream for demo period
	fmt.Println("\n📈 Streaming real-time crypto market data...")
	fmt.Println("   (Demo will run for 30 seconds)")
	
	time.Sleep(30 * time.Second)
	
	// Show statistics
	quotes, trades, bars, orderbooks := streamer.GetStatistics()
	fmt.Printf("\n📊 Market Data Statistics:\n")
	fmt.Printf("   Quotes received: %d\n", quotes)
	fmt.Printf("   Trades received: %d\n", trades)
	fmt.Printf("   Bars received: %d\n", bars)
	fmt.Printf("   OrderBooks received: %d\n", orderbooks)
	
	// Show latest data
	fmt.Println("\n📋 Latest Market Data:")
	for _, symbol := range symbols {
		if quote := streamer.GetLatestQuote(symbol); quote != nil {
			fmt.Printf("   %s: Bid $%.4f | Ask $%.4f\n",
				symbol, quote.BP, quote.AP)
		}
		
		if trade := streamer.GetLatestTrade(symbol); trade != nil {
			fmt.Printf("   %s Last Trade: $%.4f × %.4f\n",
				symbol, trade.P, trade.S2)
		}
	}
	
	// Close connection
	streamer.Close()
	
	fmt.Println("\n╔════════════════════════════════════════════════╗")
	fmt.Println("║     CRYPTO MARKET DATA DEMO COMPLETE!         ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  ✅ Real-time quotes streaming                ║")
	fmt.Println("║  ✅ Live trade execution data                 ║")
	fmt.Println("║  ✅ Dynamic orderbook updates                 ║")
	fmt.Println("║  ✅ Multi-symbol WebSocket feeds              ║")
	fmt.Println("║  ✅ 24/7 crypto data coverage                 ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  THE GREAT SYNAPSE SEES ALL CRYPTO FLOWS!     ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
}