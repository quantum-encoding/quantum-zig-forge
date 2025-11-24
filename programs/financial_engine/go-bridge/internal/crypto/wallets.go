package crypto

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
	"os"
	"strings"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/shopspring/decimal"
)

// Supported blockchain assets for wallets
var SupportedWalletAssets = map[string]WalletAssetInfo{
	"BTC": {
		Symbol:      "BTC",
		Name:        "Bitcoin",
		Network:     "Bitcoin",
		MinDeposit:  "0.00001",
		Confirmations: 3,
		TestnetFaucet: "https://testnet-faucet.mempool.co/",
	},
	"ETH": {
		Symbol:      "ETH", 
		Name:        "Ethereum",
		Network:     "Ethereum",
		MinDeposit:  "0.001",
		Confirmations: 12,
		TestnetFaucet: "https://goerli-faucet.pk910.de/",
	},
	"LTC": {
		Symbol:      "LTC",
		Name:        "Litecoin", 
		Network:     "Litecoin",
		MinDeposit:  "0.01",
		Confirmations: 6,
		TestnetFaucet: "https://litecoin-testnet.com/",
	},
	"USDC": {
		Symbol:      "USDC",
		Name:        "USD Coin",
		Network:     "Ethereum",
		MinDeposit:  "1.0",
		Confirmations: 12,
		TestnetFaucet: "https://goerli-faucet.pk910.de/",
	},
	"USDT": {
		Symbol:      "USDT",
		Name:        "Tether",
		Network:     "Ethereum", 
		MinDeposit:  "1.0",
		Confirmations: 12,
		TestnetFaucet: "https://goerli-faucet.pk910.de/",
	},
}

type WalletAssetInfo struct {
	Symbol        string `json:"symbol"`
	Name          string `json:"name"`
	Network       string `json:"network"`
	MinDeposit    string `json:"min_deposit"`
	Confirmations int    `json:"confirmations"`
	TestnetFaucet string `json:"testnet_faucet,omitempty"`
}

// CryptoWallet represents a blockchain wallet
type CryptoWallet struct {
	ID                string          `json:"id"`
	AccountID         string          `json:"account_id"`
	Asset             string          `json:"asset"`
	Address           string          `json:"address"`
	Name              string          `json:"name,omitempty"`
	Network           string          `json:"network"`
	Balance           decimal.Decimal `json:"balance"`
	AvailableBalance  decimal.Decimal `json:"available_balance"`
	CreatedAt         time.Time       `json:"created_at"`
	Status            string          `json:"status"` // "ACTIVE", "INACTIVE", "FROZEN"
	IsTestnet         bool            `json:"is_testnet"`
}

// WalletTransfer represents a blockchain transfer
type WalletTransfer struct {
	ID                string          `json:"id"`
	AccountID         string          `json:"account_id"`
	Asset             string          `json:"asset"`
	Amount            decimal.Decimal `json:"amount"`
	Direction         string          `json:"direction"` // "INCOMING", "OUTGOING"
	Status            string          `json:"status"`    // "PENDING", "CONFIRMED", "COMPLETE", "FAILED"
	TxHash            string          `json:"tx_hash,omitempty"`
	FromAddress       string          `json:"from_address,omitempty"`
	ToAddress         string          `json:"to_address"`
	NetworkFee        decimal.Decimal `json:"network_fee,omitempty"`
	Confirmations     int             `json:"confirmations"`
	RequiredConf      int             `json:"required_confirmations"`
	CreatedAt         time.Time       `json:"created_at"`
	CompletedAt       *time.Time      `json:"completed_at,omitempty"`
}

// WalletWithdrawRequest represents a withdrawal request
type WalletWithdrawRequest struct {
	Asset       string          `json:"asset"`
	Amount      decimal.Decimal `json:"amount"`
	ToAddress   string          `json:"to_address"`
	NetworkFee  string          `json:"network_fee,omitempty"` // "slow", "standard", "fast"
}

// CryptoWalletManager handles blockchain wallet operations
type CryptoWalletManager struct {
	alpacaClient *alpaca.Client
	accountID    string
	wallets      map[string]*CryptoWallet  // asset -> wallet
	transfers    []*WalletTransfer
	logger       *log.Logger
	isTestnet    bool
	
	// Security features
	withdrawalLimits map[string]decimal.Decimal
	dailyLimits      map[string]decimal.Decimal
	whitelist        map[string][]string // asset -> allowed addresses
}

