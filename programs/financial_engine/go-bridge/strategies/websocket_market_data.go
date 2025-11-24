package strategies

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/gorilla/websocket"
)

// MarketDataStream handles WebSocket connections for Alpaca market data
type MarketDataStream struct {
	APIKey    string
	APISecret string
	BaseURL   string
	conn      *websocket.Conn
	logger    *log.Logger
	
	// Callbacks
	onBar   func(MarketBar)
	onTrade func(Trade)
	onQuote func(Quote)
}

// MarketBar represents a market data bar from WebSocket
type MarketBar struct {
	Type      string    `json:"T"`
	Symbol    string    `json:"S"`
	Open      float64   `json:"o"`
	High      float64   `json:"h"`
	Low       float64   `json:"l"`
	Close     float64   `json:"c"`
	Volume    int64     `json:"v"`
	Timestamp time.Time `json:"t"`
	Count     int       `json:"n"`
	VWAP      float64   `json:"vw"`
}

// Trade represents a market data trade
type Trade struct {
	Type      string    `json:"T"`
	Symbol    string    `json:"S"`
	ID        int64     `json:"i"`
	Exchange  string    `json:"x"`
	Price     float64   `json:"p"`
	Size      int       `json:"s"`
	Timestamp time.Time `json:"t"`
	Conditions []string `json:"c"`
	Tape      string    `json:"z"`
}

// Quote represents a market data quote
type Quote struct {
	Type      string    `json:"T"`
	Symbol    string    `json:"S"`
	BidEx     string    `json:"bx"`
	BidPrice  float64   `json:"bp"`
	BidSize   int       `json:"bs"`
	AskEx     string    `json:"ax"`
	AskPrice  float64   `json:"ap"`
	AskSize   int       `json:"as"`
	Timestamp time.Time `json:"t"`
	Conditions []string `json:"c"`
	Tape      string    `json:"z"`
}

// AuthMessage represents the authentication message
type AuthMessage struct {
	Action string `json:"action"`
	Key    string `json:"key"`
	Secret string `json:"secret"`
}

// SubscribeMessage represents the subscription message
type SubscribeMessage struct {
	Action string   `json:"action"`
	Bars   []string `json:"bars,omitempty"`
	Trades []string `json:"trades,omitempty"`
	Quotes []string `json:"quotes,omitempty"`
}

// ResponseMessage represents server responses
type ResponseMessage struct {
	Type    string `json:"T"`
	Message string `json:"msg,omitempty"`
	Code    int    `json:"code,omitempty"`
}

// NewMarketDataStream creates a new market data stream
func NewMarketDataStream(apiKey, apiSecret, baseURL string) *MarketDataStream {
	return &MarketDataStream{
		APIKey:    apiKey,
		APISecret: apiSecret,
		BaseURL:   baseURL,
		logger:    log.New(log.Writer(), "[MARKET-DATA-STREAM] ", log.LstdFlags),
	}
}

// SetBarHandler sets the bar callback
func (m *MarketDataStream) SetBarHandler(handler func(MarketBar)) {
	m.onBar = handler
}

// SetTradeHandler sets the trade callback
func (m *MarketDataStream) SetTradeHandler(handler func(Trade)) {
	m.onTrade = handler
}

// SetQuoteHandler sets the quote callback
func (m *MarketDataStream) SetQuoteHandler(handler func(Quote)) {
	m.onQuote = handler
}

// Connect establishes WebSocket connection to Alpaca market data stream
func (m *MarketDataStream) Connect(ctx context.Context) error {
	// Use SIP feed for production, IEX for testing
	streamURL := "wss://stream.data.alpaca.markets/v2/sip"
	if m.BaseURL == "https://paper-api.alpaca.markets" {
		streamURL = "wss://stream.data.alpaca.markets/v2/iex"
	}

	m.logger.Printf("Connecting to market data stream: %s", streamURL)
	
	var err error
	m.conn, _, err = websocket.DefaultDialer.Dial(streamURL, nil)
	if err != nil {
		return fmt.Errorf("failed to connect to WebSocket: %w", err)
	}

	// Wait for welcome message
	var welcome []ResponseMessage
	if err := m.conn.ReadJSON(&welcome); err != nil {
		return fmt.Errorf("failed to read welcome message: %w", err)
	}

	if len(welcome) == 0 || welcome[0].Type != "success" {
		return fmt.Errorf("unexpected welcome message: %+v", welcome)
	}

	m.logger.Printf("Connected successfully: %s", welcome[0].Message)

	// Authenticate
	if err := m.authenticate(); err != nil {
		return fmt.Errorf("authentication failed: %w", err)
	}

	// Start message handler
	go m.handleMessages(ctx)

	return nil
}

