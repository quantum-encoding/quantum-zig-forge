// ALPACA SENSORY ORGANS - The Go WebSocket Client
// Trinity Architecture Component #1

package alpaca

/*
#cgo CFLAGS: -O3 -march=native
#cgo LDFLAGS: -lpthread

#include <stdint.h>
#include <stdatomic.h>
#include <stdlib.h>
#include <string.h>

// MarketPacket structure - must match Zig exactly (64 bytes)
typedef struct __attribute__((packed)) {
    uint64_t timestamp_ns;
    uint32_t symbol_id;
    uint8_t  packet_type;
    uint8_t  flags;
    uint64_t price;      // Reuse for bid or trade price
    uint32_t quantity;   // Reuse for bid or trade quantity  
    uint32_t order_id;
    uint8_t  side;
    uint8_t  _padding[23];
} MarketPacket;

// Ring buffer structure
typedef struct {
    uint8_t* buffer;
    size_t size;
    size_t mask;
    _Atomic size_t producer_head;
    _Atomic size_t consumer_head;
    char padding[64];
} RingBuffer;

void* create_ring_buffer(size_t size) {
    size_t actual_size = 1;
    while (actual_size < size) actual_size <<= 1;
    
    RingBuffer* ring = calloc(1, sizeof(RingBuffer));
    if (!ring) return NULL;
    
    ring->buffer = calloc(actual_size, 1);
    if (!ring->buffer) {
        free(ring);
        return NULL;
    }
    
    ring->size = actual_size;
    ring->mask = actual_size - 1;
    atomic_store(&ring->producer_head, 0);
    atomic_store(&ring->consumer_head, 0);
    
    return ring;
}

void destroy_ring_buffer(void* ring_ptr) {
    if (!ring_ptr) return;
    RingBuffer* ring = (RingBuffer*)ring_ptr;
    if (ring->buffer) free(ring->buffer);
    free(ring);
}

int write_market_packet(void* ring_ptr, MarketPacket* packet) {
    RingBuffer* ring = (RingBuffer*)ring_ptr;
    if (!ring || !packet) return 0;
    
    const size_t packet_size = sizeof(MarketPacket);
    
    size_t producer = atomic_load_explicit(&ring->producer_head, memory_order_relaxed);
    size_t consumer = atomic_load_explicit(&ring->consumer_head, memory_order_acquire);
    
    if ((producer - consumer) * packet_size >= ring->size) {
        return 0; // Ring full
    }
    
    size_t index = (producer * packet_size) & ring->mask;
    memcpy(ring->buffer + index, packet, packet_size);
    
    atomic_store_explicit(&ring->producer_head, producer + 1, memory_order_release);
    return 1;
}
*/
import "C"

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/signal"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
	"unsafe"

	"github.com/gorilla/websocket"
)

type AlpacaSensoryOrgans struct {
	apiKey    string
	apiSecret string
	conn      *websocket.Conn
	
	marketDataRing unsafe.Pointer
	symbolMap      map[string]uint32
	symbolMu       sync.RWMutex
	nextSymID      uint32
	
	packetsWritten uint64
	wsMessages     uint64
	
	stopChan chan struct{}
	wg       sync.WaitGroup
}

// Alpaca message types
type AlpacaQuote struct {
	T  string  `json:"T"`
	S  string  `json:"S"`
	Bp float64 `json:"bp"`
	Bs int     `json:"bs"`
	Ap float64 `json:"ap"`
	As int     `json:"as"`
	T_ int64   `json:"t"`
}

type AlpacaTrade struct {
	T  string  `json:"T"`
	S  string  `json:"S"`
	P  float64 `json:"p"`
	S_ int     `json:"s"`
	T_ int64   `json:"t"`
}

func NewAlpacaSensoryOrgans(apiKey, apiSecret string) *AlpacaSensoryOrgans {
	return &AlpacaSensoryOrgans{
		apiKey:    apiKey,
		apiSecret: apiSecret,
		symbolMap: make(map[string]uint32),
		stopChan:  make(chan struct{}),
	}
}

func (a *AlpacaSensoryOrgans) Initialize() error {
	log.Println("🧠 Initializing Trinity Sensory Organs...")
	
	// Create ring buffer (1MB for ~16k packets)
	a.marketDataRing = C.create_ring_buffer(1048576)
	if a.marketDataRing == nil {
		return fmt.Errorf("failed to create ring buffer")
	}
	
	log.Println("✅ Ring buffer created (1MB)")
	return nil
}

func (a *AlpacaSensoryOrgans) Connect() error {
	wsURL := "wss://stream.data.alpaca.markets/v2/iex"
	
	log.Printf("📡 Connecting to REAL Alpaca WebSocket: %s\n", wsURL)
	
	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		return fmt.Errorf("WebSocket dial failed: %v", err)
	}
	
	a.conn = conn
	log.Println("✅ REAL WebSocket connected")
	
	// Authenticate
	auth := map[string]interface{}{
		"action": "auth",
		"key":    a.apiKey,
		"secret": a.apiSecret,
	}
	
	if err := a.conn.WriteJSON(auth); err != nil {
		return fmt.Errorf("auth failed: %v", err)
	}
	
	// Read auth response
	_, msg, err := a.conn.ReadMessage()
	if err != nil {
		return fmt.Errorf("auth response failed: %v", err)
	}
	
	log.Printf("🔐 Auth response: %s\n", string(msg))
	
	// Start reader
	a.wg.Add(1)
	go a.readLoop()
	
	return nil
}