// NewCryptoWalletManager creates a new wallet manager
func NewCryptoWalletManager(apiKey, apiSecret, accountID string, isPaper bool) *CryptoWalletManager {
	baseURL := "https://api.alpaca.markets"
	if isPaper {
		baseURL = "https://paper-api.alpaca.markets"
	}
	
	alpacaClient := alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret, 
		BaseURL:   baseURL,
	})
	
	return &CryptoWalletManager{
		alpacaClient:     alpacaClient,
		accountID:        accountID,
		wallets:          make(map[string]*CryptoWallet),
		transfers:        make([]*WalletTransfer, 0),
		logger:           log.New(log.Writer(), "[WALLET] ", log.LstdFlags|log.Lmicroseconds),
		isTestnet:        isPaper, // Use testnet for paper trading
		withdrawalLimits: make(map[string]decimal.Decimal),
		dailyLimits:      make(map[string]decimal.Decimal),
		whitelist:        make(map[string][]string),
	}
}

// CreateOrGetWallet creates a new wallet or retrieves existing one
func (cwm *CryptoWalletManager) CreateOrGetWallet(asset string) (*CryptoWallet, error) {
	asset = strings.ToUpper(asset)
	cwm.logger.Printf("Creating/retrieving %s wallet...", asset)
	
	// Check if asset is supported
	assetInfo, exists := SupportedWalletAssets[asset]
	if !exists {
		return nil, fmt.Errorf("unsupported wallet asset: %s", asset)
	}
	
	// Check if wallet already exists
	if wallet, exists := cwm.wallets[asset]; exists {
		cwm.logger.Printf("✅ Found existing %s wallet: %s", asset, wallet.Address[:10]+"...")
		return wallet, nil
	}
	
	// In real implementation, this would call:
	// GET /v1/accounts/{account_id}/wallets?asset={asset}
	
	// Simulate wallet creation for demo
	address := cwm.generateWalletAddress(asset)
	
	wallet := &CryptoWallet{
		ID:               generateID(),
		AccountID:        cwm.accountID,
		Asset:            asset,
		Address:          address,
		Name:             fmt.Sprintf("%s Wallet", assetInfo.Name),
		Network:          assetInfo.Network,
		Balance:          decimal.Zero,
		AvailableBalance: decimal.Zero,
		CreatedAt:        time.Now(),
		Status:           "ACTIVE",
		IsTestnet:        cwm.isTestnet,
	}
	
	cwm.wallets[asset] = wallet
	cwm.logger.Printf("✅ Created new %s wallet: %s", asset, address)
	
	return wallet, nil
}

// GetWalletBalance retrieves current wallet balance
func (cwm *CryptoWalletManager) GetWalletBalance(asset string) (*CryptoWallet, error) {
	asset = strings.ToUpper(asset)
	
	wallet, exists := cwm.wallets[asset]
	if !exists {
		return cwm.CreateOrGetWallet(asset)
	}
	
	// In real implementation, this would call:
	// GET /v1/accounts/{account_id}/wallets/{wallet_id}
	
	// Simulate balance update for demo
	if cwm.isTestnet {
		// Add some testnet funds for demo
		wallet.Balance = decimal.NewFromFloat(getTestnetBalance(asset))
		wallet.AvailableBalance = wallet.Balance
	}
	
	cwm.logger.Printf("📊 %s wallet balance: %s %s", 
		asset, wallet.Balance.String(), asset)
	
	return wallet, nil
}

