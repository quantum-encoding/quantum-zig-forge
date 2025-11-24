// TRINITY NEURAL PATHWAY - The REAL Connection
// This uses the canonical C header for struct definitions

package bridge

/*
#cgo CFLAGS: -O3 -march=native
#cgo LDFLAGS: -L. -lpthread

#include "synapse_bridge.h"
#include "synapse_bridge.c"
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

	"github.com/gorilla/websocket"
)

type TrinityNeuralPathway struct {
	// Alpaca connection
	apiKey    string
	apiSecret string
	conn      *websocket.Conn
	
	// Ring buffers (using canonical C structs)
	marketRing *C.RingBuffer
	orderRing  *C.RingBuffer
	
	// Symbol mapping
	symbolMap map[string]uint32
	symbolMu  sync.RWMutex
	
	// Statistics
	packetsInjected uint64
	wsMessages      uint64
	
	// Control
	stopChan chan struct{}
	wg       sync.WaitGroup
	
	// Zig process
	zigProcess *exec.Cmd
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

func NewTrinityNeuralPathway(apiKey, apiSecret string) *TrinityNeuralPathway {
	return &TrinityNeuralPathway{
		apiKey:    apiKey,
		apiSecret: apiSecret,
		symbolMap: map[string]uint32{
			"SPY":  0,
			"QQQ":  1,
			"AAPL": 2,
			"MSFT": 3,
			"NVDA": 4,
			"AMD":  5,
		},
		stopChan: make(chan struct{}),
	}
}

func (t *TrinityNeuralPathway) Initialize() error {
	log.Println("🧠 INITIALIZING REAL NEURAL PATHWAY...")
	
	// Create ring buffers using canonical C functions
	t.marketRing = C.synapse_create_ring(2097152) // 2MB
	t.orderRing = C.synapse_create_ring(1048576)  // 1MB
	
	if t.marketRing == nil || t.orderRing == nil {
		return fmt.Errorf("failed to create ring buffers")
	}
	
	log.Println("✅ Ring buffers created via synapse_bridge")
	return nil
}

func (t *TrinityNeuralPathway) ConnectAlpaca() error {
	wsURL := "wss://stream.data.alpaca.markets/v2/iex"
	
	log.Printf("📡 Connecting to Alpaca: %s\n", wsURL)
	
	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		return err
	}
	
	t.conn = conn
	
	// Authenticate
	auth := map[string]interface{}{
		"action": "auth",
		"key":    t.apiKey,
		"secret": t.apiSecret,
	}
	
	if err := t.conn.WriteJSON(auth); err != nil {
		return err
	}
	
	// Read auth response
	_, msg, err := t.conn.ReadMessage()
	if err != nil {
		return err
	}
	
	log.Printf("🔐 Auth: %s\n", string(msg))
	
	// Subscribe
	symbols := []string{"SPY", "QQQ", "AAPL", "MSFT", "NVDA", "AMD"}
	sub := map[string]interface{}{
		"action": "subscribe",
		"quotes": symbols,
		"trades": symbols,
	}
	
	if err := t.conn.WriteJSON(sub); err != nil {
		return err
	}
	
	log.Printf("📊 Subscribed to %d symbols\n", len(symbols))
	
	// Start reader
	t.wg.Add(1)
	go t.alpacaReader()
	
	return nil
}

func (t *TrinityNeuralPathway) LaunchZigCerebrum() error {
	log.Println("⚡ LAUNCHING ZIG CEREBRUM...")
	
	// Export ring buffer pointers as environment variables
	os.Setenv("MARKET_RING_PTR", fmt.Sprintf("%p", t.marketRing))
	os.Setenv("ORDER_RING_PTR", fmt.Sprintf("%p", t.orderRing))
	
	t.zigProcess = exec.Command("./quantum_cerebrum_connected")
	t.zigProcess.Stdout = os.Stdout
	t.zigProcess.Stderr = os.Stderr
	
	if err := t.zigProcess.Start(); err != nil {
		return fmt.Errorf("failed to launch Zig: %v", err)
	}
	
	log.Println("🔥 ZIG CEREBRUM LAUNCHED - NEURAL PATHWAY COMPLETE")
	
	// Monitor Zig process
	t.wg.Add(1)
	go func() {
		defer t.wg.Done()
		if err := t.zigProcess.Wait(); err != nil {
			log.Printf("Zig cerebrum exited: %v\n", err)
		}
	}()
	
	return nil
}

func (t *TrinityNeuralPathway) alpacaReader() {
	defer t.wg.Done()
	
	for {
		select {
		case <-t.stopChan:
			return
		default:
		}
		
		_, message, err := t.conn.ReadMessage()
		if err != nil {
			return
		}
		
		atomic.AddUint64(&t.wsMessages, 1)
		
		// Parse messages
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
					t.injectQuote(&quote)
				}
			case "t":
				var trade AlpacaTrade
				if err := json.Unmarshal(msg, &trade); err == nil {
					t.injectTrade(&trade)
				}
			}
		}
	}
}

func (t *TrinityNeuralPathway) injectQuote(quote *AlpacaQuote) {
	symbolID, exists := t.symbolMap[quote.S]
	if !exists {
		return
	}
	
	// Create MarketPacket using canonical struct
	packet := C.MarketPacket{
		timestamp_ns:    C.uint64_t(time.Now().UnixNano()),
		symbol_id:       C.uint32_t(symbolID),
		packet_type:     0, // Quote
		flags:           0,
		price_field:     C.uint64_t(quote.Bp * 1_000_000),
		qty_field:       C.uint32_t(quote.Bs),
		order_id_field:  0,
		side_field:      0, // Bid
	}
	
	// Inject into ring buffer
	if C.synapse_write_packet(t.marketRing, &packet) == 1 {
		atomic.AddUint64(&t.packetsInjected, 1)
		
		// Log first few injections
		if atomic.LoadUint64(&t.packetsInjected) <= 5 {
			log.Printf("💉 INJECTED #%d: %s BID $%.2f -> Ring Buffer -> Zig", 
				atomic.LoadUint64(&t.packetsInjected), quote.S, quote.Bp)
		}
	}
	
	// Also inject ask
	packet.price_field = C.uint64_t(quote.Ap * 1_000_000)
	packet.qty_field = C.uint32_t(quote.As)
	packet.side_field = 1 // Ask
	
	if C.synapse_write_packet(t.marketRing, &packet) == 1 {
		atomic.AddUint64(&t.packetsInjected, 1)
	}
}

func (t *TrinityNeuralPathway) injectTrade(trade *AlpacaTrade) {
	symbolID, exists := t.symbolMap[trade.S]
	if !exists {
		return
	}
	
	packet := C.MarketPacket{
		timestamp_ns:    C.uint64_t(time.Now().UnixNano()),
		symbol_id:       C.uint32_t(symbolID),
		packet_type:     1, // Trade
		flags:           0,
		price_field:     C.uint64_t(trade.P * 1_000_000),
		qty_field:       C.uint32_t(trade.S_),
		order_id_field:  0,
		side_field:      2, // Trade
	}
	
	if C.synapse_write_packet(t.marketRing, &packet) == 1 {
		atomic.AddUint64(&t.packetsInjected, 1)
		
		// Log first few injections
		if atomic.LoadUint64(&t.packetsInjected) <= 5 {
			log.Printf("💉 INJECTED #%d: %s TRADE $%.2f -> Ring Buffer -> Zig",
				atomic.LoadUint64(&t.packetsInjected), trade.S, trade.P)
		}
	}
}

func (t *TrinityNeuralPathway) ReportStats() {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	
	var lastPackets uint64
	
	for {
		select {
		case <-ticker.C:
			packets := atomic.LoadUint64(&t.packetsInjected)
			messages := atomic.LoadUint64(&t.wsMessages)
			rate := (packets - lastPackets) / 5
			lastPackets = packets
			
			log.Printf("🔱 NEURAL PATHWAY: Messages: %d | Injected: %d | Rate: %d pkt/s",
				messages, packets, rate)
				
		case <-t.stopChan:
			return
		}
	}
}

func (t *TrinityNeuralPathway) Shutdown() {
	close(t.stopChan)
	
	if t.conn != nil {
		t.conn.Close()
	}
	
	if t.zigProcess != nil {
		t.zigProcess.Process.Kill()
	}
	
	t.wg.Wait()
	
	if t.marketRing != nil {
		C.synapse_destroy_ring(t.marketRing)
	}
	if t.orderRing != nil {
		C.synapse_destroy_ring(t.orderRing)
	}
}

func main() {
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	if apiKey == "" || apiSecret == "" {
		log.Fatal("❌ API credentials not set")
	}
	
	log.Println("╔════════════════════════════════════════════════════╗")
	log.Println("║           THE REAL NEURAL PATHWAY                  ║")
	log.Println("║         Go → Ring Buffer → Zig (NO FAKE)           ║")
	log.Println("╚════════════════════════════════════════════════════╝")
	log.Println("")
	
	trinity := NewTrinityNeuralPathway(apiKey, apiSecret)
	
	// Initialize ring buffers
	if err := trinity.Initialize(); err != nil {
		log.Fatal(err)
	}
	
	// Connect to Alpaca
	if err := trinity.ConnectAlpaca(); err != nil {
		log.Fatal(err)
	}
	
	// Launch Zig cerebrum
	if err := trinity.LaunchZigCerebrum(); err != nil {
		log.Fatal(err)
	}
	
	// Start stats
	go trinity.ReportStats()
	
	log.Println("")
	log.Println("🔥 THE SYNAPSE IS FORGED 🔥")
	log.Println("Real data flows from Go to Zig through shared memory")
	log.Println("")
	
	// Wait for interrupt
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	<-sigChan
	
	trinity.Shutdown()
	log.Println("✅ Clean shutdown")
}