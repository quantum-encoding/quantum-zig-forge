package websocket

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"sync"
	"sync/atomic"
	"time"

	"github.com/gorilla/websocket"
	"github.com/shopspring/decimal"
)

// WebSocket URLs
const (
	ALPACA_WS_PAPER = "wss://paper-api.alpaca.markets/stream"
	ALPACA_WS_LIVE  = "wss://api.alpaca.markets/stream"
)

// Message types
type WSMessage struct {
	Action string          `json:"action,omitempty"`
	Stream string          `json:"stream,omitempty"`
	Data   json.RawMessage `json:"data"`
	Key    string          `json:"key,omitempty"`
	Secret string          `json:"secret,omitempty"`
}

type AuthData struct {
	Status string `json:"status"`
	Action string `json:"action"`
}

type ListenData struct {
	Streams []string `json:"streams"`
}

type TradeUpdate struct {
	Event       string           `json:"event"`
	ExecutionID string           `json:"execution_id,omitempty"`
	Order       Order            `json:"order"`
	PositionQty string           `json:"position_qty,omitempty"`
	Price       string           `json:"price,omitempty"`
	Qty         string           `json:"qty,omitempty"`
	Timestamp   string           `json:"timestamp,omitempty"`
	At          string           `json:"at,omitempty"`
	EventID     string           `json:"event_id,omitempty"`
}

type Order struct {
	ID             string          `json:"id"`
	ClientOrderID  string          `json:"client_order_id"`
	CreatedAt      string          `json:"created_at"`
	UpdatedAt      string          `json:"updated_at"`
	SubmittedAt    string          `json:"submitted_at"`
	FilledAt       string          `json:"filled_at,omitempty"`
	ExpiredAt      string          `json:"expired_at,omitempty"`
	CanceledAt     string          `json:"canceled_at,omitempty"`
	FailedAt       string          `json:"failed_at,omitempty"`
	AssetID        string          `json:"asset_id"`
	Symbol         string          `json:"symbol"`
	AssetClass     string          `json:"asset_class"`
	Qty            string          `json:"qty"`
	FilledQty      string          `json:"filled_qty"`
	FilledAvgPrice string          `json:"filled_avg_price,omitempty"`
	OrderType      string          `json:"order_type"`
	Side           string          `json:"side"`
	TimeInForce    string          `json:"time_in_force"`
	LimitPrice     string          `json:"limit_price,omitempty"`
	StopPrice      string          `json:"stop_price,omitempty"`
	Status         string          `json:"status"`
	ExtendedHours  bool            `json:"extended_hours"`
}

// AlpacaWebSocketClient manages real-time streaming
type AlpacaWebSocketClient struct {
	conn           *websocket.Conn
	apiKey         string
	apiSecret      string
	url            string
	isConnected    atomic.Bool
	isAuthenticated atomic.Bool
	
	// Handlers
	onTradeUpdate  func(TradeUpdate)
	onConnect      func()
	onDisconnect   func()
	onError        func(error)
	
	// Statistics
	messagesReceived uint64
	ordersReceived   uint64
	fillsReceived    uint64
	
	// Control
	ctx            context.Context
	cancel         context.CancelFunc
	wg             sync.WaitGroup
	reconnectDelay time.Duration
	maxReconnect   int
	
	// Channels
	sendChan       chan []byte
	receiveChan    chan []byte
	errorChan      chan error
	
	logger         *log.Logger
}

// NewAlpacaWebSocketClient creates a new WebSocket client
func NewAlpacaWebSocketClient(apiKey, apiSecret string, isPaper bool) *AlpacaWebSocketClient {
	url := ALPACA_WS_LIVE
	if isPaper {
		url = ALPACA_WS_PAPER
	}
	
	ctx, cancel := context.WithCancel(context.Background())
	
	return &AlpacaWebSocketClient{
		apiKey:         apiKey,
		apiSecret:      apiSecret,
		url:            url,
		ctx:            ctx,
		cancel:         cancel,
		reconnectDelay: 5 * time.Second,
		maxReconnect:   10,
		sendChan:       make(chan []byte, 100),
		receiveChan:    make(chan []byte, 1000),
		errorChan:      make(chan error, 10),
		logger:         log.New(log.Writer(), "[WS] ", log.LstdFlags|log.Lmicroseconds),
	}
}

