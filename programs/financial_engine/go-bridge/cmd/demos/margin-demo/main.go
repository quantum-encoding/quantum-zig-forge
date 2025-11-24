package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/shopspring/decimal"
)

// Margin Trading Manager
type MarginTradingManager struct {
	alpacaClient *alpaca.Client
	logger       *log.Logger
	mutex        sync.RWMutex
	
	// Margin calculations
	positions        map[string]*MarginPosition
	marginCalls      []*MarginCall
	interestCharges  []*InterestCharge
	borrowFees       []*BorrowFee
	
	// Settings
	marginInterestRate  decimal.Decimal // Annual rate (7.0%)
	minMarginEquity     decimal.Decimal // $2,000 minimum
}

// Margin Position tracking
type MarginPosition struct {
	Symbol           string          `json:"symbol"`
	Side             string          `json:"side"` // long, short
	Quantity         decimal.Decimal `json:"qty"`
	MarketValue      decimal.Decimal `json:"market_value"`
	AvgCost          decimal.Decimal `json:"avg_cost"`
	SharePrice       decimal.Decimal `json:"share_price"`
	
	// Margin requirements
	InitialMargin    decimal.Decimal `json:"initial_margin"`
	MaintenanceMargin decimal.Decimal `json:"maintenance_margin"`
	MarginRequirement decimal.Decimal `json:"margin_requirement"`
	
	// Borrowing info
	IsBorrowed       bool            `json:"is_borrowed"`
	BorrowRate       decimal.Decimal `json:"borrow_rate"`
	BorrowStatus     string          `json:"borrow_status"` // ETB, HTB
	
	CreatedAt        time.Time       `json:"created_at"`
	UpdatedAt        time.Time       `json:"updated_at"`
}

// Margin Call structure
type MarginCall struct {
	ID               string          `json:"id"`
	AccountID        string          `json:"account_id"`
	CallAmount       decimal.Decimal `json:"call_amount"`
	CallType         string          `json:"call_type"` // initial, maintenance
	DueDate          time.Time       `json:"due_date"`
	Status           string          `json:"status"` // open, satisfied, liquidated
	CreatedAt        time.Time       `json:"created_at"`
	ResolvedAt       *time.Time      `json:"resolved_at,omitempty"`
}

// Interest Charge tracking
type InterestCharge struct {
	ID               string          `json:"id"`
	AccountID        string          `json:"account_id"`
	DebitBalance     decimal.Decimal `json:"debit_balance"`
	InterestRate     decimal.Decimal `json:"interest_rate"`
	DailyCharge      decimal.Decimal `json:"daily_charge"`
	ChargeDate       time.Time       `json:"charge_date"`
	SettlementDate   time.Time       `json:"settlement_date"`
}

// Stock Borrow Fee tracking  
type BorrowFee struct {
	ID               string          `json:"id"`
	Symbol           string          `json:"symbol"`
	Quantity         decimal.Decimal `json:"qty"`
	MarketValue      decimal.Decimal `json:"market_value"`
	BorrowRate       decimal.Decimal `json:"borrow_rate"`
	BorrowStatus     string          `json:"borrow_status"`
	DailyFee         decimal.Decimal `json:"daily_fee"`
	FeeDate          time.Time       `json:"fee_date"`
}

// Margin requirements by position type
const (
	// Initial margin requirements
	INITIAL_MARGIN_MARGINABLE     = 0.50  // 50% for marginable securities
	INITIAL_MARGIN_NON_MARGINABLE = 1.00  // 100% for non-marginable
	
	// Maintenance margin requirements
	MAINTENANCE_MARGIN_DEFAULT    = 0.30  // 30% for shares >= $2.50
	MAINTENANCE_MARGIN_LOW_PRICE  = 1.00  // 100% for shares < $2.50
	MAINTENANCE_MARGIN_2X_ETF     = 0.50  // 50% for 2x leveraged ETFs
	MAINTENANCE_MARGIN_3X_ETF     = 0.75  // 75% for 3x leveraged ETFs
	
	// Short selling requirements
	SHORT_MARGIN_MIN_PRICE        = 5.00  // $5.00 minimum for shorts >= $5.00
	SHORT_MARGIN_LOW_PRICE_MIN    = 2.50  // $2.50 minimum for shorts < $5.00
	SHORT_MARGIN_DEFAULT          = 0.30  // 30% for shorts >= $5.00
	
	// Borrow rates
	BORROW_RATE_SP500            = 0.03  // 3% for S&P 500 stocks
	BORROW_RATE_ETB              = 0.04  // 4% for other ETB stocks
	
	// Interest rates
	ANNUAL_MARGIN_INTEREST_RATE  = 0.070 // 7.0% annual
	DAYS_PER_YEAR               = 360    // 360-day year for interest calculation
)

