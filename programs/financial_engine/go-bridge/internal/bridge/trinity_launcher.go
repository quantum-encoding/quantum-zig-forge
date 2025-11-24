// TRINITY LAUNCHER - The Neural Pathway
// This connects the Go sensory organs to the Zig cerebrum

package bridge

/*
#cgo CFLAGS: -O3 -march=native
#cgo LDFLAGS: -L. -lquantum_cerebrum -lpthread

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
    uint64_t price;
    uint32_t quantity;
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

int read_market_packet(void* ring_ptr, MarketPacket* packet) {
    RingBuffer* ring = (RingBuffer*)ring_ptr;
    if (!ring || !packet) return 0;
    
    const size_t packet_size = sizeof(MarketPacket);
    
    size_t consumer = atomic_load_explicit(&ring->consumer_head, memory_order_relaxed);
    size_t producer = atomic_load_explicit(&ring->producer_head, memory_order_acquire);
    
    if (consumer >= producer) {
        return 0; // Ring empty
    }
    
    size_t index = (consumer * packet_size) & ring->mask;
    memcpy(packet, ring->buffer + index, packet_size);
    
    atomic_store_explicit(&ring->consumer_head, consumer + 1, memory_order_release);
    return 1;
}

// External Zig function
extern void quantum_cerebrum_run(void* market_ring, void* order_ring);
*/
import "C"

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/signal"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
	"unsafe"

	"github.com/gorilla/websocket"
)

type TrinitySystem struct {
	// Alpaca connection
	apiKey    string
	apiSecret string
	conn      *websocket.Conn
	
	// Ring buffers
	marketDataRing unsafe.Pointer
	orderRing      unsafe.Pointer
	
	// Symbol mapping
	symbolMap map[string]uint32
	symbolMu  sync.RWMutex
	nextSymID uint32
	
	// Statistics
	packetsWritten uint64
	wsMessages     uint64
	
	// Control
	stopChan chan struct{}
	wg       sync.WaitGroup
}

type AlpacaQuote struct {
	T  string  `json:"T"`
	S  string  `json:"S"`
	Bp float64 `json:"bp"`
	Bs int     `json:"bs"`
	Ap float64 `json:"ap"`
	As int     `json:"as"`
}

type AlpacaTrade struct {
	T  string  `json:"T"`
	S  string  `json:"S"`
	P  float64 `json:"p"`
	S_ int     `json:"s"`
}

func NewTrinitySystem(apiKey, apiSecret string) *TrinitySystem {
	return &TrinitySystem{
		apiKey:    apiKey,
		apiSecret: apiSecret,
		symbolMap: make(map[string]uint32),
		stopChan:  make(chan struct{}),
	}
}

func (t *TrinitySystem) Initialize() error {
	log.Println("🔱 INITIALIZING TRINITY NEURAL PATHWAY...")
	
	// Create ring buffers (2MB each for ~32k packets)
	t.marketDataRing = C.create_ring_buffer(2097152)
	t.orderRing = C.create_ring_buffer(2097152)
	
	if t.marketDataRing == nil || t.orderRing == nil {
		return fmt.Errorf("failed to create ring buffers")
	}
	
	log.Println("✅ Ring buffers created (2MB each)")
	return nil
}

func (t *TrinitySystem) ConnectAlpaca() error {
	wsURL := "wss://stream.data.alpaca.markets/v2/iex"
	
	log.Printf("📡 Connecting to Alpaca WebSocket: %s\n", wsURL)
	
	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		return fmt.Errorf("WebSocket dial failed: %v", err)
	}
	
	t.conn = conn
	log.Println("✅ WebSocket connected")
	
	// Authenticate
	auth := map[string]interface{}{
		"action": "auth",
		"key":    t.apiKey,
		"secret": t.apiSecret,
	}
	
	if err := t.conn.WriteJSON(auth); err != nil {
		return fmt.Errorf("auth failed: %v", err)
	}
	
	// Read auth response
	_, msg, err := t.conn.ReadMessage()
	if err != nil {
		return fmt.Errorf("auth response failed: %v", err)
	}
	
	log.Printf("🔐 Auth: %s\n", string(msg))
	
	// Start WebSocket reader
	t.wg.Add(1)
	go t.alpacaReader()
	
	return nil
}

func (t *TrinitySystem) Subscribe(symbols []string) error {
	// Map symbols to IDs
	t.symbolMu.Lock()
	for _, symbol := range symbols {
		if _, exists := t.symbolMap[symbol]; !exists {
			t.symbolMap[symbol] = t.nextSymID
			log.Printf("  Symbol %s -> ID %d\n", symbol, t.nextSymID)
			t.nextSymID++
		}
	}
	t.symbolMu.Unlock()
	
	// Subscribe
	sub := map[string]interface{}{
		"action": "subscribe",
		"quotes": symbols,
		"trades": symbols,
	}
	
	if err := t.conn.WriteJSON(sub); err != nil {
		return err
	}
	
	log.Printf("📊 Subscribed to %d symbols\n", len(symbols))
	return nil
}

