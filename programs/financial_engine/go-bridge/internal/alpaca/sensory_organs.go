// ALPACA SENSORY ORGANS - The Go WebSocket Client
// This is the Trinity's connection to reality
// It receives market data and converts it to binary packets for the Zig brain

package alpaca

/*
#include <stdint.h>
#include <string.h>

// MarketPacket structure - must match Zig definition exactly
typedef struct __attribute__((packed)) {
    uint64_t timestamp_ns;
    uint32_t symbol_id;
    uint8_t  packet_type;  // 0=quote, 1=trade
    uint8_t  flags;
    uint64_t price;        // Fixed point: multiply float by 1,000,000
    uint32_t quantity;
    uint32_t order_id;
    uint8_t  side;         // 0=bid, 1=ask
    uint8_t  _padding[7];
} MarketPacket;

// Order structure - must match Zig definition exactly  
typedef struct __attribute__((packed)) {
    uint32_t symbol_id;
    uint8_t  side;         // 0=buy, 1=sell
    uint64_t price;        // Fixed point
    uint32_t quantity;
    uint64_t timestamp_ns;
    uint8_t  strategy_id;
    uint8_t  _padding[7];
} Order;

// Ring buffer functions from our CGO bridge
extern void* create_ring_buffer(size_t size);
extern void destroy_ring_buffer(void* ring);
extern int write_market_packet(void* ring, MarketPacket* packet);
extern int read_order(void* ring, Order* order);
*/
import "C"

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"strings"
	"sync"
	"sync/atomic"
	"time"
	"unsafe"

	"github.com/gorilla/websocket"
)

// AlpacaSensoryOrgans - The Go component that interfaces with Alpaca WebSocket
type AlpacaSensoryOrgans struct {
	// Alpaca credentials
	apiKey    string
	apiSecret string
	paperMode bool

	// WebSocket connection
	conn *websocket.Conn
	
	// Ring buffers (shared with Zig)
	marketDataRing unsafe.Pointer
	orderRing      unsafe.Pointer
	
	// Symbol mapping
	symbolMap map[string]uint32
	symbolMu  sync.RWMutex
	nextSymID uint32
	
	// Statistics
	packetsWritten uint64
	ordersRead     uint64
	wsMessages     uint64
	
	// Control
	stopChan chan struct{}
	wg       sync.WaitGroup
}

// AlpacaMessage types
type AlpacaAuthResponse struct {
	T   string `json:"T"`
	Msg string `json:"msg"`
	Code int   `json:"code"`
}

type AlpacaQuote struct {
	T  string  `json:"T"`  // Message type "q"
	S  string  `json:"S"`  // Symbol
	Bp float64 `json:"bp"` // Bid price
	Bs int     `json:"bs"` // Bid size
	Ap float64 `json:"ap"` // Ask price
	As int     `json:"as"` // Ask size
	T_ int64   `json:"t"`  // Timestamp
}

type AlpacaTrade struct {
	T  string  `json:"T"`  // Message type "t"
	S  string  `json:"S"`  // Symbol
	P  float64 `json:"p"`  // Price
	S_ int     `json:"s"`  // Size
	T_ int64   `json:"t"`  // Timestamp
}

func NewAlpacaSensoryOrgans(apiKey, apiSecret string, paperMode bool) *AlpacaSensoryOrgans {
	return &AlpacaSensoryOrgans{
		apiKey:    apiKey,
		apiSecret: apiSecret,
		paperMode: paperMode,
		symbolMap: make(map[string]uint32),
		stopChan:  make(chan struct{}),
	}
}

func (a *AlpacaSensoryOrgans) Initialize() error {
	log.Println("🧠 Initializing Alpaca Sensory Organs...")
	
	// Create ring buffers (64KB each, ~1000 packets)
	a.marketDataRing = C.create_ring_buffer(65536)
	a.orderRing = C.create_ring_buffer(65536)
	
	if a.marketDataRing == nil || a.orderRing == nil {
		return fmt.Errorf("failed to create ring buffers")
	}
	
	log.Println("✅ Ring buffers created")
	return nil
}

func (a *AlpacaSensoryOrgans) Connect() error {
	var wsURL string
	if a.paperMode {
		wsURL = "wss://stream.data.alpaca.markets/v2/iex"
	} else {
		wsURL = "wss://stream.data.alpaca.markets/v2/sip"
	}
	
	log.Printf("📡 Connecting to Alpaca WebSocket: %s\n", wsURL)
	
	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		return fmt.Errorf("WebSocket dial failed: %v", err)
	}
	
	a.conn = conn
	log.Println("✅ WebSocket connected")
	
	// Authenticate
	if err := a.authenticate(); err != nil {
		conn.Close()
		return err
	}
	
	// Start reader goroutine
	a.wg.Add(1)
	go a.readLoop()
	
	// Start order executor goroutine
	a.wg.Add(1)
	go a.orderExecutor()
	
	return nil
}

