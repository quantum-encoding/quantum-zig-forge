package main

import (
	"fmt"
	"net/http"
	"os"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/shopspring/decimal"
)

func main() {
	fmt.Println("🔍 === ALPACA ACCOUNT DIAGNOSTICS ===\n")

	// Get credentials - USING CORRECT KEYS
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("ALPACA_API_SECRET")
	if apiSecret == "" {
		apiSecret = os.Getenv("APCA_API_SECRET_KEY")
	}

	fmt.Printf("API Key: %s\n", apiKey)
	fmt.Printf("Secret: %s...\n", apiSecret[:10])

	// Test different endpoints and base URLs
	baseUrls := []string{
		"https://paper-api.alpaca.markets",
		"https://api.alpaca.markets", // Live trading URL
	}

	for _, baseUrl := range baseUrls {
		fmt.Printf("\n🔌 Testing connection to: %s\n", baseUrl)

		// Create client with longer timeout
		client := alpaca.NewClient(alpaca.ClientOpts{
			APIKey:     apiKey,
			APISecret:  apiSecret,
			BaseURL:    baseUrl,
			HTTPClient: &http.Client{Timeout: 30 * time.Second},
		})

		// Test account access
		fmt.Println("📊 Attempting to get account information...")
		account, err := client.GetAccount()
		if err != nil {
			fmt.Printf("❌ Account access failed: %v\n", err)
			continue
		}

		// Success! Print account details
		fmt.Println("✅ ACCOUNT ACCESS SUCCESSFUL!")
		fmt.Printf("   Account ID: %s\n", account.ID)
		fmt.Printf("   Status: %s\n", account.Status)
		fmt.Printf("   Trading Blocked: %t\n", account.TradingBlocked)
		fmt.Printf("   Account Blocked: %t\n", account.AccountBlocked)
		fmt.Printf("   Pattern Day Trader: %t\n", account.PatternDayTrader)
		fmt.Printf("   Buying Power: $%s\n", account.BuyingPower)
		fmt.Printf("   Cash: $%s\n", account.Cash)
		fmt.Printf("   Portfolio Value: $%s\n", account.Equity)
		fmt.Printf("   Daytrade Count: %d\n", account.DaytradeCount)

		// Test positions
		fmt.Println("\n📊 Checking positions...")
		positions, err := client.GetPositions()
		if err != nil {
			fmt.Printf("⚠️  Positions access error: %v\n", err)
		} else {
			fmt.Printf("✅ Position access successful - %d positions\n", len(positions))
			for _, pos := range positions {
				fmt.Printf("   %s: %s shares @ $%s\n", pos.Symbol, pos.Qty, pos.AvgEntryPrice)
			}
		}

		// Test order placement with a small test order
		fmt.Println("\n📈 Testing order placement (1 share of AAPL)...")
		qty := decimal.NewFromInt(1)
		testOrder := alpaca.PlaceOrderRequest{
			Symbol:      "AAPL",
			Qty:         &qty,
			Side:        alpaca.Buy,
			Type:        alpaca.Market,
			TimeInForce: alpaca.Day,
		}

		order, err := client.PlaceOrder(testOrder)
		if err != nil {
			fmt.Printf("⚠️  Test order failed: %v\n", err)
		} else {
			fmt.Printf("🎯 TEST ORDER SUCCESSFUL!\n")
			fmt.Printf("   Order ID: %s\n", order.ID)
			fmt.Printf("   Status: %s\n", order.Status)
			fmt.Printf("   Symbol: %s\n", order.Symbol)
			fmt.Printf("   Side: %s\n", order.Side)
			fmt.Printf("   Quantity: %s\n", order.Qty)
			fmt.Printf("   Submitted at: %s\n", order.SubmittedAt)
		}

		return // Exit after first successful connection
	}

	fmt.Println("\n❌ No successful connections to any Alpaca endpoint")
	fmt.Println("\n📝 Possible issues:")
	fmt.Println("   1. Account not yet approved for trading")
	fmt.Println("   2. API keys may need regeneration")
	fmt.Println("   3. Account may need additional verification")
	fmt.Println("   4. Network connectivity issues")
}