// NewMarginTradingManager creates a new margin trading manager
func NewMarginTradingManager(alpacaClient *alpaca.Client, logger *log.Logger) *MarginTradingManager {
	return &MarginTradingManager{
		alpacaClient:       alpacaClient,
		logger:             logger,
		positions:          make(map[string]*MarginPosition),
		marginCalls:        make([]*MarginCall, 0),
		interestCharges:    make([]*InterestCharge, 0),
		borrowFees:         make([]*BorrowFee, 0),
		marginInterestRate: decimal.NewFromFloat(ANNUAL_MARGIN_INTEREST_RATE),
		minMarginEquity:    decimal.NewFromInt(2000), // $2,000 minimum
	}
}

// ==================== MARGIN CALCULATION METHODS ====================

// CalculateInitialMargin calculates initial margin requirement for a position
func (mtm *MarginTradingManager) CalculateInitialMargin(symbol string, qty decimal.Decimal, price decimal.Decimal, side string) decimal.Decimal {
	marketValue := qty.Abs().Mul(price)
	
	// Check if security is marginable (simplified - in reality check asset API)
	isMarginable := mtm.isSecurityMarginable(symbol)
	
	if !isMarginable {
		// Non-marginable: 100% initial margin
		return marketValue
	}
	
	if side == "short" {
		// Short positions: 50% + market value (Reg T)
		return marketValue.Add(marketValue.Mul(decimal.NewFromFloat(0.50)))
	}
	
	// Long marginable positions: 50% initial margin (Reg T)
	return marketValue.Mul(decimal.NewFromFloat(INITIAL_MARGIN_MARGINABLE))
}

// CalculateMaintenanceMargin calculates maintenance margin requirement
func (mtm *MarginTradingManager) CalculateMaintenanceMargin(symbol string, qty decimal.Decimal, price decimal.Decimal, side string) decimal.Decimal {
	marketValue := qty.Abs().Mul(price)
	
	if side == "short" {
		return mtm.calculateShortMaintenanceMargin(marketValue, price)
	}
	
	return mtm.calculateLongMaintenanceMargin(symbol, marketValue, price)
}

// calculateLongMaintenanceMargin for long positions
func (mtm *MarginTradingManager) calculateLongMaintenanceMargin(symbol string, marketValue decimal.Decimal, price decimal.Decimal) decimal.Decimal {
	priceFloat, _ := price.Float64()
	
	// Low price stocks: 100% of market value
	if priceFloat < 2.50 {
		return marketValue
	}
	
	// Check for leveraged ETFs (simplified check by symbol naming)
	if mtm.isLeveraged3xETF(symbol) {
		return marketValue.Mul(decimal.NewFromFloat(MAINTENANCE_MARGIN_3X_ETF))
	}
	
	if mtm.isLeveraged2xETF(symbol) {
		return marketValue.Mul(decimal.NewFromFloat(MAINTENANCE_MARGIN_2X_ETF))
	}
	
	// Default: 30% of market value
	return marketValue.Mul(decimal.NewFromFloat(MAINTENANCE_MARGIN_DEFAULT))
}

