package strategies

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/gorilla/websocket"
)

// TradeUpdatesStream handles WebSocket connections for Alpaca trade updates
type TradeUpdatesStream struct {
	APIKey    string
	APISecret string
	BaseURL   string
	conn      *websocket.Conn
	logger    *log.Logger
	
	// Callback
	onTradeUpdate func(TradeUpdate)
}

// TradeUpdate represents a trade update message
type TradeUpdate struct {
	Stream string `json:"stream"`
	Data   struct {
		Event       string    `json:"event"`
		ExecutionID string    `json:"execution_id,omitempty"`
		Order       Order     `json:"order"`
		Timestamp   time.Time `json:"timestamp,omitempty"`
		Price       string    `json:"price,omitempty"`
		Qty         string    `json:"qty,omitempty"`
		PositionQty string    `json:"position_qty,omitempty"`
	} `json:"data"`
}

// Order represents an order in trade updates
type Order struct {
	ID              string    `json:"id"`
	ClientOrderID   string    `json:"client_order_id"`
	CreatedAt       time.Time `json:"created_at"`
	UpdatedAt       time.Time `json:"updated_at"`
	SubmittedAt     time.Time `json:"submitted_at"`
	FilledAt        *time.Time `json:"filled_at"`
	ExpiredAt       *time.Time `json:"expired_at"`
	CanceledAt      *time.Time `json:"canceled_at"`
	FailedAt        *time.Time `json:"failed_at"`
	ReplacedAt      *time.Time `json:"replaced_at"`
	AssetID         string    `json:"asset_id"`
	Symbol          string    `json:"symbol"`
	AssetClass      string    `json:"asset_class"`
	Notional        *string   `json:"notional"`
	Qty             string    `json:"qty"`
	FilledQty       string    `json:"filled_qty"`
	FilledAvgPrice  *string   `json:"filled_avg_price"`
	OrderClass      string    `json:"order_class"`
	OrderType       string    `json:"order_type"`
	Type            string    `json:"type"`
	Side            string    `json:"side"`
	TimeInForce     string    `json:"time_in_force"`
	LimitPrice      *string   `json:"limit_price"`
	StopPrice       *string   `json:"stop_price"`
	Status          string    `json:"status"`
	ExtendedHours   bool      `json:"extended_hours"`
	Legs            []Order   `json:"legs"`
	TrailPercent    *string   `json:"trail_percent"`
	TrailPrice      *string   `json:"trail_price"`
	Hwm             *string   `json:"hwm"`
}

// TradeAuthMessage represents the authentication message for trade updates
type TradeAuthMessage struct {
	Action string `json:"action"`
	Key    string `json:"key"`
	Secret string `json:"secret"`
}

// TradeListenMessage represents the listen message
type TradeListenMessage struct {
	Action string `json:"action"`
	Data   struct {
		Streams []string `json:"streams"`
	} `json:"data"`
}

// TradeResponseMessage represents server responses for trade updates
type TradeResponseMessage struct {
	Stream string `json:"stream"`
	Data   struct {
		Status  string   `json:"status,omitempty"`
		Action  string   `json:"action,omitempty"`
		Streams []string `json:"streams,omitempty"`
	} `json:"data"`
}

// NewTradeUpdatesStream creates a new trade updates stream
func NewTradeUpdatesStream(apiKey, apiSecret, baseURL string) *TradeUpdatesStream {
	return &TradeUpdatesStream{
		APIKey:    apiKey,
		APISecret: apiSecret,
		BaseURL:   baseURL,
		logger:    log.New(log.Writer(), "[TRADE-UPDATES-STREAM] ", log.LstdFlags),
	}
}

// SetTradeUpdateHandler sets the trade update callback
func (t *TradeUpdatesStream) SetTradeUpdateHandler(handler func(TradeUpdate)) {
	t.onTradeUpdate = handler
}

// Connect establishes WebSocket connection to Alpaca trade updates stream
func (t *TradeUpdatesStream) Connect(ctx context.Context) error {
	// Use paper or live trading API based on baseURL
	streamURL := "wss://api.alpaca.markets/stream"
	if t.BaseURL == "https://paper-api.alpaca.markets" {
		streamURL = "wss://paper-api.alpaca.markets/stream"
	}

	t.logger.Printf("Connecting to trade updates stream: %s", streamURL)
	
	var err error
	t.conn, _, err = websocket.DefaultDialer.Dial(streamURL, nil)
	if err != nil {
		return fmt.Errorf("failed to connect to WebSocket: %w", err)
	}

	// Authenticate immediately
	if err := t.authenticate(); err != nil {
		return fmt.Errorf("authentication failed: %w", err)
	}

	// Subscribe to trade updates
	if err := t.subscribe(); err != nil {
		return fmt.Errorf("subscription failed: %w", err)
	}

	// Start message handler
	go t.handleMessages(ctx)

	return nil
}

// authenticate sends authentication message
func (t *TradeUpdatesStream) authenticate() error {
	authMsg := TradeAuthMessage{
		Action: "auth",
		Key:    t.APIKey,
		Secret: t.APISecret,
	}

	if err := t.conn.WriteJSON(authMsg); err != nil {
		return err
	}

	// Wait for auth response
	var authResp TradeResponseMessage
	if err := t.conn.ReadJSON(&authResp); err != nil {
		return err
	}

	if authResp.Stream != "authorization" || authResp.Data.Status != "authorized" {
		return fmt.Errorf("authentication failed: %+v", authResp)
	}

	t.logger.Printf("Authenticated successfully")
	return nil
}

// subscribe subscribes to trade updates
func (t *TradeUpdatesStream) subscribe() error {
	listenMsg := TradeListenMessage{
		Action: "listen",
		Data: struct {
			Streams []string `json:"streams"`
		}{
			Streams: []string{"trade_updates"},
		},
	}

	if err := t.conn.WriteJSON(listenMsg); err != nil {
		return err
	}

	// Wait for subscription confirmation
	var subResp TradeResponseMessage
	if err := t.conn.ReadJSON(&subResp); err != nil {
		return err
	}

	if subResp.Stream != "listening" {
		return fmt.Errorf("subscription failed: %+v", subResp)
	}

	t.logger.Printf("Subscribed to trade_updates successfully")
	return nil
}

// handleMessages handles incoming WebSocket messages
func (t *TradeUpdatesStream) handleMessages(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			return
		default:
			var message json.RawMessage
			if err := t.conn.ReadJSON(&message); err != nil {
				t.logger.Printf("Error reading message: %v", err)
				continue
			}

			t.processMessage(message)
		}
	}
}

// processMessage processes individual trade update messages
func (t *TradeUpdatesStream) processMessage(rawMsg json.RawMessage) {
	// Try to parse as trade update
	var tradeUpdate TradeUpdate
	if err := json.Unmarshal(rawMsg, &tradeUpdate); err != nil {
		t.logger.Printf("Error parsing trade update: %v", err)
		return
	}

	if tradeUpdate.Stream == "trade_updates" && t.onTradeUpdate != nil {
		t.onTradeUpdate(tradeUpdate)
	} else {
		// Handle other message types (authorization, listening, etc.)
		var resp TradeResponseMessage
		if err := json.Unmarshal(rawMsg, &resp); err == nil {
			t.logger.Printf("Server message: %s - %+v", resp.Stream, resp.Data)
		}
	}
}

// Disconnect closes the WebSocket connection
func (t *TradeUpdatesStream) Disconnect() error {
	if t.conn != nil {
		return t.conn.Close()
	}
	return nil
}