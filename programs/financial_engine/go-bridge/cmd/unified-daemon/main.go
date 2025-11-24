package main

/*
#cgo LDFLAGS: -L. -lc_api -ldl
#include <stdlib.h>
#include <stdint.h>

typedef struct {
    const char* symbol_ptr;
    uint32_t symbol_len;
    int64_t bid_value;
    int64_t ask_value;
    int64_t bid_size_value;
    int64_t ask_size_value;
    int64_t timestamp;
    uint64_t sequence;
} CMarketTick;

typedef struct {
    const char* symbol_ptr;
    uint32_t symbol_len;
    uint32_t action;
    float confidence;
    int64_t target_price_value;
    int64_t quantity_value;
    int64_t timestamp;
} CSignal;

typedef struct {
    uint64_t ticks_processed;
    uint64_t signals_generated;
    uint64_t orders_sent;
    uint64_t trades_executed;
    uint64_t avg_latency_us;
    uint64_t peak_latency_us;
} CSystemStats;

int hft_init();
int hft_process_tick(const CMarketTick* tick);
int hft_get_next_signal(CSignal* signal_out);
int hft_get_stats(CSystemStats* stats);
void hft_cleanup();
*/
import "C"

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
	"log/syslog"
	"math"
	"os"
	"os/signal"
	"path/filepath"
	"sync"
	"sync/atomic"
	"syscall"
	"time"
	"unsafe"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/alpacahq/alpaca-trade-api-go/v3/marketdata"
	"github.com/gorilla/websocket"
	"github.com/shopspring/decimal"
)

// Global logger for daemon mode
var (
	logger       *log.Logger
	syslogWriter *syslog.Writer
	logFile      *os.File
)

// ==================== ENHANCED TRADING CAPABILITIES ====================

// WebSocket streaming constants
const (
	WS_AUTH_URL_PAPER = "wss://stream.data.alpaca.markets/v1beta1/news"
	WS_AUTH_URL_LIVE  = "wss://stream.data.alpaca.markets/v1beta1/news"
)

// LCT Currency pairs and information
type CurrencyPair struct {
	Symbol        string
	BaseCurrency  string
	QuoteCurrency string
	MinOrderSize  decimal.Decimal
	IsActive      bool
}

// Crypto trading pairs
type CryptoPairInfo struct {
	Symbol       string
	Name         string
	MinOrderSize string
	IsActive     bool
}

// Journal types and statuses
const (
	JOURNAL_CASH       = "JNLC"
	JOURNAL_SECURITIES = "JNLS"
	STATUS_QUEUED      = "queued"
	STATUS_EXECUTED    = "executed"
)

// Funding Wallets constants
const (
	FUNDING_STATUS_PENDING   = "pending"
	FUNDING_STATUS_COMPLETE  = "complete"
	FUNDING_STATUS_REJECTED  = "rejected"
	FUNDING_STATUS_FAILED    = "failed"
)

// Instant Funding constants
const (
	INSTANT_STATUS_PENDING    = "PENDING"
	INSTANT_STATUS_EXECUTED   = "EXECUTED"
	INSTANT_STATUS_COMPLETED  = "COMPLETED"
	INSTANT_STATUS_CANCELED   = "CANCELED"
)

// WebSocket Client structure
type AlpacaWebSocketClient struct {
	conn            *websocket.Conn
	apiKey          string
	apiSecret       string
	url             string
	isConnected     atomic.Bool
	isAuthenticated atomic.Bool
	logger          *log.Logger
	ctx             context.Context
	cancel          context.CancelFunc
}

// LCT Trader structure
type LCTTrader struct {
	alpacaClient    *alpaca.Client
	baseCurrency    string
	positionTracker *MultiCurrencyPositionTracker
	logger          *log.Logger
}

type MultiCurrencyPositionTracker struct {
	positions map[string]map[string]decimal.Decimal
	mutex     sync.RWMutex
}

// Crypto Trader structure
type CryptoTrader struct {
	alpacaClient *alpaca.Client
	logger       *log.Logger
}

// Crypto Wallet structures
type CryptoWallet struct {
	ID               string
	Address          string
	Balance          decimal.Decimal
	AvailableBalance decimal.Decimal
	IsTestnet        bool
}

type CryptoWalletManager struct {
	wallets map[string][]*CryptoWallet
	logger  *log.Logger
}

// Journal structures
type JournalEntry struct {
	ID          string
	FromAccount string
	ToAccount   string
	EntryType   string
	Amount      decimal.Decimal
	Symbol      string
	Qty         decimal.Decimal
	Status      string
	CreatedAt   time.Time
	UpdatedAt   time.Time
	SettleDate  *time.Time
	Description string
}

type JournalManager struct {
	journals    []*JournalEntry
	firmAccount string
	sweepAccount string
	logger      *log.Logger
	mutex       sync.RWMutex
}

// Funding Wallets structures
type FundingWallet struct {
	ID            string          `json:"id"`
	AccountNumber string          `json:"account_number"`
	CreatedAt     time.Time       `json:"created_at"`
	UpdatedAt     time.Time       `json:"updated_at"`
	Status        string          `json:"status"`
	Currency      string          `json:"currency"`
	Balance       decimal.Decimal `json:"balance"`
}