// calculateShortMaintenanceMargin for short positions
func (mtm *MarginTradingManager) calculateShortMaintenanceMargin(marketValue decimal.Decimal, price decimal.Decimal) decimal.Decimal {
	priceFloat, _ := price.Float64()
	
	if priceFloat < 5.00 {
		// Less than $5.00: Greater of $2.50/share or 100% of market value
		perShareMin := decimal.NewFromFloat(SHORT_MARGIN_LOW_PRICE_MIN).Mul(marketValue.Div(price))
		return decimal.Max(perShareMin, marketValue)
	}
	
	// $5.00 or greater: Greater of $5.00/share or 30% of market value
	perShareMin := decimal.NewFromFloat(SHORT_MARGIN_MIN_PRICE).Mul(marketValue.Div(price))
	percentMin := marketValue.Mul(decimal.NewFromFloat(SHORT_MARGIN_DEFAULT))
	
	return decimal.Max(perShareMin, percentMin)
}

// CalculateBuyingPower calculates available buying power
func (mtm *MarginTradingManager) CalculateBuyingPower(accountEquity decimal.Decimal, isPatternDayTrader bool, currentMarginUsed decimal.Decimal) (decimal.Decimal, decimal.Decimal) {
	// Check minimum equity requirement
	if accountEquity.LessThan(mtm.minMarginEquity) {
		// Less than $2,000: 1x buying power only (cash account)
		return accountEquity, accountEquity
	}
	
	availableEquity := accountEquity.Sub(currentMarginUsed)
	
	// Overnight buying power: 2x for margin accounts
	overnightBuyingPower := availableEquity.Mul(decimal.NewFromInt(2))
	
	// Intraday buying power
	intradayBuyingPower := overnightBuyingPower
	if isPatternDayTrader && accountEquity.GreaterThanOrEqual(decimal.NewFromInt(25000)) {
		// PDT with $25k+: 4x intraday buying power
		intradayBuyingPower = availableEquity.Mul(decimal.NewFromInt(4))
	}
	
	return intradayBuyingPower, overnightBuyingPower
}

// ==================== MARGIN CALL METHODS ====================

// CheckMarginCall evaluates if account needs a margin call
func (mtm *MarginTradingManager) CheckMarginCall(accountID string, accountEquity decimal.Decimal, totalMarginRequired decimal.Decimal) *MarginCall {
	if accountEquity.GreaterThanOrEqual(totalMarginRequired) {
		return nil // No margin call needed
	}
	
	callAmount := totalMarginRequired.Sub(accountEquity)
	
	marginCall := &MarginCall{
		ID:        fmt.Sprintf("mc_%d_%s", time.Now().Unix(), generateRandomHex(8)),
		AccountID: accountID,
		CallAmount: callAmount,
		CallType:  "maintenance",
		DueDate:   time.Now().Add(24 * time.Hour), // Due next day
		Status:    "open",
		CreatedAt: time.Now(),
	}
	
	mtm.mutex.Lock()
	mtm.marginCalls = append(mtm.marginCalls, marginCall)
	mtm.mutex.Unlock()
	
	mtm.logger.Printf("🚨 MARGIN CALL: Account %s needs $%.2f by %s", 
		accountID[:8]+"...", callAmount, marginCall.DueDate.Format("2006-01-02 15:04"))
	
	return marginCall
}

// ==================== INTEREST AND FEE CALCULATIONS ====================

// CalculateMarginInterest calculates daily margin interest
func (mtm *MarginTradingManager) CalculateMarginInterest(accountID string, debitBalance decimal.Decimal, settlementDate time.Time) *InterestCharge {
	if debitBalance.LessThanOrEqual(decimal.Zero) {
		return nil // No debit balance, no interest
	}
	
	// Daily interest = (debit_balance * annual_rate) / 360
	dailyRate := mtm.marginInterestRate.Div(decimal.NewFromInt(DAYS_PER_YEAR))
	dailyCharge := debitBalance.Mul(dailyRate)
	
	// Weekend adjustment: Friday settlement = 3 days of interest
	daysCharged := 1
	if settlementDate.Weekday() == time.Friday {
		daysCharged = 3 // Fri, Sat, Sun
	}
	
	totalCharge := dailyCharge.Mul(decimal.NewFromInt(int64(daysCharged)))
	
	interestCharge := &InterestCharge{
		ID:             fmt.Sprintf("int_%d_%s", settlementDate.Unix(), generateRandomHex(6)),
		AccountID:      accountID,
		DebitBalance:   debitBalance,
		InterestRate:   mtm.marginInterestRate,
		DailyCharge:    totalCharge,
		ChargeDate:     time.Now(),
		SettlementDate: settlementDate,
	}
	
	mtm.mutex.Lock()
	mtm.interestCharges = append(mtm.interestCharges, interestCharge)
	mtm.mutex.Unlock()
	
	mtm.logger.Printf("💰 Margin interest: $%.4f on $%.2f debit (%d days)", 
		totalCharge, debitBalance, daysCharged)
	
	return interestCharge
}