func (a *AlpacaSensoryOrgans) authenticate() error {
	auth := map[string]interface{}{
		"action": "auth",
		"key":    a.apiKey,
		"secret": a.apiSecret,
	}
	
	if err := a.conn.WriteJSON(auth); err != nil {
		return fmt.Errorf("auth send failed: %v", err)
	}
	
	// Read auth response
	var response []AlpacaAuthResponse
	if err := a.conn.ReadJSON(&response); err != nil {
		return fmt.Errorf("auth response read failed: %v", err)
	}
	
	if len(response) > 0 && response[0].T == "success" {
		log.Println("✅ Authentication successful")
		return nil
	}
	
	return fmt.Errorf("authentication failed: %v", response)
}

func (a *AlpacaSensoryOrgans) Subscribe(symbols []string) error {
	// Map symbols to IDs
	a.symbolMu.Lock()
	for _, symbol := range symbols {
		if _, exists := a.symbolMap[symbol]; !exists {
			a.symbolMap[symbol] = a.nextSymID
			a.nextSymID++
		}
	}
	a.symbolMu.Unlock()
	
	// Subscribe to quotes and trades
	sub := map[string]interface{}{
		"action": "subscribe",
		"quotes": symbols,
		"trades": symbols,
	}
	
	if err := a.conn.WriteJSON(sub); err != nil {
		return fmt.Errorf("subscription failed: %v", err)
	}
	
	log.Printf("📊 Subscribed to %d symbols\n", len(symbols))
	return nil
}

func (a *AlpacaSensoryOrgans) readLoop() {
	defer a.wg.Done()
	log.Println("👂 WebSocket read loop started")
	
	for {
		select {
		case <-a.stopChan:
			return
		default:
		}
		
		_, message, err := a.conn.ReadMessage()
		if err != nil {
			log.Printf("WebSocket read error: %v\n", err)
			return
		}
		
		atomic.AddUint64(&a.wsMessages, 1)
		
		// Parse and process message
		a.processMessage(message)
	}
}

func (a *AlpacaSensoryOrgans) processMessage(data []byte) {
	// Alpaca sends arrays of messages
	var messages []json.RawMessage
	if err := json.Unmarshal(data, &messages); err != nil {
		// Try single message
		a.processSingleMessage(data)
		return
	}
	
	for _, msg := range messages {
		a.processSingleMessage(msg)
	}
}

func (a *AlpacaSensoryOrgans) processSingleMessage(data []byte) {
	// Determine message type
	var msgType struct {
		T string `json:"T"`
	}
	
	if err := json.Unmarshal(data, &msgType); err != nil {
		return
	}
	
	switch msgType.T {
	case "q": // Quote
		var quote AlpacaQuote
		if err := json.Unmarshal(data, &quote); err == nil {
			a.processQuote(&quote)
		}
		
	case "t": // Trade
		var trade AlpacaTrade
		if err := json.Unmarshal(data, &trade); err == nil {
			a.processTrade(&trade)
		}
		
	case "success", "subscription":
		log.Printf("✅ %s\n", string(data))
		
	case "error":
		log.Printf("❌ Alpaca error: %s\n", string(data))
	}
}

func (a *AlpacaSensoryOrgans) processQuote(quote *AlpacaQuote) {
	a.symbolMu.RLock()
	symbolID, exists := a.symbolMap[quote.S]
	a.symbolMu.RUnlock()
	
	if !exists {
		return
	}
	
	// Create bid packet
	bidPacket := C.MarketPacket{
		timestamp_ns: C.uint64_t(time.Now().UnixNano()),
		symbol_id:    C.uint32_t(symbolID),
		packet_type:  0, // Quote
		flags:        0,
		price:        C.uint64_t(quote.Bp * 1_000_000),
		quantity:     C.uint32_t(quote.Bs),
		order_id:     0,
		side:         0, // Bid
	}
	
	if C.write_market_packet(a.marketDataRing, &bidPacket) == 1 {
		atomic.AddUint64(&a.packetsWritten, 1)
	}
	
	// Create ask packet
	askPacket := C.MarketPacket{
		timestamp_ns: C.uint64_t(time.Now().UnixNano()),
		symbol_id:    C.uint32_t(symbolID),
		packet_type:  0, // Quote
		flags:        0,
		price:        C.uint64_t(quote.Ap * 1_000_000),
		quantity:     C.uint32_t(quote.As),
		order_id:     0,
		side:         1, // Ask
	}
	
	if C.write_market_packet(a.marketDataRing, &askPacket) == 1 {
		atomic.AddUint64(&a.packetsWritten, 1)
	}
}