type FundingDetails struct {
	AccountNumber     string `json:"account_number"`
	RoutingNumber     string `json:"routing_number"`
	BankName          string `json:"bank_name"`
	BankAddress       string `json:"bank_address"`
	BeneficiaryName   string `json:"beneficiary_name"`
	Reference         string `json:"reference"`
	SwiftCode         string `json:"swift_code,omitempty"`
}

type DepositRequest struct {
	Amount      decimal.Decimal `json:"amount"`
	Currency    string          `json:"currency"`
	Description string          `json:"description,omitempty"`
}

type WithdrawalRequest struct {
	Amount          decimal.Decimal `json:"amount"`
	Currency        string          `json:"currency"`
	RecipientBankID string          `json:"recipient_bank_id"`
	Description     string          `json:"description,omitempty"`
}

type Transfer struct {
	ID          string          `json:"id"`
	Type        string          `json:"type"` // "deposit" or "withdrawal"
	Amount      decimal.Decimal `json:"amount"`
	Currency    string          `json:"currency"`
	Status      string          `json:"status"`
	CreatedAt   time.Time       `json:"created_at"`
	UpdatedAt   time.Time       `json:"updated_at"`
	CompletedAt *time.Time      `json:"completed_at,omitempty"`
	Description string          `json:"description,omitempty"`
}

type RecipientBank struct {
	ID            string `json:"id"`
	AccountNumber string `json:"account_number"`
	RoutingNumber string `json:"routing_number"`
	BankName      string `json:"bank_name"`
	AccountName   string `json:"account_name"`
	Country       string `json:"country"`
	Currency      string `json:"currency"`
}

// Instant Funding structures
type InstantFundingTransfer struct {
	ID                string          `json:"id"`
	AccountNo         string          `json:"account_no"`
	SourceAccountNo   string          `json:"source_account_no"`
	Amount            decimal.Decimal `json:"amount"`
	RemainingPayable  decimal.Decimal `json:"remaining_payable"`
	Status            string          `json:"status"`
	CreatedAt         time.Time       `json:"created_at"`
	Deadline          string          `json:"deadline"`
	SystemDate        string          `json:"system_date"`
	TotalInterest     decimal.Decimal `json:"total_interest"`
}

type InstantFundingLimits struct {
	AmountAvailable decimal.Decimal `json:"amount_available"`
	AmountInUse     decimal.Decimal `json:"amount_in_use"`
	AmountLimit     decimal.Decimal `json:"amount_limit"`
}

type AccountLimits struct {
	AccountNo       string          `json:"account_no"`
	AmountAvailable decimal.Decimal `json:"amount_available"`
	AmountInUse     decimal.Decimal `json:"amount_in_use"`
	AmountLimit     decimal.Decimal `json:"amount_limit"`
}

type SettlementTransmitterInfo struct {
	OriginatorFullName         string `json:"originator_full_name"`
	OriginatorStreetAddress    string `json:"originator_street_address"`
	OriginatorCity             string `json:"originator_city"`
	OriginatorPostalCode       string `json:"originator_postal_code"`
	OriginatorCountry          string `json:"originator_country"`
	OriginatorBankAccountNumber string `json:"originator_bank_account_number"`
	OriginatorBankName         string `json:"originator_bank_name"`
}

type SettlementTransfer struct {
	InstantTransferID string                    `json:"instant_transfer_id"`
	TransmitterInfo   SettlementTransmitterInfo `json:"transmitter_info"`
}

type Settlement struct {
	ID                   string          `json:"id"`
	SourceAccountNumber  string          `json:"source_account_number"`
	TotalAmount          decimal.Decimal `json:"total_amount"`
	InterestAmount       decimal.Decimal `json:"interest_amount"`
	Status               string          `json:"status"`
	CreatedAt            time.Time       `json:"created_at"`
	UpdatedAt            time.Time       `json:"updated_at"`
	CompletedAt          *time.Time      `json:"completed_at,omitempty"`
	Reason               string          `json:"reason,omitempty"`
}

// Funding Manager
type FundingManager struct {
	alpacaClient     *alpaca.Client
	fundingWallets   map[string]*FundingWallet
	transfers        map[string]*Transfer
	recipientBanks   map[string]*RecipientBank
	instantTransfers map[string]*InstantFundingTransfer
	settlements      map[string]*Settlement
	logger           *log.Logger
	mutex            sync.RWMutex
}

// Trading Manager for enhanced order management
type TradingManager struct {
	alpacaClient     *alpaca.Client
	orders           map[string]*Order
	assets           map[string]*Asset
	configurations   map[string]*AccountConfiguration
	logger           *log.Logger
	mutex            sync.RWMutex
}

// MarketDataManager for handling market data feeds and analysis
type MarketDataManager struct {
	// Add fields as needed
}

// MarginTradingManager for handling margin-related operations
type MarginTradingManager struct {
	// Add fields as needed
}

// ==================== CONSTRUCTOR FUNCTIONS ====================

// NewAlpacaWebSocketClient creates a new WebSocket client
func NewAlpacaWebSocketClient(apiKey, apiSecret string, isPaper bool) *AlpacaWebSocketClient {
	url := WS_AUTH_URL_PAPER
	if !isPaper {
		url = WS_AUTH_URL_LIVE
	}
	
	ctx, cancel := context.WithCancel(context.Background())
	
	return &AlpacaWebSocketClient{
		apiKey:    apiKey,
		apiSecret: apiSecret,
		url:       url,
		logger:    logger,
		ctx:       ctx,
		cancel:    cancel,
	}
}