// Connect establishes WebSocket connection
func (c *AlpacaWebSocketClient) Connect() error {
	c.logger.Printf("Connecting to %s...", c.url)
	
	dialer := websocket.Dialer{
		HandshakeTimeout: 10 * time.Second,
	}
	
	conn, _, err := dialer.Dial(c.url, nil)
	if err != nil {
		return fmt.Errorf("failed to connect: %v", err)
	}
	
	c.conn = conn
	c.isConnected.Store(true)
	
	// Start goroutines
	c.wg.Add(3)
	go c.readPump()
	go c.writePump()
	go c.messageProcessor()
	
	// Authenticate
	if err := c.authenticate(); err != nil {
		c.Close()
		return fmt.Errorf("authentication failed: %v", err)
	}
	
	// Subscribe to trade updates
	if err := c.subscribe([]string{"trade_updates"}); err != nil {
		c.Close()
		return fmt.Errorf("subscription failed: %v", err)
	}
	
	if c.onConnect != nil {
		c.onConnect()
	}
	
	c.logger.Println("✅ WebSocket connected and authenticated")
	return nil
}

// Authenticate sends authentication message
func (c *AlpacaWebSocketClient) authenticate() error {
	authMsg := WSMessage{
		Action: "auth",
		Key:    c.apiKey,
		Secret: c.apiSecret,
	}
	
	data, err := json.Marshal(authMsg)
	if err != nil {
		return err
	}
	
	select {
	case c.sendChan <- data:
		c.logger.Println("Authentication message sent")
	case <-time.After(5 * time.Second):
		return fmt.Errorf("authentication timeout")
	}
	
	// Wait for auth response
	timeout := time.After(10 * time.Second)
	for {
		select {
		case <-timeout:
			return fmt.Errorf("authentication response timeout")
		case <-time.After(100 * time.Millisecond):
			if c.isAuthenticated.Load() {
				return nil
			}
		}
	}
}

// Subscribe to streams
func (c *AlpacaWebSocketClient) subscribe(streams []string) error {
	listenMsg := WSMessage{
		Action: "listen",
		Data:   json.RawMessage(fmt.Sprintf(`{"streams":%s}`, toJSON(streams))),
	}
	
	data, err := json.Marshal(listenMsg)
	if err != nil {
		return err
	}
	
	select {
	case c.sendChan <- data:
		c.logger.Printf("Subscribed to streams: %v", streams)
		return nil
	case <-time.After(5 * time.Second):
		return fmt.Errorf("subscription timeout")
	}
}

// Read pump - reads messages from WebSocket
func (c *AlpacaWebSocketClient) readPump() {
	defer c.wg.Done()
	
	c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
	c.conn.SetPongHandler(func(string) error {
		c.conn.SetReadDeadline(time.Now().Add(60 * time.Second))
		return nil
	})
	
	for {
		select {
		case <-c.ctx.Done():
			return
		default:
			messageType, message, err := c.conn.ReadMessage()
			if err != nil {
				if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
					c.logger.Printf("WebSocket error: %v", err)
				}
				c.handleDisconnect()
				return
			}
			
			// Handle binary frames (trade_updates are binary on paper trading)
			if messageType == websocket.BinaryMessage || messageType == websocket.TextMessage {
				atomic.AddUint64(&c.messagesReceived, 1)
				select {
				case c.receiveChan <- message:
				default:
					c.logger.Println("Receive channel full, dropping message")
				}
			}
		}
	}
}

// Write pump - sends messages to WebSocket
func (c *AlpacaWebSocketClient) writePump() {
	defer c.wg.Done()
	
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-c.ctx.Done():
			return
			
		case message := <-c.sendChan:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.conn.WriteMessage(websocket.TextMessage, message); err != nil {
				c.logger.Printf("Write error: %v", err)
				c.handleDisconnect()
				return
			}
			
		case <-ticker.C:
			c.conn.SetWriteDeadline(time.Now().Add(10 * time.Second))
			if err := c.conn.WriteMessage(websocket.PingMessage, nil); err != nil {
				c.logger.Printf("Ping error: %v", err)
				c.handleDisconnect()
				return
			}
		}
	}
}

// Message processor - processes received messages
func (c *AlpacaWebSocketClient) messageProcessor() {
	defer c.wg.Done()
	
	for {
		select {
		case <-c.ctx.Done():
			return
			
		case message := <-c.receiveChan:
			c.processMessage(message)
		}
	}
}

