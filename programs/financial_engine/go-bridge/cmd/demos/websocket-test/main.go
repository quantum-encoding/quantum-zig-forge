package main

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/shopspring/decimal"
)

func main() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║      ALPACA WEBSOCKET STREAMING TEST          ║")
	fmt.Println("║         Real-Time Trade Updates               ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	// Get credentials
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("ALPACA_API_SECRET")
	if apiSecret == "" {
		apiSecret = os.Getenv("APCA_API_SECRET_KEY")
	}
	
	// Create WebSocket client
	fmt.Println("\n🔌 Connecting to Alpaca WebSocket stream...")
	wsClient := NewAlpacaWebSocketClient(apiKey, apiSecret, true) // true for paper trading
	
	// Create position tracker
	positionTracker := NewPositionTracker()
	
	// Set up handlers
	wsClient.SetConnectHandler(func() {
		fmt.Println("✅ WebSocket connected!")
		fmt.Println("📡 Listening for trade updates...")
		fmt.Println("\n" + strings.Repeat("=", 50))
	})
	
	wsClient.SetDisconnectHandler(func() {
		fmt.Println("\n⚠️ WebSocket disconnected - will attempt reconnection")
	})
	
	wsClient.SetErrorHandler(func(err error) {
		fmt.Printf("❌ WebSocket error: %v\n", err)
	})
	
	// Set trade update handler
	wsClient.SetTradeUpdateHandler(func(update TradeUpdate) {
		// Update position tracking
		positionTracker.UpdateFromTradeUpdate(update)
		
		// Display detailed trade information
		fmt.Printf("\n🔔 TRADE UPDATE [%s]\n", time.Now().Format("15:04:05"))
		fmt.Printf("   Event: %s\n", update.Event)
		fmt.Printf("   Symbol: %s\n", update.Order.Symbol)
		fmt.Printf("   Side: %s\n", update.Order.Side)
		fmt.Printf("   Quantity: %s\n", update.Order.Qty)
		fmt.Printf("   Order Type: %s\n", update.Order.OrderType)
		fmt.Printf("   Status: %s\n", update.Order.Status)
		
		if update.Event == "fill" || update.Event == "partial_fill" {
			fmt.Printf("   Fill Price: %s\n", update.Price)
			fmt.Printf("   Fill Qty: %s\n", update.Qty)
			fmt.Printf("   Position: %s shares\n", update.PositionQty)
			fmt.Printf("   Avg Fill Price: %s\n", update.Order.FilledAvgPrice)
		}
		
		fmt.Println(strings.Repeat("-", 50))
	})
	
	// Connect to WebSocket
	if err := wsClient.Connect(); err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	
	// Create regular Alpaca client for placing orders
	alpacaClient := alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret,
		BaseURL:   "https://paper-api.alpaca.markets",
	})
	
	// Place some test orders to generate events
	go func() {
		time.Sleep(3 * time.Second)
		
		fmt.Println("\n📈 Placing test orders to generate WebSocket events...")
		
		// Test order 1: Market buy
		qty1 := decimal.NewFromInt(1)
		order1 := alpaca.PlaceOrderRequest{
			Symbol:      "AAPL",
			Qty:         &qty1,
			Side:        alpaca.Buy,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
		}
		
		if _, err := alpacaClient.PlaceOrder(order1); err != nil {
			fmt.Printf("Failed to place order 1: %v\n", err)
		} else {
			fmt.Println("✅ Placed market buy order for 1 AAPL")
		}
		
		time.Sleep(2 * time.Second)
		
		// Test order 2: Limit sell
		qty2 := decimal.NewFromInt(1)
		limitPrice := decimal.NewFromFloat(155.00)
		order2 := alpaca.PlaceOrderRequest{
			Symbol:      "AAPL",
			Qty:         &qty2,
			Side:        alpaca.Sell,
			Type:        alpaca.Limit,
			LimitPrice:  &limitPrice,
			TimeInForce: alpaca.Day,
		}
		
		if placedOrder, err := alpacaClient.PlaceOrder(order2); err != nil {
			fmt.Printf("Failed to place order 2: %v\n", err)
		} else {
			fmt.Println("✅ Placed limit sell order for 1 AAPL @ $155.00")
			
			// Cancel it after a moment to generate cancel event
			go func() {
				time.Sleep(5 * time.Second)
				if err := alpacaClient.CancelOrder(placedOrder.ID); err != nil {
					fmt.Printf("Failed to cancel order: %v\n", err)
				} else {
					fmt.Println("📝 Sent cancel request for limit order")
				}
			}()
		}
		
		// Test order 3: Market sell
		time.Sleep(10 * time.Second)
		qty3 := decimal.NewFromInt(1)
		order3 := alpaca.PlaceOrderRequest{
			Symbol:      "MSFT",
			Qty:         &qty3,
			Side:        alpaca.Buy,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
		}
		
		if _, err := alpacaClient.PlaceOrder(order3); err != nil {
			fmt.Printf("Failed to place order 3: %v\n", err)
		} else {
			fmt.Println("✅ Placed market buy order for 1 MSFT")
		}
	}()
	
	// Display statistics periodically
	go func() {
		ticker := time.NewTicker(30 * time.Second)
		defer ticker.Stop()
		
		for range ticker.C {
			messages, orders, fills := wsClient.GetStatistics()
			fmt.Printf("\n📊 WebSocket Statistics:\n")
			fmt.Printf("   Messages Received: %d\n", messages)
			fmt.Printf("   Orders Received: %d\n", orders)
			fmt.Printf("   Fills Received: %d\n", fills)
			fmt.Printf("   Connected: %v\n", wsClient.IsConnected())
			fmt.Printf("   Authenticated: %v\n", wsClient.IsAuthenticated())
			
			// Show current positions
			positions := positionTracker.GetAllPositions()
			if len(positions) > 0 {
				fmt.Println("\n📍 Current Positions:")
				for symbol, qty := range positions {
					fmt.Printf("   %s: %s shares\n", symbol, qty)
				}
			}
			
			fmt.Println(strings.Repeat("=", 50))
		}
	}()
	
	// Wait for interrupt signal
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	
	fmt.Println("\n🎯 WebSocket stream is running. Press Ctrl+C to exit...")
	fmt.Println("📝 Orders placed through any method will appear here in real-time")
	
	<-sigChan
	
	fmt.Println("\n🛑 Shutting down WebSocket stream...")
	
	// Close WebSocket
	if err := wsClient.Close(); err != nil {
		fmt.Printf("Error closing WebSocket: %v\n", err)
	}
	
	// Final statistics
	messages, orders, fills := wsClient.GetStatistics()
	fmt.Printf("\n📊 Final Statistics:\n")
	fmt.Printf("   Total Messages: %d\n", messages)
	fmt.Printf("   Total Orders: %d\n", orders)
	fmt.Printf("   Total Fills: %d\n", fills)
	
	fmt.Println("\n✅ WebSocket stream test complete!")
}