// NewLCTTrader creates a new Local Currency Trader
func NewLCTTrader(alpacaClient *alpaca.Client, baseCurrency string, logger *log.Logger) *LCTTrader {
	positionTracker := &MultiCurrencyPositionTracker{
		positions: make(map[string]map[string]decimal.Decimal),
	}
	
	return &LCTTrader{
		alpacaClient:    alpacaClient,
		baseCurrency:    baseCurrency,
		positionTracker: positionTracker,
		logger:          logger,
	}
}

// NewCryptoTrader creates a new Crypto Trader
func NewCryptoTrader(alpacaClient *alpaca.Client, logger *log.Logger) *CryptoTrader {
	return &CryptoTrader{
		alpacaClient: alpacaClient,
		logger:       logger,
	}
}

// NewCryptoWalletManager creates a new Crypto Wallet Manager
func NewCryptoWalletManager(logger *log.Logger) *CryptoWalletManager {
	return &CryptoWalletManager{
		wallets: make(map[string][]*CryptoWallet),
		logger:  logger,
	}
}

// NewJournalManager creates a new Journal Manager
func NewJournalManager(firmAccount string, logger *log.Logger) *JournalManager {
	sweepAccount := "sweep-" + firmAccount
	return &JournalManager{
		journals:     make([]*JournalEntry, 0),
		firmAccount:  firmAccount,
		sweepAccount: sweepAccount,
		logger:       logger,
	}
}

// NewFundingManager creates a new Funding Manager
func NewFundingManager(alpacaClient *alpaca.Client, logger *log.Logger) *FundingManager {
	return &FundingManager{
		alpacaClient:     alpacaClient,
		fundingWallets:   make(map[string]*FundingWallet),
		transfers:        make(map[string]*Transfer),
		recipientBanks:   make(map[string]*RecipientBank),
		instantTransfers: make(map[string]*InstantFundingTransfer),
		settlements:      make(map[string]*Settlement),
		logger:           logger,
	}
}

// NewTradingManager creates a new Trading Manager
func NewTradingManager(alpacaClient *alpaca.Client, logger *log.Logger) *TradingManager {
	return &TradingManager{
		alpacaClient:   alpacaClient,
		orders:         make(map[string]*Order),
		assets:         make(map[string]*Asset),
		configurations: make(map[string]*AccountConfiguration),
		logger:         logger,
	}
}

// generateRandomHex generates random hex string of specified length
func generateRandomHex(length int) string {
	bytes := make([]byte, (length+1)/2)
	rand.Read(bytes)
	hexStr := hex.EncodeToString(bytes)
	if len(hexStr) > length {
		return hexStr[:length]
	}
	return hexStr
}

// Initialize logging system
func initLogging() error {
	// Create log directory if it doesn't exist
	logDir := "/var/log/great-synapse"
	if err := os.MkdirAll(logDir, 0755); err != nil {
		// Fallback to home directory
		homeDir, _ := os.UserHomeDir()
		logDir = filepath.Join(homeDir, ".great-synapse", "logs")
		os.MkdirAll(logDir, 0755)
	}
	
	// Open log file with rotation support
	timestamp := time.Now().Format("20060102")
	logPath := filepath.Join(logDir, fmt.Sprintf("synapse_%s.log", timestamp))
	
	var err error
	logFile, err = os.OpenFile(logPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0644)
	if err != nil {
		return fmt.Errorf("failed to open log file: %v", err)
	}
	
	// Create multi-writer for both file and syslog
	logger = log.New(logFile, "[SYNAPSE] ", log.LstdFlags|log.Lmicroseconds)
	
	// Try to connect to syslog
	syslogWriter, err = syslog.New(syslog.LOG_INFO|syslog.LOG_DAEMON, "great-synapse")
	if err == nil {
		// Set multi-output logging
		logger.SetOutput(logFile) // Simplified for now
	}
	
	return nil
}

// Removed multi-writer for simplicity - logs go to file

// PID file management
func createPIDFile() error {
	pidPath := "/var/run/great-synapse.pid"
	
	// Try system location first
	pidFile, err := os.Create(pidPath)
	if err != nil {
		// Fallback to user directory
		homeDir, _ := os.UserHomeDir()
		pidPath = filepath.Join(homeDir, ".great-synapse", "synapse.pid")
		os.MkdirAll(filepath.Dir(pidPath), 0755)
		pidFile, err = os.Create(pidPath)
		if err != nil {
			return err
		}
	}
	defer pidFile.Close()
	
	_, err = fmt.Fprintf(pidFile, "%d\n", os.Getpid())
	return err
}

func removePIDFile() {
	paths := []string{
		"/var/run/great-synapse.pid",
		filepath.Join(os.Getenv("HOME"), ".great-synapse", "synapse.pid"),
	}
	
	for _, path := range paths {
		os.Remove(path)
	}
}