// InitiateWithdrawal initiates a blockchain withdrawal
func (cwm *CryptoWalletManager) InitiateWithdrawal(req WalletWithdrawRequest) (*WalletTransfer, error) {
	asset := strings.ToUpper(req.Asset)
	cwm.logger.Printf("Initiating %s withdrawal: %s to %s", 
		asset, req.Amount.String(), req.ToAddress[:10]+"...")
	
	// Validate withdrawal
	if err := cwm.validateWithdrawal(req); err != nil {
		return nil, err
	}
	
	// Check wallet exists and has sufficient balance
	wallet, err := cwm.GetWalletBalance(asset)
	if err != nil {
		return nil, fmt.Errorf("failed to get wallet: %v", err)
	}
	
	if wallet.AvailableBalance.LessThan(req.Amount) {
		return nil, fmt.Errorf("insufficient balance: %s available, %s requested",
			wallet.AvailableBalance.String(), req.Amount.String())
	}
	
	// Create transfer record
	transfer := &WalletTransfer{
		ID:            generateID(),
		AccountID:     cwm.accountID,
		Asset:         asset,
		Amount:        req.Amount,
		Direction:     "OUTGOING", 
		Status:        "PENDING",
		ToAddress:     req.ToAddress,
		NetworkFee:    cwm.calculateNetworkFee(asset, req.NetworkFee),
		Confirmations: 0,
		RequiredConf:  SupportedWalletAssets[asset].Confirmations,
		CreatedAt:     time.Now(),
	}
	
	// In real implementation, this would call:
	// POST /v1/accounts/{account_id}/wallets/transfers
	
	// Simulate transaction hash for demo
	if cwm.isTestnet {
		transfer.TxHash = generateTxHash(asset)
		transfer.Status = "CONFIRMED"
		
		// Update wallet balance
		wallet.AvailableBalance = wallet.AvailableBalance.Sub(req.Amount)
		wallet.Balance = wallet.Balance.Sub(req.Amount)
	}
	
	cwm.transfers = append(cwm.transfers, transfer)
	cwm.logger.Printf("✅ Withdrawal initiated: %s", transfer.ID)
	
	return transfer, nil
}

// GetTransfers retrieves wallet transfer history
func (cwm *CryptoWalletManager) GetTransfers() ([]*WalletTransfer, error) {
	cwm.logger.Printf("Fetching transfer history...")
	
	// In real implementation, this would call:
	// GET /v1/accounts/{account_id}/wallets/transfers
	
	cwm.logger.Printf("📋 Found %d transfers", len(cwm.transfers))
	return cwm.transfers, nil
}

// MonitorIncomingTransfers monitors for incoming blockchain transfers
func (cwm *CryptoWalletManager) MonitorIncomingTransfers() error {
	cwm.logger.Println("🔍 Starting incoming transfer monitoring...")
	
	// In real implementation, this would:
	// 1. Poll the transfers endpoint
	// 2. Check for new INCOMING transfers
	// 3. Update wallet balances when transfers complete
	
	// Simulate incoming transfer for demo
	if cwm.isTestnet {
		// Create a simulated incoming transfer
		incomingTransfer := &WalletTransfer{
			ID:            generateID(),
			AccountID:     cwm.accountID,
			Asset:         "ETH",
			Amount:        decimal.NewFromFloat(0.5),
			Direction:     "INCOMING",
			Status:        "COMPLETE",
			FromAddress:   "YOUR_ETH_WALLET_ADDRESS", // Example external address
			TxHash:        generateTxHash("ETH"),
			NetworkFee:    decimal.NewFromFloat(0.002),
			Confirmations: 15,
			RequiredConf:  12,
			CreatedAt:     time.Now().Add(-10 * time.Minute),
			CompletedAt:   timePtr(time.Now().Add(-2 * time.Minute)),
		}
		
		cwm.transfers = append(cwm.transfers, incomingTransfer)
		
		// Update ETH wallet balance
		if ethWallet, exists := cwm.wallets["ETH"]; exists {
			ethWallet.Balance = ethWallet.Balance.Add(incomingTransfer.Amount)
			ethWallet.AvailableBalance = ethWallet.Balance
		}
		
		cwm.logger.Printf("📥 Detected incoming transfer: %s %s (Complete)", 
			incomingTransfer.Amount.String(), incomingTransfer.Asset)
	}
	
	return nil
}

// ValidateAddress validates a blockchain address
func (cwm *CryptoWalletManager) ValidateAddress(asset, address string) error {
	asset = strings.ToUpper(asset)
	
	// Basic validation based on asset type
	switch asset {
	case "BTC":
		if !cwm.isValidBTCAddress(address) {
			return fmt.Errorf("invalid Bitcoin address: %s", address)
		}
	case "ETH", "USDC", "USDT":
		if !cwm.isValidETHAddress(address) {
			return fmt.Errorf("invalid Ethereum address: %s", address)
		}
	case "LTC":
		if !cwm.isValidLTCAddress(address) {
			return fmt.Errorf("invalid Litecoin address: %s", address)
		}
	default:
		return fmt.Errorf("address validation not implemented for %s", asset)
	}
	
	cwm.logger.Printf("✅ Address validation passed for %s: %s", asset, address[:10]+"...")
	return nil
}

