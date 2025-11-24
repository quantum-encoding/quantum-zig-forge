package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: crypto_main <demo>")
		fmt.Println("Demos:")
		fmt.Println("  trading    - Crypto spot trading demo")
		fmt.Println("  wallets    - Crypto wallets demo") 
		fmt.Println("  marketdata - Real-time market data demo")
		fmt.Println("  fees       - Volume-tiered fee calculation demo")
		fmt.Println("  unified    - Complete unified system demo")
		fmt.Println("  options    - Options trading demo")
		fmt.Println("  protection - User protection & compliance demo")
		return
	}
	
	demo := os.Args[1]
	
	switch demo {
	case "trading":
		RunCryptoDemo()
	case "wallets":
		RunCryptoWalletsDemo()
	case "marketdata":
		RunCryptoMarketDataDemo()
	case "fees":
		RunCryptoFeesDemo()
	case "unified":
		RunUnifiedCryptoDemo()
	case "options":
		RunOptionsDemo()
	case "protection":
		RunUserProtectionDemo()
	default:
		fmt.Printf("Unknown demo: %s\n", demo)
		fmt.Println("Available: trading, wallets, marketdata, fees, unified, options, protection")
	}
}