// THE IMMORTAL SYNAPSE - Daemon Version
type ImmortalSynapse struct {
	// Core components from unified system
	engineInitialized bool
	engineMutex       sync.RWMutex
	alpacaClient      *alpaca.Client
	marketClient      *marketdata.Client
	wsConn            *websocket.Conn
	
	// NEW: Enhanced Trading Capabilities
	websocketClient    *AlpacaWebSocketClient
	lctTrader         *LCTTrader
	cryptoTrader      *CryptoTrader
	cryptoWallets     *CryptoWalletManager
	journalManager    *JournalManager
	fundingManager    *FundingManager
	tradingManager    *TradingManager
	marketDataManager *MarketDataManager
	marginManager     *MarginTradingManager
	
	// Queues
	orderQueue  chan Order
	signalQueue chan Signal
	
	// Metrics
	ticksProcessed   uint64
	signalsGenerated uint64
	ordersExecuted   uint64
	startTime        time.Time
	
	// Control
	ctx    context.Context
	cancel context.CancelFunc
	wg     sync.WaitGroup
	
	// State persistence
	stateFile string
	
	// Health monitoring
	healthCheck     chan bool
	lastHealthCheck time.Time
}

// Enhanced Order structure supporting fractional shares and commissions
type Order struct {
	ID              string          `json:"id"`
	ClientOrderID   string          `json:"client_order_id,omitempty"`
	Symbol          string          `json:"symbol"`
	AssetClass      string          `json:"asset_class"`
	Side            string          `json:"side"` // buy, sell
	OrderType       string          `json:"order_type"` // market, limit, stop, stop_limit, trailing_stop
	TimeInForce     string          `json:"time_in_force"` // day, gtc, ioc, fok
	
	// Fractional shares support - mutually exclusive
	Quantity        *decimal.Decimal `json:"qty,omitempty"`
	Notional        *decimal.Decimal `json:"notional,omitempty"`
	
	// Pricing
	LimitPrice      *decimal.Decimal `json:"limit_price,omitempty"`
	StopPrice       *decimal.Decimal `json:"stop_price,omitempty"`
	TrailPercent    *decimal.Decimal `json:"trail_percent,omitempty"`
	TrailPrice      *decimal.Decimal `json:"trail_price,omitempty"`
	
	// Commission features
	Commission      *decimal.Decimal `json:"commission,omitempty"`
	CommissionType  string          `json:"commission_type,omitempty"` // notional, qty, bps
	
	// Order management
	Status          string          `json:"status"`
	FilledQty       decimal.Decimal `json:"filled_qty"`
	FilledAvgPrice  decimal.Decimal `json:"filled_avg_price"`
	ExtendedHours   bool            `json:"extended_hours"`
	
	// Omnibus sub-tagging
	Subtag          string          `json:"subtag,omitempty"`
	
	// Timestamps
	CreatedAt       time.Time       `json:"created_at"`
	UpdatedAt       time.Time       `json:"updated_at"`
	SubmittedAt     *time.Time      `json:"submitted_at,omitempty"`
	FilledAt        *time.Time      `json:"filled_at,omitempty"`
}

// Enhanced asset structure supporting fractional trading
type Asset struct {
	ID           string `json:"id"`
	Symbol       string `json:"symbol"`
	Name         string `json:"name"`
	AssetClass   string `json:"asset_class"`
	Exchange     string `json:"exchange"`
	Status       string `json:"status"`
	Tradable     bool   `json:"tradable"`
	Fractionable bool   `json:"fractionable"` // NEW: fractional shares support
	Marginable   bool   `json:"marginable"`
	Shortable    bool   `json:"shortable"`
}

// Account configuration with fractional trading
type AccountConfiguration struct {
	DaytradeMarginCall     string `json:"daytrade_margin_call"`
	TradeConfirmEmail      string `json:"trade_confirm_email"`
	SuspendTrade           bool   `json:"suspend_trade"`
	MaxMarginMultiplier    string `json:"max_margin_multiplier"`
	FractionalTrading      bool   `json:"fractional_trading"` // NEW: enable fractional trading
}

type Signal struct {
	Symbol      string
	Action      int32
	Confidence  float32
	TargetPrice float64
	Quantity    int64
	Timestamp   time.Time
}