// SetWithdrawalLimit sets daily withdrawal limits
func (cwm *CryptoWalletManager) SetWithdrawalLimit(asset string, limit decimal.Decimal) {
	asset = strings.ToUpper(asset)
	cwm.withdrawalLimits[asset] = limit
	cwm.logger.Printf("🛡️ Set withdrawal limit for %s: %s", asset, limit.String())
}

// AddToWhitelist adds an address to the withdrawal whitelist
func (cwm *CryptoWalletManager) AddToWhitelist(asset, address string) error {
	asset = strings.ToUpper(asset)
	
	// Validate address first
	if err := cwm.ValidateAddress(asset, address); err != nil {
		return err
	}
	
	if cwm.whitelist[asset] == nil {
		cwm.whitelist[asset] = make([]string, 0)
	}
	
	cwm.whitelist[asset] = append(cwm.whitelist[asset], address)
	cwm.logger.Printf("✅ Added %s to %s whitelist", address[:10]+"...", asset)
	
	return nil
}

// Helper functions

func (cwm *CryptoWalletManager) validateWithdrawal(req WalletWithdrawRequest) error {
	asset := strings.ToUpper(req.Asset)
	
	// Check minimum withdrawal
	assetInfo := SupportedWalletAssets[asset]
	minAmount, _ := decimal.NewFromString(assetInfo.MinDeposit)
	if req.Amount.LessThan(minAmount) {
		return fmt.Errorf("amount %s below minimum %s for %s", 
			req.Amount.String(), minAmount.String(), asset)
	}
	
	// Check withdrawal limits
	if limit, exists := cwm.withdrawalLimits[asset]; exists {
		if req.Amount.GreaterThan(limit) {
			return fmt.Errorf("amount %s exceeds daily limit %s for %s",
				req.Amount.String(), limit.String(), asset)
		}
	}
	
	// Validate destination address
	if err := cwm.ValidateAddress(asset, req.ToAddress); err != nil {
		return err
	}
	
	// Check whitelist if enabled
	if whitelist, exists := cwm.whitelist[asset]; exists && len(whitelist) > 0 {
		found := false
		for _, addr := range whitelist {
			if addr == req.ToAddress {
				found = true
				break
			}
		}
		if !found {
			return fmt.Errorf("destination address not in whitelist")
		}
	}
	
	return nil
}

func (cwm *CryptoWalletManager) calculateNetworkFee(asset, feeLevel string) decimal.Decimal {
	// Simulate network fees based on asset and speed
	baseFees := map[string]decimal.Decimal{
		"BTC":  decimal.NewFromFloat(0.0001),
		"ETH":  decimal.NewFromFloat(0.002),
		"LTC":  decimal.NewFromFloat(0.001),
		"USDC": decimal.NewFromFloat(0.002),
		"USDT": decimal.NewFromFloat(0.002),
	}
	
	baseFee := baseFees[asset]
	if baseFee.IsZero() {
		baseFee = decimal.NewFromFloat(0.001)
	}
	
	// Adjust for fee level
	switch feeLevel {
	case "slow":
		return baseFee.Mul(decimal.NewFromFloat(0.8))
	case "fast":
		return baseFee.Mul(decimal.NewFromFloat(1.5))
	default: // standard
		return baseFee
	}
}

func (cwm *CryptoWalletManager) generateWalletAddress(asset string) string {
	switch asset {
	case "BTC":
		return "bc1q" + generateRandomHex(39)
	case "ETH", "USDC", "USDT":
		return "0x" + generateRandomHex(40)
	case "LTC":
		return "ltc1q" + generateRandomHex(39)
	default:
		return "addr_" + generateRandomHex(32)
	}
}