// Process individual message
func (c *AlpacaWebSocketClient) processMessage(data []byte) {
	var msg WSMessage
	if err := json.Unmarshal(data, &msg); err != nil {
		c.logger.Printf("Failed to unmarshal message: %v", err)
		return
	}
	
	switch msg.Stream {
	case "authorization":
		c.handleAuthorization(msg.Data)
		
	case "listening":
		c.handleListening(msg.Data)
		
	case "trade_updates":
		c.handleTradeUpdate(msg.Data)
		
	default:
		if msg.Action == "error" {
			c.handleError(msg.Data)
		}
	}
}

// Handle authorization response
func (c *AlpacaWebSocketClient) handleAuthorization(data json.RawMessage) {
	var auth AuthData
	if err := json.Unmarshal(data, &auth); err != nil {
		c.logger.Printf("Failed to parse auth data: %v", err)
		return
	}
	
	if auth.Status == "authorized" {
		c.isAuthenticated.Store(true)
		c.logger.Println("✅ Authentication successful")
	} else {
		c.logger.Printf("❌ Authentication failed: %s", auth.Status)
		if c.onError != nil {
			c.onError(fmt.Errorf("authentication failed: %s", auth.Status))
		}
	}
}

// Handle listening confirmation
func (c *AlpacaWebSocketClient) handleListening(data json.RawMessage) {
	var listen ListenData
	if err := json.Unmarshal(data, &listen); err != nil {
		c.logger.Printf("Failed to parse listening data: %v", err)
		return
	}
	
	c.logger.Printf("Now listening to streams: %v", listen.Streams)
}

// Handle trade update
func (c *AlpacaWebSocketClient) handleTradeUpdate(data json.RawMessage) {
	var update TradeUpdate
	if err := json.Unmarshal(data, &update); err != nil {
		c.logger.Printf("Failed to parse trade update: %v", err)
		return
	}
	
	atomic.AddUint64(&c.ordersReceived, 1)
	
	// Track fills
	if update.Event == "fill" || update.Event == "partial_fill" {
		atomic.AddUint64(&c.fillsReceived, 1)
	}
	
	// Log important events
	switch update.Event {
	case "new":
		c.logger.Printf("📝 New order: %s %s %s (ID: %s)", 
			update.Order.Side, update.Order.Qty, update.Order.Symbol, update.Order.ID[:8])
			
	case "fill":
		c.logger.Printf("✅ Order filled: %s %s %s @ %s (Position: %s)", 
			update.Order.Side, update.Qty, update.Order.Symbol, update.Price, update.PositionQty)
			
	case "partial_fill":
		c.logger.Printf("📊 Partial fill: %s %s %s @ %s", 
			update.Order.Side, update.Qty, update.Order.Symbol, update.Price)
			
	case "canceled":
		c.logger.Printf("❌ Order canceled: %s %s %s", 
			update.Order.Side, update.Order.Qty, update.Order.Symbol)
			
	case "rejected":
		c.logger.Printf("🚫 Order rejected: %s %s %s", 
			update.Order.Side, update.Order.Qty, update.Order.Symbol)
			
	case "replaced":
		c.logger.Printf("🔄 Order replaced: %s", update.Order.ID[:8])
		
	case "expired":
		c.logger.Printf("⏰ Order expired: %s", update.Order.ID[:8])
		
	case "done_for_day":
		c.logger.Printf("🌅 Order done for day: %s", update.Order.ID[:8])
	}
	
	// Call handler if set
	if c.onTradeUpdate != nil {
		c.onTradeUpdate(update)
	}
}

// Handle error message
func (c *AlpacaWebSocketClient) handleError(data json.RawMessage) {
	var errData map[string]string
	if err := json.Unmarshal(data, &errData); err != nil {
		c.logger.Printf("Failed to parse error data: %v", err)
		return
	}
	
	errMsg := errData["error_message"]
	c.logger.Printf("❌ Server error: %s", errMsg)
	
	if c.onError != nil {
		c.onError(fmt.Errorf("server error: %s", errMsg))
	}
}

// Handle disconnect
func (c *AlpacaWebSocketClient) handleDisconnect() {
	if !c.isConnected.Load() {
		return
	}
	
	c.isConnected.Store(false)
	c.isAuthenticated.Store(false)
	
	if c.onDisconnect != nil {
		c.onDisconnect()
	}
	
	// Attempt reconnection
	go c.reconnect()
}