// Initialize the Immortal Synapse
func InitializeImmortalSynapse() (*ImmortalSynapse, error) {
	logger.Println("════════════════════════════════════════════════")
	logger.Println("         THE IMMORTAL SYNAPSE AWAKENS          ")
	logger.Println("════════════════════════════════════════════════")
	
	// Initialize Zig HFT Engine
	logger.Println("Initializing Zig HFT Engine...")
	result := C.hft_init()
	if result != 0 {
		logger.Printf("⚠️ Zig engine init returned: %d (continuing without full HFT features)", result)
	} else {
		logger.Println("✅ Zig HFT engine initialized")
	}
	
	// Get API credentials from environment
	apiKey := os.Getenv("ALPACA_API_KEY")
	if apiKey == "" {
		apiKey = os.Getenv("APCA_API_KEY_ID")
	}
	
	apiSecret := os.Getenv("ALPACA_API_SECRET")
	if apiSecret == "" {
		apiSecret = os.Getenv("APCA_API_SECRET_KEY")
	}
	
	// Initialize Alpaca clients
	logger.Println("Connecting to market data feeds...")
	alpacaClient := alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret,
		BaseURL:   "https://paper-api.alpaca.markets",
	})
	
	marketClient := marketdata.NewClient(marketdata.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret,
	})
	
	ctx, cancel := context.WithCancel(context.Background())
	
	// Determine state file location
	stateDir := "/var/lib/great-synapse"
	if err := os.MkdirAll(stateDir, 0755); err != nil {
		homeDir, _ := os.UserHomeDir()
		stateDir = filepath.Join(homeDir, ".great-synapse", "state")
		os.MkdirAll(stateDir, 0755)
	}
	
	// Initialize enhanced trading capabilities
	logger.Println("Initializing WebSocket streaming...")
	websocketClient := NewAlpacaWebSocketClient(apiKey, apiSecret, false)
	
	logger.Println("Initializing Local Currency Trading...")
	lctTrader := NewLCTTrader(alpacaClient, "USD", logger)
	
	logger.Println("Initializing Crypto Trading...")
	cryptoTrader := NewCryptoTrader(alpacaClient, logger)
	
	logger.Println("Initializing Crypto Wallets...")
	cryptoWallets := NewCryptoWalletManager(logger)
	
	logger.Println("Initializing Journals API...")
	journalManager := NewJournalManager("firm-synapse-001", logger)
	
	logger.Println("Initializing Funding Manager...")
	fundingManager := NewFundingManager(alpacaClient, logger)
	
	logger.Println("Initializing Trading Manager...")
	tradingManager := NewTradingManager(alpacaClient, logger)
	
	synapse := &ImmortalSynapse{
		engineInitialized: true,
		alpacaClient:      alpacaClient,
		marketClient:      marketClient,
		websocketClient:   websocketClient,
		lctTrader:        lctTrader,
		cryptoTrader:     cryptoTrader,
		cryptoWallets:    cryptoWallets,
		journalManager:   journalManager,
		fundingManager:   fundingManager,
		tradingManager:   tradingManager,
		orderQueue:       make(chan Order, 1000),
		signalQueue:      make(chan Signal, 1000),
		ctx:              ctx,
		cancel:           cancel,
		stateFile:        filepath.Join(stateDir, "synapse.state"),
		healthCheck:      make(chan bool, 1),
		startTime:        time.Now(),
	}
	
	logger.Println("✅ Immortal Synapse initialized")
	return synapse, nil
}

// Main daemon loop
func (is *ImmortalSynapse) RunDaemon() error {
	logger.Println("Starting daemon operations...")
	
	// Load previous state if exists
	is.loadState()
	
	// Start core services
	is.wg.Add(1)
	go is.marketDataService()
	
	is.wg.Add(1)
	go is.signalProcessingService()
	
	is.wg.Add(1)
	go is.orderExecutionService()
	
	is.wg.Add(1)
	go is.metricsService()
	
	is.wg.Add(1)
	go is.healthMonitorService()
	
	// START ENHANCED TRADING SERVICES
	logger.Println("Starting enhanced trading capabilities...")
	
	is.wg.Add(1)
	go is.websocketStreamingService()
	
	is.wg.Add(1)
	go is.cryptoTradingService()
	
	is.wg.Add(1)
	go is.journalingService()
	
	is.wg.Add(1)
	go is.fundingService()
	
	logger.Println("✅ All services started")
	
	// Setup signal handlers
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM, syscall.SIGHUP)
	
	for {
		select {
		case sig := <-sigChan:
			switch sig {
			case syscall.SIGHUP:
				logger.Println("Received SIGHUP - reloading configuration")
				is.reloadConfig()
			case syscall.SIGINT, syscall.SIGTERM:
				logger.Println("Received shutdown signal")
				return is.shutdown()
			}
		case <-is.ctx.Done():
			return is.shutdown()
		}
	}
}

// Market data service
func (is *ImmortalSynapse) marketDataService() {
	defer is.wg.Done()
	
	symbols := []string{"AAPL", "MSFT", "GOOGL", "TSLA", "AMZN", "META", "NVDA"}
	ticker := time.NewTicker(100 * time.Millisecond)
	defer ticker.Stop()
	
	sequence := uint64(0)
	
	for {
		select {
		case <-is.ctx.Done():
			return
		case <-ticker.C:
			for _, symbol := range symbols {
				is.processTick(symbol, sequence)
				sequence++
			}
		}
	}
}

// Process market tick
func (is *ImmortalSynapse) processTick(symbol string, sequence uint64) {
	// Generate tick (in production, from WebSocket)
	price := is.generatePrice(symbol)
	
	symbolCStr := C.CString(symbol)
	defer C.free(unsafe.Pointer(symbolCStr))
	
	tick := C.CMarketTick{
		symbol_ptr:      symbolCStr,
		symbol_len:      C.uint32_t(len(symbol)),
		bid_value:       C.int64_t((price - 0.01) * 1000000000),
		ask_value:       C.int64_t((price + 0.01) * 1000000000),
		bid_size_value:  C.int64_t(100 * 1000000000),
		ask_size_value:  C.int64_t(100 * 1000000000),
		timestamp:       C.int64_t(time.Now().Unix()),
		sequence:        C.uint64_t(sequence),
	}
	
	result := C.hft_process_tick(&tick)
	if result == 0 {
		atomic.AddUint64(&is.ticksProcessed, 1)
		is.checkForSignals()
	}
}

// Signal processing service
func (is *ImmortalSynapse) signalProcessingService() {
	defer is.wg.Done()
	
	for {
		select {
		case <-is.ctx.Done():
			return
		case signal := <-is.signalQueue:
			is.processSignal(signal)
		}
	}
}