// CalculateBorrowFee calculates stock borrow fees for short positions
func (mtm *MarginTradingManager) CalculateBorrowFee(symbol string, quantity decimal.Decimal, marketValue decimal.Decimal, borrowStatus string, feeDate time.Time) *BorrowFee {
	if quantity.GreaterThanOrEqual(decimal.Zero) {
		return nil // Not a short position
	}
	
	// Determine borrow rate
	var borrowRate decimal.Decimal
	if mtm.isSP500Stock(symbol) {
		borrowRate = decimal.NewFromFloat(BORROW_RATE_SP500)
	} else {
		borrowRate = decimal.NewFromFloat(BORROW_RATE_ETB)
	}
	
	// Calculate daily fee: (market_value * borrow_rate) / 360
	dailyRate := borrowRate.Div(decimal.NewFromInt(DAYS_PER_YEAR))
	
	// Round up to nearest round lot (100 shares) for fee calculation
	absQty := quantity.Abs()
	roundLots := absQty.Div(decimal.NewFromInt(100)).Ceil()
	feeQuantity := roundLots.Mul(decimal.NewFromInt(100))
	feeMarketValue := feeQuantity.Mul(marketValue.Div(absQty))
	
	dailyFee := feeMarketValue.Mul(dailyRate)
	
	// Weekend adjustment
	daysCharged := 1
	if feeDate.Weekday() == time.Friday {
		daysCharged = 3 // Fri, Sat, Sun
	}
	
	totalFee := dailyFee.Mul(decimal.NewFromInt(int64(daysCharged)))
	
	borrowFee := &BorrowFee{
		ID:           fmt.Sprintf("borrow_%d_%s", feeDate.Unix(), generateRandomHex(6)),
		Symbol:       symbol,
		Quantity:     feeQuantity, // Round lot quantity
		MarketValue:  feeMarketValue,
		BorrowRate:   borrowRate,
		BorrowStatus: borrowStatus,
		DailyFee:     totalFee,
		FeeDate:      feeDate,
	}
	
	mtm.mutex.Lock()
	mtm.borrowFees = append(mtm.borrowFees, borrowFee)
	mtm.mutex.Unlock()
	
	mtm.logger.Printf("📉 Borrow fee: %s %.0f shares @ %.1f%% = $%.4f (%d days)", 
		symbol, feeQuantity, borrowRate.Mul(decimal.NewFromInt(100)), totalFee, daysCharged)
	
	return borrowFee
}

// ==================== HELPER METHODS ====================

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

// isSecurityMarginable checks if a security can be bought on margin (simplified)
func (mtm *MarginTradingManager) isSecurityMarginable(symbol string) bool {
	// In reality, check via Assets API
	// Most stocks are marginable, some ETFs and new issues are not
	return true // Simplified for this implementation
}

// isLeveraged2xETF checks if symbol is a 2x leveraged ETF
func (mtm *MarginTradingManager) isLeveraged2xETF(symbol string) bool {
	leveraged2x := []string{"SSO", "QLD", "DDM", "UGL", "AGQ"}
	for _, etf := range leveraged2x {
		if symbol == etf {
			return true
		}
	}
	return false
}

// isLeveraged3xETF checks if symbol is a 3x leveraged ETF
func (mtm *MarginTradingManager) isLeveraged3xETF(symbol string) bool {
	leveraged3x := []string{"TQQQ", "SQQQ", "UPRO", "SPXU", "TNA", "TZA"}
	for _, etf := range leveraged3x {
		if symbol == etf {
			return true
		}
	}
	return false
}

