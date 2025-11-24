package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/pebbe/zmq4"
	"github.com/shopspring/decimal"
)

// OrderSignal represents an order request from the HFT engine
type OrderSignal struct {
	Action    string  `json:"action"`    // "BUY" or "SELL"
	Symbol    string  `json:"symbol"`    // e.g., "AAPL"
	Quantity  float64 `json:"quantity"`  // Number of shares
	OrderType string  `json:"type"`      // "MARKET" or "LIMIT"
	Price     float64 `json:"price"`     // Limit price (0 for market orders)
	TimeStamp int64   `json:"timestamp"` // Unix timestamp
	SignalID  string  `json:"signal_id"` // Unique signal identifier
}

// OrderResponse represents the result of an order execution
type OrderResponse struct {
	SignalID  string  `json:"signal_id"`
	OrderID   string  `json:"order_id"`
	Status    string  `json:"status"`
	FilledQty float64 `json:"filled_qty"`
	FilledAvg float64 `json:"filled_avg"`
	Error     string  `json:"error,omitempty"`
}

// TradeExecutor handles order execution via Alpaca API
type TradeExecutor struct {
	alpacaClient *alpaca.Client
	zmqSocket    *zmq4.Socket
	zmqReply     *zmq4.Socket
	isLive       bool
}

func NewTradeExecutor() (*TradeExecutor, error) {
	// Get API credentials from environment
	apiKey := os.Getenv("ALPACA_API_KEY")
	apiSecret := os.Getenv("ALPACA_API_SECRET")

	if apiKey == "" || apiSecret == "" {
		return nil, fmt.Errorf("ALPACA_API_KEY and ALPACA_API_SECRET must be set")
	}

	// Create Alpaca client (paper trading)
	client := alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret,
		BaseURL:   "https://paper-api.alpaca.markets",
	})

	// Test connection
	account, err := client.GetAccount()
	if err != nil {
		return nil, fmt.Errorf("failed to connect to Alpaca: %v", err)
	}

	fmt.Printf("✅ Connected to Alpaca Paper Trading\n")
	fmt.Printf("💰 Buying Power: $%.2f\n", account.BuyingPower.InexactFloat64())
	fmt.Printf("💵 Cash: $%.2f\n", account.Cash.InexactFloat64())

	return &TradeExecutor{
		alpacaClient: client,
		isLive:       false, // Start in paper mode
	}, nil
}

func (te *TradeExecutor) Start() error {
	// Create ZeroMQ PULL socket to receive orders
	socket, err := zmq4.NewSocket(zmq4.PULL)
	if err != nil {
		return fmt.Errorf("failed to create ZMQ socket: %v", err)
	}
	te.zmqSocket = socket

	// Bind to IPC endpoint
	endpoint := "ipc:///tmp/hft_orders.ipc"
	err = socket.Bind(endpoint)
	if err != nil {
		return fmt.Errorf("failed to bind to %s: %v", endpoint, err)
	}

	// Create PUSH socket for responses
	reply, err := zmq4.NewSocket(zmq4.PUSH)
	if err != nil {
		return fmt.Errorf("failed to create reply socket: %v", err)
	}
	te.zmqReply = reply

	replyEndpoint := "ipc:///tmp/hft_responses.ipc"
	err = reply.Bind(replyEndpoint)
	if err != nil {
		return fmt.Errorf("failed to bind reply socket: %v", err)
	}

	fmt.Printf("🔌 Trade Executor listening on %s\n", endpoint)
	fmt.Printf("📤 Sending responses on %s\n", replyEndpoint)

	// Start processing loop
	for {
		// Receive order signal
		msg, err := socket.Recv(0)
		if err != nil {
			log.Printf("Error receiving message: %v", err)
			continue
		}

		// Parse order signal
		var signal OrderSignal
		err = json.Unmarshal([]byte(msg), &signal)
		if err != nil {
			log.Printf("Error parsing order signal: %v", err)
			continue
		}

		// Process the order
		response := te.processOrder(signal)

		// Send response back
		responseData, _ := json.Marshal(response)
		te.zmqReply.Send(string(responseData), zmq4.DONTWAIT)
	}
}

func (te *TradeExecutor) processOrder(signal OrderSignal) OrderResponse {
	fmt.Printf("\n📨 Received Signal: %s %s %.2f @ %.2f\n",
		signal.Action, signal.Symbol, signal.Quantity, signal.Price)

	// Determine order side
	var side alpaca.Side
	if signal.Action == "BUY" {
		side = alpaca.Buy
	} else {
		side = alpaca.Sell
	}

	// Determine order type
	var orderType alpaca.OrderType
	if signal.OrderType == "LIMIT" {
		orderType = alpaca.Limit
	} else {
		orderType = alpaca.Market
	}

	// Create order request
	qty := decimal.NewFromFloat(signal.Quantity)
	req := alpaca.PlaceOrderRequest{
		Symbol:      signal.Symbol,
		Qty:         &qty,
		Side:        side,
		Type:        orderType,
		TimeInForce: alpaca.Day,
	}

	// Add limit price if specified
	if orderType == alpaca.Limit && signal.Price > 0 {
		price := decimal.NewFromFloat(signal.Price)
		req.LimitPrice = &price
	}

	// Place the order
	order, err := te.alpacaClient.PlaceOrder(req)
	if err != nil {
		fmt.Printf("❌ Order failed: %v\n", err)
		return OrderResponse{
			SignalID: signal.SignalID,
			Status:   "FAILED",
			Error:    err.Error(),
		}
	}

	fmt.Printf("✅ Order placed: %s (Status: %s)\n", order.ID, order.Status)

	// Return response
	return OrderResponse{
		SignalID:  signal.SignalID,
		OrderID:   order.ID,
		Status:    string(order.Status),
		FilledQty: order.FilledQty.InexactFloat64(),
		FilledAvg: order.FilledAvgPrice.InexactFloat64(),
	}
}

func (te *TradeExecutor) Shutdown() {
	if te.zmqSocket != nil {
		te.zmqSocket.Close()
	}
	if te.zmqReply != nil {
		te.zmqReply.Close()
	}
	fmt.Println("🔌 Trade Executor shutdown complete")
}

func main() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║          ALPACA TRADE EXECUTOR                ║")
	fmt.Println("║         ZeroMQ IPC Bridge Edition             ║")
	fmt.Println("╚════════════════════════════════════════════════╝")

	executor, err := NewTradeExecutor()
	if err != nil {
		log.Fatalf("Failed to create executor: %v", err)
	}

	// Handle shutdown gracefully
	defer executor.Shutdown()

	// Start processing orders
	fmt.Println("\n🚀 Starting Trade Executor...")
	err = executor.Start()
	if err != nil {
		log.Fatalf("Failed to start executor: %v", err)
	}
}