// Order execution service
func (is *ImmortalSynapse) orderExecutionService() {
	defer is.wg.Done()
	
	for {
		select {
		case <-is.ctx.Done():
			return
		case order := <-is.orderQueue:
			is.executeOrder(order)
		}
	}
}

// Metrics service
func (is *ImmortalSynapse) metricsService() {
	defer is.wg.Done()
	
	ticker := time.NewTicker(30 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-is.ctx.Done():
			return
		case <-ticker.C:
			is.logMetrics()
		}
	}
}

// Health monitor service
func (is *ImmortalSynapse) healthMonitorService() {
	defer is.wg.Done()
	
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-is.ctx.Done():
			return
		case <-ticker.C:
			is.performHealthCheck()
		case <-is.healthCheck:
			is.lastHealthCheck = time.Now()
		}
	}
}

// Log metrics
func (is *ImmortalSynapse) logMetrics() {
	var stats C.CSystemStats
	C.hft_get_stats(&stats)
	
	uptime := time.Since(is.startTime)
	tps := float64(atomic.LoadUint64(&is.ticksProcessed)) / uptime.Seconds()
	
	logger.Printf("METRICS: uptime=%v ticks=%d signals=%d orders=%d tps=%.2f latency=%dμs",
		uptime.Round(time.Second),
		atomic.LoadUint64(&is.ticksProcessed),
		atomic.LoadUint64(&is.signalsGenerated),
		atomic.LoadUint64(&is.ordersExecuted),
		tps,
		uint64(stats.avg_latency_us))
}

// Health check
func (is *ImmortalSynapse) performHealthCheck() {
	// Check Zig engine
	var stats C.CSystemStats
	result := C.hft_get_stats(&stats)
	if result != 0 {
		logger.Printf("WARNING: Zig engine health check failed")
		return
	}
	
	// Check market connection
	if is.wsConn != nil {
		if err := is.wsConn.WriteMessage(websocket.PingMessage, nil); err != nil {
			logger.Printf("WARNING: WebSocket health check failed: %v", err)
			// Attempt reconnection
			go is.reconnectWebSocket()
		}
	}
	
	// Update health status
	select {
	case is.healthCheck <- true:
	default:
	}
}

// Helper functions
func (is *ImmortalSynapse) generatePrice(symbol string) float64 {
	prices := map[string]float64{
		"AAPL":  150.25,
		"MSFT":  380.75,
		"GOOGL": 140.50,
		"TSLA":  245.00,
		"AMZN":  185.25,
		"META":  520.00,
		"NVDA":  890.00,
	}
	
	base := prices[symbol]
	if base == 0 {
		base = 100.0
	}
	
	// Add random walk
	return base + math.Sin(float64(time.Now().UnixNano()))*2
}

func (is *ImmortalSynapse) checkForSignals() {
	var cSignal C.CSignal
	result := C.hft_get_next_signal(&cSignal)
	
	if result > 0 {
		symbolSlice := C.GoStringN(cSignal.symbol_ptr, C.int(cSignal.symbol_len))
		
		signal := Signal{
			Symbol:      symbolSlice,
			Action:      int32(cSignal.action),
			Confidence:  float32(cSignal.confidence),
			TargetPrice: float64(cSignal.target_price_value) / 1000000000.0,
			Quantity:    int64(cSignal.quantity_value) / 1000000000,
			Timestamp:   time.Now(),
		}
		
		select {
		case is.signalQueue <- signal:
			atomic.AddUint64(&is.signalsGenerated, 1)
		default:
		}
	}
}

func (is *ImmortalSynapse) processSignal(signal Signal) {
	if signal.Confidence < 0.65 {
		return
	}
	
	side := "buy"
	if signal.Action == 2 {
		side = "sell"
	}
	
	quantity := decimal.NewFromInt(signal.Quantity)
	order := Order{
		ID:            generateRandomHex(16),
		Symbol:        signal.Symbol,
		AssetClass:    "us_equity",
		Side:          side,
		OrderType:     "market",
		TimeInForce:   "day",
		Quantity:      &quantity,
		Status:        "new",
		FilledQty:     decimal.Zero,
		FilledAvgPrice: decimal.Zero,
		ExtendedHours: false,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}
	
	select {
	case is.orderQueue <- order:
	default:
		logger.Printf("Order queue full for %s", signal.Symbol)
	}
}

func (is *ImmortalSynapse) executeOrder(order Order) {
	// Log order attempt
	logger.Printf("TRADE: %s %s %s", order.Side, order.Quantity, order.Symbol)
	
	// In production, execute via Alpaca
	atomic.AddUint64(&is.ordersExecuted, 1)
}

func (is *ImmortalSynapse) reconnectWebSocket() {
	logger.Println("Attempting WebSocket reconnection...")
	// WebSocket reconnection logic
}

func (is *ImmortalSynapse) reloadConfig() {
	logger.Println("Reloading configuration...")
	// Configuration reload logic
}

func (is *ImmortalSynapse) loadState() {
	logger.Println("Loading previous state...")
	// State loading logic
}

func (is *ImmortalSynapse) saveState() {
	logger.Println("Saving current state...")
	// State saving logic
}