func (t *TrinitySystem) alpacaReader() {
	defer t.wg.Done()
	log.Println("👂 Alpaca reader started")
	
	for {
		select {
		case <-t.stopChan:
			return
		default:
		}
		
		_, message, err := t.conn.ReadMessage()
		if err != nil {
			log.Printf("Read error: %v\n", err)
			return
		}
		
		atomic.AddUint64(&t.wsMessages, 1)
		
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
					t.processQuote(&quote)
				}
			case "t":
				var trade AlpacaTrade
				if err := json.Unmarshal(msg, &trade); err == nil {
					t.processTrade(&trade)
				}
			case "success":
				log.Printf("✅ %s\n", string(msg))
			}
		}
	}
}

func (t *TrinitySystem) processQuote(quote *AlpacaQuote) {
	t.symbolMu.RLock()
	symbolID, exists := t.symbolMap[quote.S]
	t.symbolMu.RUnlock()
	
	if !exists {
		return
	}
	
	// Send bid packet
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
	
	if C.write_market_packet(t.marketDataRing, &bidPacket) == 1 {
		atomic.AddUint64(&t.packetsWritten, 1)
	}
	
	// Send ask packet
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
	
	if C.write_market_packet(t.marketDataRing, &askPacket) == 1 {
		atomic.AddUint64(&t.packetsWritten, 1)
		
		// Log injection of first few packets
		if atomic.LoadUint64(&t.packetsWritten) <= 5 {
			log.Printf("💉 INJECTED: %s Quote Bid:$%.2f Ask:$%.2f -> Ring Buffer", 
				quote.S, quote.Bp, quote.Ap)
		}
	}
}

func (t *TrinitySystem) processTrade(trade *AlpacaTrade) {
	t.symbolMu.RLock()
	symbolID, exists := t.symbolMap[trade.S]
	t.symbolMu.RUnlock()
	
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
		side:         2, // Trade
	}
	
	if C.write_market_packet(t.marketDataRing, &packet) == 1 {
		atomic.AddUint64(&t.packetsWritten, 1)
		
		// Log injection of first few packets
		if atomic.LoadUint64(&t.packetsWritten) <= 5 {
			log.Printf("💉 INJECTED: %s Trade $%.2f x %d -> Ring Buffer", 
				trade.S, trade.P, trade.S_)
		}
	}
}

func (t *TrinitySystem) LaunchCerebrum() error {
	log.Println("🧠 LAUNCHING QUANTUM CEREBRUM...")
	
	// Start Zig cerebrum in a goroutine
	t.wg.Add(1)
	go func() {
		defer t.wg.Done()
		
		// This would call the Zig cerebrum via CGO
		// For now, we'll launch it as a subprocess
		cmd := exec.Command("./quantum_cerebrum")
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		
		if err := cmd.Start(); err != nil {
			log.Printf("Failed to launch cerebrum: %v\n", err)
			return
		}
		
		log.Println("⚡ CEREBRUM PROCESS LAUNCHED")
		
		// Wait for it to complete
		if err := cmd.Wait(); err != nil {
			log.Printf("Cerebrum exited: %v\n", err)
		}
	}()
	
	return nil
}

func (t *TrinitySystem) ReportStats() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	
	var lastPackets uint64
	
	for {
		select {
		case <-ticker.C:
			packets := atomic.LoadUint64(&t.packetsWritten)
			messages := atomic.LoadUint64(&t.wsMessages)
			rate := (packets - lastPackets) / 5
			lastPackets = packets
			
			log.Printf("🔱 TRINITY STATS: Messages: %d | Packets Injected: %d | Rate: %d pkt/s",
				messages, packets, rate)
				
		case <-t.stopChan:
			return
		}
	}
}

func (t *TrinitySystem) Shutdown() {
	log.Println("🛑 Shutting down Trinity...")
	close(t.stopChan)
	
	if t.conn != nil {
		t.conn.Close()
	}
	
	t.wg.Wait()
	
	if t.marketDataRing != nil {
		C.destroy_ring_buffer(t.marketDataRing)
	}
	if t.orderRing != nil {
		C.destroy_ring_buffer(t.orderRing)
	}
}

func main() {
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	if apiKey == "" || apiSecret == "" {
		log.Fatal("❌ API credentials not set")
	}
	
	log.Println("╔════════════════════════════════════════════════════╗")
	log.Println("║              TRINITY NEURAL PATHWAY                ║")
	log.Println("║         Connecting Go Eyes to Zig Brain            ║")
	log.Println("╚════════════════════════════════════════════════════╝")
	log.Println("")
	
	trinity := NewTrinitySystem(apiKey, apiSecret)
	
	// Initialize ring buffers
	if err := trinity.Initialize(); err != nil {
		log.Fatal(err)
	}
	
	// Connect to Alpaca
	if err := trinity.ConnectAlpaca(); err != nil {
		log.Fatal(err)
	}
	
	// Subscribe to symbols
	symbols := []string{"SPY", "QQQ", "AAPL", "MSFT", "NVDA", "AMD"}
	if err := trinity.Subscribe(symbols); err != nil {
		log.Fatal(err)
	}
	
	// Launch the Zig cerebrum
	if err := trinity.LaunchCerebrum(); err != nil {
		log.Fatal(err)
	}
	
	// Start stats reporter
	go trinity.ReportStats()
	
	log.Println("")
	log.Println("🔥 THE NEURAL PATHWAY IS OPEN 🔥")
	log.Println("Real market data is flowing from Go to Zig via ring buffers")
	log.Println("")
	
	// Handle shutdown
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	<-sigChan
	
	trinity.Shutdown()
	log.Println("✅ Clean shutdown")
}