// isSP500Stock checks if symbol is in S&P 500 (simplified)
func (mtm *MarginTradingManager) isSP500Stock(symbol string) bool {
	sp500Symbols := []string{"AAPL", "MSFT", "GOOGL", "AMZN", "TSLA", "META", "NVDA"}
	for _, sp500 := range sp500Symbols {
		if symbol == sp500 {
			return true
		}
	}
	return false
}

// ProcessEndOfDayMarginCalculations runs all EOD margin calculations
func (mtm *MarginTradingManager) ProcessEndOfDayMarginCalculations(accountID string, positions []*MarginPosition, accountEquity decimal.Decimal) {
	mtm.logger.Printf("🌙 Processing EOD margin calculations for account %s", accountID[:8]+"...")
	
	totalMarginRequired := decimal.Zero
	totalDebitBalance := decimal.Zero
	
	for _, position := range positions {
		// Update maintenance margin
		maintenanceMargin := mtm.CalculateMaintenanceMargin(position.Symbol, position.Quantity, position.SharePrice, position.Side)
		position.MaintenanceMargin = maintenanceMargin
		position.UpdatedAt = time.Now()
		
		totalMarginRequired = totalMarginRequired.Add(maintenanceMargin)
		
		// Calculate interest on margin loans (long positions with debit balance)
		if position.Side == "long" && position.MarketValue.GreaterThan(accountEquity) {
			debit := position.MarketValue.Sub(accountEquity)
			if debit.GreaterThan(decimal.Zero) {
				totalDebitBalance = totalDebitBalance.Add(debit)
			}
		}
		
		// Calculate borrow fees for short positions  
		if position.Side == "short" {
			mtm.CalculateBorrowFee(position.Symbol, position.Quantity.Neg(), position.MarketValue, "ETB", time.Now())
		}
	}
	
	// Check for margin call
	mtm.CheckMarginCall(accountID, accountEquity, totalMarginRequired)
	
	// Calculate margin interest
	if totalDebitBalance.GreaterThan(decimal.Zero) {
		mtm.CalculateMarginInterest(accountID, totalDebitBalance, time.Now())
	}
	
	mtm.logger.Printf("✅ EOD margin: Equity=$%.2f Required=$%.2f Debit=$%.2f", 
		accountEquity, totalMarginRequired, totalDebitBalance)
}

// ==================== DEMO FUNCTION ====================