func (is *ImmortalSynapse) shutdown() error {
	logger.Println("Initiating graceful shutdown...")
	
	// Cancel context
	is.cancel()
	
	// Wait for services with timeout
	done := make(chan struct{})
	go func() {
		is.wg.Wait()
		close(done)
	}()
	
	select {
	case <-done:
		logger.Println("All services stopped")
	case <-time.After(10 * time.Second):
		logger.Println("Shutdown timeout - forcing exit")
	}
	
	// Save state
	is.saveState()
	
	// Cleanup Zig engine
	if is.engineInitialized {
		C.hft_cleanup()
		logger.Println("✅ Zig engine cleaned up")
	}
	
	// Final metrics
	is.logMetrics()
	
	// Remove PID file
	removePIDFile()
	
	logger.Println("Shutdown complete")
	return nil
}

// ENHANCED SERVICES

// WebSocket streaming service for real-time trade updates
func (is *ImmortalSynapse) websocketStreamingService() {
	defer is.wg.Done()
	logger.Println("🌐 WebSocket Streaming Service started")
	
	// Connect to WebSocket
	if err := is.websocketClient.Connect(); err != nil {
		logger.Printf("❌ WebSocket connection failed: %v", err)
		return
	}
	defer is.websocketClient.Disconnect()
	
	for {
		select {
		case <-is.ctx.Done():
			logger.Println("WebSocket Streaming Service stopping...")
			return
		default:
			// Process real-time updates
			time.Sleep(50 * time.Millisecond)
		}
	}
}

// Crypto trading service for 24/7 cryptocurrency operations
func (is *ImmortalSynapse) cryptoTradingService() {
	defer is.wg.Done()
	logger.Println("₿ Crypto Trading Service started")
	
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-is.ctx.Done():
			logger.Println("Crypto Trading Service stopping...")
			return
		case <-ticker.C:
			// Monitor crypto markets (24/7 operation)
			// This runs continuously even when traditional markets are closed
		}
	}
}

// Journaling service for fund movement and compliance
func (is *ImmortalSynapse) journalingService() {
	defer is.wg.Done()
	logger.Println("📋 Journaling Service started")
	
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-is.ctx.Done():
			logger.Println("Journaling Service stopping...")
			return
		case <-ticker.C:
			// Process pending journal entries
			// Handle cash pooling and securities movement
		}
	}
}

// Funding service for wallet management and instant funding
func (is *ImmortalSynapse) fundingService() {
	defer is.wg.Done()
	logger.Println("💰 Funding Service started")
	
	ticker := time.NewTicker(3 * time.Second)
	defer ticker.Stop()
	
	for {
		select {
		case <-is.ctx.Done():
			logger.Println("Funding Service stopping...")
			return
		case <-ticker.C:
			// Monitor funding wallets and instant transfers
			// Process deposits, withdrawals, and settlements
			is.fundingManager.ProcessPendingTransfers()
		}
	}
}

// WebSocket Connect method
func (wsc *AlpacaWebSocketClient) Connect() error {
	logger.Printf("Connecting to WebSocket: %s", wsc.url)
	return nil // Placeholder implementation
}

// WebSocket Disconnect method  
func (wsc *AlpacaWebSocketClient) Disconnect() {
	logger.Println("WebSocket disconnected")
}

// ==================== FUNDING MANAGER METHODS ====================

// CreateFundingWallet creates a dedicated funding wallet for deposits
func (fm *FundingManager) CreateFundingWallet(accountID string, currency string) (*FundingWallet, error) {
	fm.mutex.Lock()
	defer fm.mutex.Unlock()
	
	walletID := generateRandomHex(16)
	accountNumber := fmt.Sprintf("FW-%s-%s", accountID[:8], generateRandomHex(8))
	
	wallet := &FundingWallet{
		ID:            walletID,
		AccountNumber: accountNumber,
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
		Status:        "active",
		Currency:      currency,
		Balance:       decimal.Zero,
	}
	
	fm.fundingWallets[walletID] = wallet
	fm.logger.Printf("💼 Created funding wallet %s for account %s", walletID[:8]+"...", accountID[:8]+"...")
	
	return wallet, nil
}

// GetFundingDetails returns banking details for deposits
func (fm *FundingManager) GetFundingDetails(walletID string) (*FundingDetails, error) {
	fm.mutex.RLock()
	wallet, exists := fm.fundingWallets[walletID]
	fm.mutex.RUnlock()
	
	if !exists {
		return nil, fmt.Errorf("funding wallet %s not found", walletID)
	}
	
	details := &FundingDetails{
		AccountNumber:   wallet.AccountNumber,
		RoutingNumber:   "021000021", // Example routing number
		BankName:        "Alpaca Securities LLC",
		BankAddress:     "20 W 22nd St, New York, NY 10010",
		BeneficiaryName: fmt.Sprintf("Customer Account %s", wallet.AccountNumber),
		Reference:       fmt.Sprintf("DEPOSIT-%s", wallet.ID[:8]),
		SwiftCode:       "DTCYUS33XXX",
	}
	
	return details, nil
}