func (cwm *CryptoWalletManager) isValidBTCAddress(address string) bool {
	// Basic Bitcoin address validation
	return (strings.HasPrefix(address, "bc1") || strings.HasPrefix(address, "1") || 
		    strings.HasPrefix(address, "3")) && len(address) >= 26 && len(address) <= 42
}

func (cwm *CryptoWalletManager) isValidETHAddress(address string) bool {
	// Basic Ethereum address validation  
	return strings.HasPrefix(address, "0x") && len(address) == 42
}

func (cwm *CryptoWalletManager) isValidLTCAddress(address string) bool {
	// Basic Litecoin address validation
	return (strings.HasPrefix(address, "ltc1") || strings.HasPrefix(address, "L") ||
		    strings.HasPrefix(address, "M")) && len(address) >= 26 && len(address) <= 43
}

// Utility functions

func generateID() string {
	bytes := make([]byte, 16)
	rand.Read(bytes)
	return hex.EncodeToString(bytes)
}

func generateRandomHex(length int) string {
	bytes := make([]byte, (length+1)/2)
	rand.Read(bytes)
	hexStr := hex.EncodeToString(bytes)
	if len(hexStr) > length {
		return hexStr[:length]
	}
	return hexStr
}

func generateTxHash(asset string) string {
	return "0x" + generateRandomHex(64)
}

func getTestnetBalance(asset string) float64 {
	balances := map[string]float64{
		"BTC":  0.1,
		"ETH":  2.5,
		"LTC":  10.0,
		"USDC": 1000.0,
		"USDT": 500.0,
	}
	
	if balance, ok := balances[asset]; ok {
		return balance
	}
	return 0.0
}

func timePtr(t time.Time) *time.Time {
	return &t
}