// authenticate sends authentication message
func (m *MarketDataStream) authenticate() error {
	authMsg := AuthMessage{
		Action: "auth",
		Key:    m.APIKey,
		Secret: m.APISecret,
	}

	if err := m.conn.WriteJSON(authMsg); err != nil {
		return err
	}

	// Wait for auth response
	var authResp []ResponseMessage
	if err := m.conn.ReadJSON(&authResp); err != nil {
		return err
	}

	if len(authResp) == 0 || authResp[0].Type != "success" {
		return fmt.Errorf("authentication failed: %+v", authResp)
	}

	m.logger.Printf("Authenticated successfully: %s", authResp[0].Message)
	return nil
}

// Subscribe subscribes to market data for symbols
func (m *MarketDataStream) Subscribe(symbols []string) error {
	subMsg := SubscribeMessage{
		Action: "subscribe",
		Bars:   symbols,
		Trades: symbols,
		Quotes: symbols,
	}

	if err := m.conn.WriteJSON(subMsg); err != nil {
		return err
	}

	m.logger.Printf("Subscribed to symbols: %v", symbols)
	return nil
}

// SubscribeBars subscribes only to bars for symbols
func (m *MarketDataStream) SubscribeBars(symbols []string) error {
	subMsg := SubscribeMessage{
		Action: "subscribe",
		Bars:   symbols,
	}

	if err := m.conn.WriteJSON(subMsg); err != nil {
		return err
	}

	m.logger.Printf("Subscribed to bars for symbols: %v", symbols)
	return nil
}

// handleMessages handles incoming WebSocket messages
func (m *MarketDataStream) handleMessages(ctx context.Context) {
	for {
		select {
		case <-ctx.Done():
			return
		default:
			var messages []json.RawMessage
			if err := m.conn.ReadJSON(&messages); err != nil {
				m.logger.Printf("Error reading message: %v", err)
				continue
			}

			for _, rawMsg := range messages {
				m.processMessage(rawMsg)
			}
		}
	}
}

// processMessage processes individual market data messages
func (m *MarketDataStream) processMessage(rawMsg json.RawMessage) {
	// Parse the type first
	var typeMsg struct {
		Type string `json:"T"`
	}
	
	if err := json.Unmarshal(rawMsg, &typeMsg); err != nil {
		m.logger.Printf("Error parsing message type: %v", err)
		return
	}

	switch typeMsg.Type {
	case "b": // Minute bar
		var bar MarketBar
		if err := json.Unmarshal(rawMsg, &bar); err != nil {
			m.logger.Printf("Error parsing bar: %v", err)
			return
		}
		if m.onBar != nil {
			m.onBar(bar)
		}

	case "t": // Trade
		var trade Trade
		if err := json.Unmarshal(rawMsg, &trade); err != nil {
			m.logger.Printf("Error parsing trade: %v", err)
			return
		}
		if m.onTrade != nil {
			m.onTrade(trade)
		}

	case "q": // Quote
		var quote Quote
		if err := json.Unmarshal(rawMsg, &quote); err != nil {
			m.logger.Printf("Error parsing quote: %v", err)
			return
		}
		if m.onQuote != nil {
			m.onQuote(quote)
		}

	case "success", "subscription":
		var resp ResponseMessage
		if err := json.Unmarshal(rawMsg, &resp); err == nil {
			m.logger.Printf("Server message: %s", resp.Message)
		}

	case "error":
		var resp ResponseMessage
		if err := json.Unmarshal(rawMsg, &resp); err == nil {
			m.logger.Printf("Server error: %s (code: %d)", resp.Message, resp.Code)
		}

	default:
		m.logger.Printf("Unknown message type: %s", typeMsg.Type)
	}
}

// Disconnect closes the WebSocket connection
func (m *MarketDataStream) Disconnect() error {
	if m.conn != nil {
		return m.conn.Close()
	}
	return nil
}