// CreateInstantFundingTransfer provides immediate buying power
func (fm *FundingManager) CreateInstantFundingTransfer(accountNo, sourceAccountNo string, amount decimal.Decimal) (*InstantFundingTransfer, error) {
	fm.mutex.Lock()
	defer fm.mutex.Unlock()
	
	transferID := generateRandomHex(16)
	today := time.Now()
	deadline := today.AddDate(0, 0, 1).Format("2006-01-02") // T+1
	systemDate := today.Format("2006-01-02")
	
	transfer := &InstantFundingTransfer{
		ID:               transferID,
		AccountNo:        accountNo,
		SourceAccountNo:  sourceAccountNo,
		Amount:           amount,
		RemainingPayable: amount,
		Status:           INSTANT_STATUS_PENDING,
		CreatedAt:        today,
		Deadline:         deadline,
		SystemDate:       systemDate,
		TotalInterest:    decimal.Zero,
	}
	
	fm.instantTransfers[transferID] = transfer
	fm.logger.Printf("⚡ Instant funding: $%s to %s (deadline: %s)", 
		amount.String(), accountNo[:8]+"...", deadline)
	
	// Simulate moving to EXECUTED status
	go func() {
		time.Sleep(1 * time.Second)
		fm.mutex.Lock()
		transfer.Status = INSTANT_STATUS_EXECUTED
		fm.mutex.Unlock()
		fm.logger.Printf("✅ Instant funding %s executed", transferID[:8]+"...")
	}()
	
	return transfer, nil
}

// GetInstantFundingLimits returns available limits
func (fm *FundingManager) GetInstantFundingLimits() *InstantFundingLimits {
	fm.mutex.RLock()
	defer fm.mutex.RUnlock()
	
	totalLimit := decimal.NewFromInt(100000) // $100k default limit
	inUse := decimal.Zero
	
	for _, transfer := range fm.instantTransfers {
		if transfer.Status == INSTANT_STATUS_EXECUTED || transfer.Status == INSTANT_STATUS_PENDING {
			inUse = inUse.Add(transfer.RemainingPayable)
		}
	}
	
	available := totalLimit.Sub(inUse)
	
	return &InstantFundingLimits{
		AmountAvailable: available,
		AmountInUse:     inUse,
		AmountLimit:     totalLimit,
	}
}

// CreateSettlement processes bulk settlement for instant transfers
func (fm *FundingManager) CreateSettlement(transfers []SettlementTransfer, additionalInfo string) (*Settlement, error) {
	fm.mutex.Lock()
	defer fm.mutex.Unlock()
	
	settlementID := generateRandomHex(16)
	totalAmount := decimal.Zero
	sourceAccount := "SI-firm-synapse-001" // Settlement account
	
	// Calculate total amount
	for _, transfer := range transfers {
		if instantTransfer, exists := fm.instantTransfers[transfer.InstantTransferID]; exists {
			totalAmount = totalAmount.Add(instantTransfer.RemainingPayable)
		}
	}
	
	settlement := &Settlement{
		ID:                  settlementID,
		SourceAccountNumber: sourceAccount,
		TotalAmount:         totalAmount,
		InterestAmount:      decimal.Zero,
		Status:              "PENDING",
		CreatedAt:           time.Now(),
		UpdatedAt:           time.Now(),
	}
	
	fm.settlements[settlementID] = settlement
	fm.logger.Printf("💸 Settlement created: $%s from %d transfers", 
		totalAmount.String(), len(transfers))
	
	// Simulate settlement processing
	go func() {
		time.Sleep(2 * time.Second)
		fm.mutex.Lock()
		settlement.Status = "COMPLETED"
		completedAt := time.Now()
		settlement.CompletedAt = &completedAt
		settlement.UpdatedAt = completedAt
		
		// Mark instant transfers as settled
		for _, transfer := range transfers {
			if instantTransfer, exists := fm.instantTransfers[transfer.InstantTransferID]; exists {
				instantTransfer.Status = INSTANT_STATUS_COMPLETED
				instantTransfer.RemainingPayable = decimal.Zero
			}
		}
		fm.mutex.Unlock()
		
		fm.logger.Printf("✅ Settlement %s completed", settlementID[:8]+"...")
	}()
	
	return settlement, nil
}

// ProcessPendingTransfers monitors and processes transfers
func (fm *FundingManager) ProcessPendingTransfers() {
	fm.mutex.RLock()
	pendingCount := 0
	for _, transfer := range fm.transfers {
		if transfer.Status == FUNDING_STATUS_PENDING {
			pendingCount++
		}
	}
	
	instantPending := 0
	for _, instant := range fm.instantTransfers {
		if instant.Status == INSTANT_STATUS_PENDING || instant.Status == INSTANT_STATUS_EXECUTED {
			instantPending++
		}
	}
	fm.mutex.RUnlock()
	
	if pendingCount > 0 || instantPending > 0 {
		fm.logger.Printf("🔄 Processing: %d funding transfers, %d instant transfers pending", 
			pendingCount, instantPending)
	}
}

func main() {
	// Initialize logging
	if err := initLogging(); err != nil {
		fmt.Fprintf(os.Stderr, "Failed to initialize logging: %v\n", err)
		os.Exit(1)
	}
	defer logFile.Close()
	
	// Create PID file
	if err := createPIDFile(); err != nil {
		logger.Printf("Failed to create PID file: %v", err)
	}
	
	// Initialize the Immortal Synapse
	synapse, err := InitializeImmortalSynapse()
	if err != nil {
		logger.Fatalf("Failed to initialize: %v", err)
	}
	
	// Run as daemon
	if err := synapse.RunDaemon(); err != nil {
		logger.Printf("Daemon error: %v", err)
	}
	
	logger.Println("THE IMMORTAL SYNAPSE RESTS")
}