// Reconnect with exponential backoff
func (c *AlpacaWebSocketClient) reconnect() {
	attempts := 0
	delay := c.reconnectDelay
	
	for attempts < c.maxReconnect {
		select {
		case <-c.ctx.Done():
			return
		case <-time.After(delay):
			attempts++
			c.logger.Printf("Reconnection attempt %d/%d...", attempts, c.maxReconnect)
			
			if err := c.Connect(); err != nil {
				c.logger.Printf("Reconnection failed: %v", err)
				delay = time.Duration(float64(delay) * 1.5)
				if delay > 60*time.Second {
					delay = 60 * time.Second
				}
			} else {
				c.logger.Println("✅ Reconnected successfully")
				return
			}
		}
	}
	
	c.logger.Printf("Max reconnection attempts reached")
	if c.onError != nil {
		c.onError(fmt.Errorf("max reconnection attempts reached"))
	}
}

// Close gracefully shuts down the WebSocket connection
func (c *AlpacaWebSocketClient) Close() error {
	c.logger.Println("Closing WebSocket connection...")
	
	c.cancel()
	
	if c.conn != nil {
		// Send close message
		deadline := time.Now().Add(5 * time.Second)
		c.conn.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
		c.conn.SetReadDeadline(deadline)
		c.conn.Close()
	}
	
	c.wg.Wait()
	
	c.isConnected.Store(false)
	c.isAuthenticated.Store(false)
	
	c.logger.Println("WebSocket connection closed")
	return nil
}

// SetTradeUpdateHandler sets the handler for trade updates
func (c *AlpacaWebSocketClient) SetTradeUpdateHandler(handler func(TradeUpdate)) {
	c.onTradeUpdate = handler
}

// SetConnectHandler sets the handler for connection events
func (c *AlpacaWebSocketClient) SetConnectHandler(handler func()) {
	c.onConnect = handler
}

// SetDisconnectHandler sets the handler for disconnection events
func (c *AlpacaWebSocketClient) SetDisconnectHandler(handler func()) {
	c.onDisconnect = handler
}

// SetErrorHandler sets the handler for errors
func (c *AlpacaWebSocketClient) SetErrorHandler(handler func(error)) {
	c.onError = handler
}

// GetStatistics returns connection statistics
func (c *AlpacaWebSocketClient) GetStatistics() (messagesReceived, ordersReceived, fillsReceived uint64) {
	return atomic.LoadUint64(&c.messagesReceived),
		atomic.LoadUint64(&c.ordersReceived),
		atomic.LoadUint64(&c.fillsReceived)
}

// IsConnected returns connection status
func (c *AlpacaWebSocketClient) IsConnected() bool {
	return c.isConnected.Load()
}

// IsAuthenticated returns authentication status
func (c *AlpacaWebSocketClient) IsAuthenticated() bool {
	return c.isAuthenticated.Load()
}

// Helper function to convert to JSON
func toJSON(v interface{}) string {
	data, _ := json.Marshal(v)
	return string(data)
}

// PositionTracker tracks positions from trade updates
type PositionTracker struct {
	positions map[string]decimal.Decimal
	mu        sync.RWMutex
}

func NewPositionTracker() *PositionTracker {
	return &PositionTracker{
		positions: make(map[string]decimal.Decimal),
	}
}

func (pt *PositionTracker) UpdateFromTradeUpdate(update TradeUpdate) {
	if update.PositionQty == "" {
		return
	}
	
	pt.mu.Lock()
	defer pt.mu.Unlock()
	
	qty, err := decimal.NewFromString(update.PositionQty)
	if err != nil {
		return
	}
	
	pt.positions[update.Order.Symbol] = qty
}

func (pt *PositionTracker) GetPosition(symbol string) decimal.Decimal {
	pt.mu.RLock()
	defer pt.mu.RUnlock()
	
	if pos, ok := pt.positions[symbol]; ok {
		return pos
	}
	return decimal.Zero
}

func (pt *PositionTracker) GetAllPositions() map[string]decimal.Decimal {
	pt.mu.RLock()
	defer pt.mu.RUnlock()
	
	positions := make(map[string]decimal.Decimal)
	for k, v := range pt.positions {
		positions[k] = v
	}
	return positions
}