func (a *AlpacaSensoryOrgans) Subscribe(symbols []string) error {
	// Map symbols
	a.symbolMu.Lock()
	for _, symbol := range symbols {
		if _, exists := a.symbolMap[symbol]; !exists {
			a.symbolMap[symbol] = a.nextSymID
			a.nextSymID++
			log.Printf("  Symbol %s -> ID %d\n", symbol, a.symbolMap[symbol])
		}
	}
	a.symbolMu.Unlock()
	
	// Subscribe
	sub := map[string]interface{}{
		"action": "subscribe",
		"quotes": symbols,
		"trades": symbols,
	}
	
	if err := a.conn.WriteJSON(sub); err != nil {
		return err
	}
	
	log.Printf("📊 Subscribed to %d symbols\n", len(symbols))
	return nil
}

func (a *AlpacaSensoryOrgans) readLoop() {
	defer a.wg.Done()
	log.Println("👂 Read loop started")
	
	for {
		select {
		case <-a.stopChan:
			return
		default:
		}
		
		_, message, err := a.conn.ReadMessage()
		if err != nil {
			log.Printf("Read error: %v\n", err)
			return
		}
		
		atomic.AddUint64(&a.wsMessages, 1)
		
		// Parse array of messages
		var messages []json.RawMessage
		if err := json.Unmarshal(message, &messages); err != nil {
			continue
		}
		
		for _, msg := range messages {
			var msgType struct {
				T string `json:"T"`
			}
			
			if err := json.Unmarshal(msg, &msgType); err != nil {
				continue
			}
			
			switch msgType.T {
			case "q":
				var quote AlpacaQuote
				if err := json.Unmarshal(msg, &quote); err == nil {
					a.processQuote(&quote)
				}
			case "t":
				var trade AlpacaTrade
				if err := json.Unmarshal(msg, &trade); err == nil {
					a.processTrade(&trade)
				}
			case "success":
				log.Printf("✅ %s\n", string(msg))
			case "error":
				log.Printf("❌ %s\n", string(msg))
			}
		}
	}
}

func (a *AlpacaSensoryOrgans) processQuote(quote *AlpacaQuote) {
	a.symbolMu.RLock()
	symbolID, exists := a.symbolMap[quote.S]
	a.symbolMu.RUnlock()
	
	if !exists {
		return
	}
	
	// Send bid as one packet
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
	
	// Send ask as another packet
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
		
		// Log first few packets
		if atomic.LoadUint64(&a.packetsWritten) <= 10 {
			log.Printf("📈 QUOTE %s: Bid $%.2f x %d, Ask $%.2f x %d\n",
				quote.S, quote.Bp, quote.Bs, quote.Ap, quote.As)
		}
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
		
		// Log first few packets
		if atomic.LoadUint64(&a.packetsWritten) <= 10 {
			log.Printf("💹 TRADE %s: $%.2f x %d\n", trade.S, trade.P, trade.S_)
		}
	}
}

func (a *AlpacaSensoryOrgans) ReportStats() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	
	var lastPackets uint64
	
	for {
		select {
		case <-ticker.C:
			packets := atomic.LoadUint64(&a.packetsWritten)
			messages := atomic.LoadUint64(&a.wsMessages)
			rate := (packets - lastPackets) / 5
			lastPackets = packets
			
			log.Printf("📊 STATS: Messages: %d | Packets: %d | Rate: %d pkt/s\n",
				messages, packets, rate)
				
		case <-a.stopChan:
			return
		}
	}
}

func (a *AlpacaSensoryOrgans) Shutdown() {
	log.Println("🛑 Shutting down...")
	close(a.stopChan)
	
	if a.conn != nil {
		a.conn.Close()
	}
	
	a.wg.Wait()
	
	if a.marketDataRing != nil {
		C.destroy_ring_buffer(a.marketDataRing)
	}
}

func main() {
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	if apiKey == "" || apiSecret == "" {
		log.Fatal("❌ API credentials not set")
	}
	
	log.Println("╔════════════════════════════════════════════════════╗")
	log.Println("║        ALPACA TRINITY SENSORY ORGANS V1.0          ║")
	log.Println("║           Real WebSocket, Real Data                ║")
	log.Println("╚════════════════════════════════════════════════════╝")
	
	organs := NewAlpacaSensoryOrgans(apiKey, apiSecret)
	
	if err := organs.Initialize(); err != nil {
		log.Fatal(err)
	}
	
	if err := organs.Connect(); err != nil {
		log.Fatal(err)
	}
	
	// Subscribe to symbols
	symbols := []string{"SPY", "QQQ", "AAPL", "MSFT", "NVDA", "AMD"}
	if err := organs.Subscribe(symbols); err != nil {
		log.Fatal(err)
	}
	
	go organs.ReportStats()
	
	// Handle shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	<-sigChan
	
	organs.Shutdown()
	log.Println("✅ Clean shutdown")
}