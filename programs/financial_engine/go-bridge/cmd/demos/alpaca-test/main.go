// SIMPLE TEST OF ALPACA WEBSOCKET CONNECTION
package main

import (
	"encoding/json"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gorilla/websocket"
)

func main() {
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("APCA_API_SECRET_KEY")
	
	if apiKey == "" || apiSecret == "" {
		log.Fatal("❌ API credentials not set")
	}
	
	log.Println("🚀 Testing REAL Alpaca WebSocket Connection")
	log.Println("==========================================")
	
	// Connect to Alpaca
	wsURL := "wss://stream.data.alpaca.markets/v2/iex"
	log.Printf("📡 Connecting to: %s\n", wsURL)
	
	conn, _, err := websocket.DefaultDialer.Dial(wsURL, nil)
	if err != nil {
		log.Fatal("Connection failed:", err)
	}
	defer conn.Close()
	
	log.Println("✅ WebSocket connected!")
	
	// Authenticate
	auth := map[string]interface{}{
		"action": "auth",
		"key":    apiKey,
		"secret": apiSecret,
	}
	
	if err := conn.WriteJSON(auth); err != nil {
		log.Fatal("Auth failed:", err)
	}
	
	// Read auth response
	_, msg, err := conn.ReadMessage()
	if err != nil {
		log.Fatal("Auth response failed:", err)
	}
	log.Printf("🔐 Auth response: %s\n", string(msg))
	
	// Subscribe to quotes
	sub := map[string]interface{}{
		"action": "subscribe",
		"quotes": []string{"SPY", "AAPL", "MSFT"},
		"trades": []string{"SPY", "AAPL", "MSFT"},
	}
	
	if err := conn.WriteJSON(sub); err != nil {
		log.Fatal("Subscribe failed:", err)
	}
	log.Println("📊 Subscribed to SPY, AAPL, MSFT")
	
	// Read messages
	go func() {
		messageCount := 0
		for {
			_, message, err := conn.ReadMessage()
			if err != nil {
				log.Println("Read error:", err)
				return
			}
			
			messageCount++
			
			// Parse and display first 10 messages
			if messageCount <= 10 {
				var messages []json.RawMessage
				if err := json.Unmarshal(message, &messages); err == nil {
					for _, msg := range messages {
						var data map[string]interface{}
						if err := json.Unmarshal(msg, &data); err == nil {
							if t, ok := data["T"].(string); ok {
								switch t {
								case "q":
									log.Printf("📈 QUOTE: %s Bid: $%.2f Ask: $%.2f\n",
										data["S"], data["bp"], data["ap"])
								case "t":
									log.Printf("💹 TRADE: %s Price: $%.2f Size: %.0f\n",
										data["S"], data["p"], data["s"])
								default:
									log.Printf("📨 %s: %v\n", t, data)
								}
							}
						}
					}
				}
			}
			
			if messageCount%100 == 0 {
				log.Printf("📊 Received %d messages\n", messageCount)
			}
		}
	}()
	
	// Wait for interrupt
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	
	// Run for 30 seconds or until interrupted
	select {
	case <-sigChan:
		log.Println("🛑 Interrupted")
	case <-time.After(30 * time.Second):
		log.Println("⏰ Test complete")
	}
	
	log.Println("✅ WebSocket test successful!")
}