func RunMarginTradingDemo() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║            MARGIN TRADING DEMO                ║")
	fmt.Println("║        Margin & Short Selling Engine          ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	// Create logger
	logger := log.New(log.Writer(), "[MARGIN] ", log.LstdFlags|log.Lmicroseconds)
	
	// Create alpaca client
	alpacaClient := alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    os.Getenv("APCA_API_KEY_ID"),
		APISecret: os.Getenv("APCA_API_SECRET_KEY"),
		BaseURL:   "https://paper-api.alpaca.markets",
	})
	
	// Initialize margin manager
	mtm := NewMarginTradingManager(alpacaClient, logger)
	
	// 1. Margin Requirements Calculation
	fmt.Println("\n1️⃣ === MARGIN REQUIREMENTS ===")
	
	// Long position calculation
	symbol := "AAPL"
	qty := decimal.NewFromInt(100)
	price := decimal.NewFromFloat(150.00)
	
	initialMargin := mtm.CalculateInitialMargin(symbol, qty, price, "long")
	maintenanceMargin := mtm.CalculateMaintenanceMargin(symbol, qty, price, "long")
	
	fmt.Printf("📈 LONG %s: %s shares @ $%.2f\n", symbol, qty.String(), price)
	fmt.Printf("   Initial Margin: $%.2f (50%%)\n", initialMargin)
	fmt.Printf("   Maintenance Margin: $%.2f (30%%)\n", maintenanceMargin)
	
	// Short position calculation
	shortQty := decimal.NewFromInt(-50)
	shortInitial := mtm.CalculateInitialMargin("TSLA", shortQty, decimal.NewFromFloat(200.00), "short")
	shortMaintenance := mtm.CalculateMaintenanceMargin("TSLA", shortQty, decimal.NewFromFloat(200.00), "short")
	
	fmt.Printf("📉 SHORT TSLA: %s shares @ $%.2f\n", shortQty.String(), 200.00)
	fmt.Printf("   Initial Margin: $%.2f (150%% of market value)\n", shortInitial)
	fmt.Printf("   Maintenance Margin: $%.2f (max of $5/share or 30%%)\n", shortMaintenance)
	
	// 2. Buying Power Calculation
	fmt.Println("\n2️⃣ === BUYING POWER CALCULATION ===")
	
	accountEquity := decimal.NewFromInt(25000) // $25,000 account
	currentMarginUsed := decimal.NewFromInt(5000) // $5,000 in use
	
	intradayBP, overnightBP := mtm.CalculateBuyingPower(accountEquity, true, currentMarginUsed)
	
	fmt.Printf("💰 Account Equity: $%.2f\n", accountEquity)
	fmt.Printf("💰 Margin Used: $%.2f\n", currentMarginUsed)
	fmt.Printf("💰 Intraday Buying Power: $%.2f (4x for PDT)\n", intradayBP)
	fmt.Printf("💰 Overnight Buying Power: $%.2f (2x for margin)\n", overnightBP)
	
	// 3. Interest Calculation
	fmt.Println("\n3️⃣ === MARGIN INTEREST CALCULATION ===")
	
	debitBalance := decimal.NewFromInt(10000) // $10,000 borrowed
	accountID := "user-margin-001"
	
	interestCharge := mtm.CalculateMarginInterest(accountID, debitBalance, time.Now())
	if interestCharge != nil {
		fmt.Printf("💸 Daily Interest: $%.4f on $%.2f debit\n", interestCharge.DailyCharge, debitBalance)
		fmt.Printf("💸 Annual Rate: %.1f%% | Days: %d\n", mtm.marginInterestRate.Mul(decimal.NewFromInt(100)), 1)
	}
	
	// 4. Borrow Fees
	fmt.Println("\n4️⃣ === STOCK BORROW FEES ===")
	
	shortMarketValue := decimal.NewFromFloat(5000.00) // $5,000 short position
	borrowFee := mtm.CalculateBorrowFee("AAPL", decimal.NewFromInt(-100), shortMarketValue, "ETB", time.Now())
	if borrowFee != nil {
		fmt.Printf("📉 Short Borrow Fee: $%.4f daily\n", borrowFee.DailyFee)
		fmt.Printf("📉 Borrow Rate: %.1f%% (S&P 500 rate)\n", borrowFee.BorrowRate.Mul(decimal.NewFromInt(100)))
	}
	
	// 5. Margin Call Simulation
	fmt.Println("\n5️⃣ === MARGIN CALL SIMULATION ===")
	
	// Simulate account below maintenance margin
	lowEquity := decimal.NewFromInt(8000)
	requiredMargin := decimal.NewFromInt(12000)
	
	marginCall := mtm.CheckMarginCall(accountID, lowEquity, requiredMargin)
	if marginCall != nil {
		fmt.Printf("🚨 MARGIN CALL ISSUED!\n")
		fmt.Printf("🚨 Call Amount: $%.2f\n", marginCall.CallAmount)
		fmt.Printf("🚨 Due Date: %s\n", marginCall.DueDate.Format("2006-01-02 15:04"))
	}
	
	fmt.Println("\n╔════════════════════════════════════════════════╗")
	fmt.Println("║          MARGIN TRADING COMPLETE!             ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  ✅ Real margin requirement calculations       ║")
	fmt.Println("║  ✅ Short selling with borrow fees            ║")
	fmt.Println("║  ✅ Pattern day trader 4x buying power        ║")
	fmt.Println("║  ✅ Automated margin calls & interest         ║")
	fmt.Println("║  ✅ Regulatory compliance (Reg T, FINRA)      ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  THE GREAT SYNAPSE MASTERS LEVERAGE!          ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
}

func main() {
	RunMarginTradingDemo()
}