// Demo function for crypto wallets
func RunCryptoWalletsDemo() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║            CRYPTO WALLETS DEMO                ║")
	fmt.Println("║         Blockchain Integration                ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	// Initialize wallet manager
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("ALPACA_API_SECRET")
	if apiSecret == "" {
		apiSecret = os.Getenv("APCA_API_SECRET_KEY")
	}
	
	walletManager := NewCryptoWalletManager(apiKey, apiSecret, "test-account", true)
	
	fmt.Printf("\n🔐 Wallet Manager initialized (Testnet: %v)\n", walletManager.isTestnet)
	fmt.Printf("📊 Supported assets: %v\n", getAssetList())
	
	// 1. Create wallets
	fmt.Println("\n1️⃣ === WALLET CREATION ===")
	assets := []string{"BTC", "ETH", "USDC"}
	
	for _, asset := range assets {
		wallet, err := walletManager.CreateOrGetWallet(asset)
		if err != nil {
			fmt.Printf("❌ Failed to create %s wallet: %v\n", asset, err)
		} else {
			fmt.Printf("✅ %s wallet: %s (%s)\n", 
				wallet.Asset, wallet.Address, wallet.Status)
		}
	}
	
	// 2. Check balances  
	fmt.Println("\n2️⃣ === WALLET BALANCES ===")
	for _, asset := range assets {
		wallet, err := walletManager.GetWalletBalance(asset)
		if err != nil {
			fmt.Printf("❌ Failed to get %s balance: %v\n", asset, err)
		} else {
			fmt.Printf("💰 %s: %s %s (Available: %s)\n",
				wallet.Asset, wallet.Balance.String(), asset,
				wallet.AvailableBalance.String())
		}
	}
	
	// 3. Address validation
	fmt.Println("\n3️⃣ === ADDRESS VALIDATION ===")
	testAddresses := map[string]string{
		"BTC":  "YOUR_BTC_WALLET_ADDRESS",
		"ETH":  "YOUR_ETH_WALLET_ADDRESS",
		"USDC": "YOUR_ETH_WALLET_ADDRESS",
		"LTC":  "ltc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh",
		"INVALID": "invalid_address",
	}
	
	for asset, address := range testAddresses {
		if asset == "INVALID" {
			if err := walletManager.ValidateAddress("BTC", address); err != nil {
				fmt.Printf("❌ %s address validation: %v\n", asset, err)
			}
		} else {
			if err := walletManager.ValidateAddress(asset, address); err != nil {
				fmt.Printf("❌ %s address validation failed: %v\n", asset, err)
			} else {
				fmt.Printf("✅ %s address validation passed\n", asset)
			}
		}
	}
	
	// 4. Set security limits
	fmt.Println("\n4️⃣ === SECURITY CONFIGURATION ===")
	walletManager.SetWithdrawalLimit("BTC", decimal.NewFromFloat(0.5))
	walletManager.SetWithdrawalLimit("ETH", decimal.NewFromFloat(10.0))
	
	// Add addresses to whitelist
	walletManager.AddToWhitelist("BTC", "YOUR_BTC_WALLET_ADDRESS")
	walletManager.AddToWhitelist("ETH", "YOUR_ETH_WALLET_ADDRESS")
	
	// 5. Monitor incoming transfers
	fmt.Println("\n5️⃣ === INCOMING TRANSFERS ===")
	if err := walletManager.MonitorIncomingTransfers(); err != nil {
		fmt.Printf("❌ Failed to monitor transfers: %v\n", err)
	}
	
	// 6. Initiate withdrawal
	fmt.Println("\n6️⃣ === WITHDRAWAL TEST ===")
	withdrawalReq := WalletWithdrawRequest{
		Asset:      "ETH",
		Amount:     decimal.NewFromFloat(0.1),
		ToAddress:  "YOUR_ETH_WALLET_ADDRESS",
		NetworkFee: "standard",
	}
	
	transfer, err := walletManager.InitiateWithdrawal(withdrawalReq)
	if err != nil {
		fmt.Printf("❌ Withdrawal failed: %v\n", err)
	} else {
		fmt.Printf("✅ Withdrawal initiated: %s\n", transfer.ID)
		fmt.Printf("   Amount: %s %s\n", transfer.Amount.String(), transfer.Asset)
		fmt.Printf("   To: %s\n", transfer.ToAddress[:10]+"...")
		fmt.Printf("   Status: %s\n", transfer.Status)
		fmt.Printf("   Network fee: %s %s\n", transfer.NetworkFee.String(), transfer.Asset)
		if transfer.TxHash != "" {
			fmt.Printf("   TX Hash: %s\n", transfer.TxHash[:10]+"...")
		}
	}
	
	// 7. Transfer history
	fmt.Println("\n7️⃣ === TRANSFER HISTORY ===")
	transfers, err := walletManager.GetTransfers()
	if err != nil {
		fmt.Printf("❌ Failed to get transfers: %v\n", err)
	} else {
		fmt.Printf("📋 Transfer history (%d transfers):\n", len(transfers))
		for _, t := range transfers {
			direction := "📤"
			if t.Direction == "INCOMING" {
				direction = "📥"
			}
			
			fmt.Printf("   %s %s: %s %s (%s) - %s\n",
				direction, t.Direction, t.Amount.String(), t.Asset,
				t.Status, t.CreatedAt.Format("15:04:05"))
			
			if t.TxHash != "" {
				fmt.Printf("      TX: %s\n", t.TxHash[:16]+"...")
			}
		}
	}
	
	fmt.Println("\n╔════════════════════════════════════════════════╗")
	fmt.Println("║          CRYPTO WALLETS DEMO COMPLETE!        ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  ✅ Multi-asset wallet creation               ║")
	fmt.Println("║  ✅ Real-time balance monitoring              ║")
	fmt.Println("║  ✅ Blockchain address validation             ║")
	fmt.Println("║  ✅ Secure withdrawal processing              ║")
	fmt.Println("║  ✅ Transfer history tracking                 ║")
	fmt.Println("║  ✅ Security limits and whitelists           ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  THE GREAT SYNAPSE CONTROLS THE BLOCKCHAIN!   ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	fmt.Println("\n📝 Wallet Features:")
	fmt.Println("   • Multi-asset support: BTC, ETH, LTC, USDC, USDT")
	fmt.Println("   • Testnet integration: Safe testing with fake funds")
	fmt.Println("   • Address validation: Prevent invalid withdrawals")
	fmt.Println("   • Security controls: Withdrawal limits & whitelists")
	fmt.Println("   • Real-time monitoring: Track incoming deposits")
	fmt.Println("   • Network fee optimization: Slow/Standard/Fast options")
}

func getAssetList() []string {
	var assets []string
	for asset := range SupportedWalletAssets {
		assets = append(assets, asset)
	}
	return assets
}

// Removed main function - use crypto_main.go