func (a *AlpacaSensoryOrgans) processTrade(trade *AlpacaTrade) {
	a.symbolMu.RLock()
	symbolID, exists := a.symbolMap[trade.S]
	a.symbolMu.RUnlock()
	
	if !exists {
		return
	}
	
	packet := C.MarketPacket{
		timestamp_ns: C.uint64_t(time.Now().UnixNano()),
		symbol_id:    C.uint32_t(symbolID),
		packet_type:  1, // Trade
		flags:        0,
		price:        C.uint64_t(trade.P * 1_000_000),
		quantity:     C.uint32_t(trade.S_),
		order_id:     0,
		side:         2, // Trade (neither bid nor ask)
	}
	
	if C.write_market_packet(a.marketDataRing, &packet) == 1 {
		atomic.AddUint64(&a.packetsWritten, 1)
	}
}

func (a *AlpacaSensoryOrgans) orderExecutor() {
	defer a.wg.Done()
	log.Println("📤 Order executor started")
	
	var order C.Order
	
	for {
		select {
		case <-a.stopChan:
			return
		default:
		}
		
		// Check for orders from Zig
		if C.read_order(a.orderRing, &order) == 1 {
			atomic.AddUint64(&a.ordersRead, 1)
			a.executeOrder(&order)
		} else {
			time.Sleep(100 * time.Microsecond)
		}
	}
}

func (a *AlpacaSensoryOrgans) executeOrder(order *C.Order) {
	// Find symbol name
	var symbol string
	a.symbolMu.RLock()
	for sym, id := range a.symbolMap {
		if id == uint32(order.symbol_id) {
			symbol = sym
			break
		}
	}
	a.symbolMu.RUnlock()
	
	side := "buy"
	if order.side == 1 {
		side = "sell"
	}
	
	price := float64(order.price) / 1_000_000.0
	
	log.Printf("🎯 EXECUTE ORDER: %s %d %s @ $%.2f\n", 
		side, order.quantity, symbol, price)
	
	// Here you would call the Alpaca REST API to place the order
	// For now, we'll just log it
}

func (a *AlpacaSensoryOrgans) ReportStats() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-ticker.C:
			log.Printf("📊 STATS: WS Messages: %d | Packets Written: %d | Orders Read: %d\n",
				atomic.LoadUint64(&a.wsMessages),
				atomic.LoadUint64(&a.packetsWritten),
				atomic.LoadUint64(&a.ordersRead))
				
		case <-a.stopChan:
			return
		}
	}
}

func (a *AlpacaSensoryOrgans) Shutdown() {
	log.Println("🛑 Shutting down Alpaca Sensory Organs...")
	
	close(a.stopChan)
	
	if a.conn != nil {
		a.conn.Close()
	}
	
	a.wg.Wait()
	
	if a.marketDataRing != nil {
		C.destroy_ring_buffer(a.marketDataRing)
	}
	
	if a.orderRing != nil {
		C.destroy_ring_buffer(a.orderRing)
	}
	
	log.Println("✅ Shutdown complete")
}

func main() {
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	if apiKey == "" || apiSecret == "" {
		log.Fatal("❌ APCA_API_KEY_ID and APCA_API_SECRET_KEY must be set")
	}
	
	log.Println("╔════════════════════════════════════════════════════╗")
	log.Println("║         ALPACA SENSORY ORGANS ACTIVATED            ║")
	log.Println("║          The Trinity Architecture Lives            ║")
	log.Println("╚════════════════════════════════════════════════════╝")
	
	organs := NewAlpacaSensoryOrgans(apiKey, apiSecret, true)
	
	if err := organs.Initialize(); err != nil {
		log.Fatal(err)
	}
	
	if err := organs.Connect(); err != nil {
		log.Fatal(err)
	}
	
	// Subscribe to key symbols
	symbols := []string{"SPY", "QQQ", "AAPL", "MSFT", "NVDA", "TSLA", "AMD", "META"}
	if err := organs.Subscribe(symbols); err != nil {
		log.Fatal(err)
	}
	
	// Start stats reporter
	go organs.ReportStats()
	
	// Wait forever (or until interrupted)
	select {}
}