package journals

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/alpacahq/alpaca-trade-api-go/v3/alpaca"
	"github.com/shopspring/decimal"
)

// Journal types
const (
	JOURNAL_CASH       = "JNLC" // Journal cash between accounts
	JOURNAL_SECURITIES = "JNLS" // Journal securities between accounts
)

// Journal statuses
const (
	STATUS_QUEUED         = "queued"
	STATUS_SENT_CLEARING  = "sent_to_clearing"
	STATUS_EXECUTED       = "executed"
	STATUS_PENDING        = "pending"
	STATUS_REJECTED       = "rejected"
	STATUS_CANCELED       = "canceled"
	STATUS_REFUSED        = "refused"
	STATUS_CORRECT        = "correct"
	STATUS_DELETED        = "deleted"
)

// Journal request structure
type JournalRequest struct {
	// Required fields
	FromAccount string          `json:"from_account"`
	ToAccount   string          `json:"to_account"`
	EntryType   string          `json:"entry_type"` // "JNLC" or "JNLS"
	
	// Cash journal fields (JNLC)
	Amount      decimal.Decimal `json:"amount,omitempty"`
	Currency    string          `json:"currency,omitempty"`
	
	// Securities journal fields (JNLS)
	Symbol      string          `json:"symbol,omitempty"`
	Qty         decimal.Decimal `json:"qty,omitempty"`
	Price       decimal.Decimal `json:"price,omitempty"`
	
	// Optional fields
	Description string          `json:"description,omitempty"`
	
	// Travel Rule compliance (for amounts > $3,000)
	TransmitterName              string `json:"transmitter_name,omitempty"`
	TransmitterAccountNumber     string `json:"transmitter_account_number,omitempty"`
	TransmitterAddress           string `json:"transmitter_address,omitempty"`
	TransmitterFinancialInst     string `json:"transmitter_financial_institution,omitempty"`
}

// Journal response structure
type JournalResponse struct {
	ID           string          `json:"id"`
	FromAccount  string          `json:"from_account"`
	ToAccount    string          `json:"to_account"`
	EntryType    string          `json:"entry_type"`
	Status       string          `json:"status"`
	
	// Cash fields
	Amount       decimal.Decimal `json:"amount,omitempty"`
	NetAmount    decimal.Decimal `json:"net_amount,omitempty"`
	Currency     string          `json:"currency,omitempty"`
	
	// Securities fields
	Symbol       string          `json:"symbol,omitempty"`
	Qty          decimal.Decimal `json:"qty,omitempty"`
	Price        decimal.Decimal `json:"price,omitempty"`
	
	Description  string          `json:"description,omitempty"`
	CreatedAt    time.Time       `json:"created_at"`
	UpdatedAt    time.Time       `json:"updated_at"`
	SettleDate   *time.Time      `json:"settle_date,omitempty"`
	SystemDate   *time.Time      `json:"system_date,omitempty"`
}

// JournalManager handles cash and securities journaling
type JournalManager struct {
	alpacaClient    *alpaca.Client
	firmAccountID   string
	journals        []*JournalResponse
	logger          *log.Logger
	
	// Cash pooling
	sweepAccountID  string
	
	// Tracking
	totalCashMoved  decimal.Decimal
	totalSharesMoved decimal.Decimal
	journalsToday   int
}

// NewJournalManager creates a new journal manager
func NewJournalManager(apiKey, apiSecret, firmAccountID string, isPaper bool) *JournalManager {
	baseURL := "https://api.alpaca.markets"
	if isPaper {
		baseURL = "https://paper-api.alpaca.markets"
	}
	
	alpacaClient := alpaca.NewClient(alpaca.ClientOpts{
		APIKey:    apiKey,
		APISecret: apiSecret,
		BaseURL:   baseURL,
	})
	
	return &JournalManager{
		alpacaClient:     alpacaClient,
		firmAccountID:    firmAccountID,
		journals:         make([]*JournalResponse, 0),
		logger:           log.New(log.Writer(), "[JOURNALS] ", log.LstdFlags|log.Lmicroseconds),
		sweepAccountID:   "sweep-" + firmAccountID,
		totalCashMoved:   decimal.Zero,
		totalSharesMoved: decimal.Zero,
	}
}

// JournalCash moves cash between accounts (JNLC)
func (jm *JournalManager) JournalCash(req JournalRequest) (*JournalResponse, error) {
	req.EntryType = JOURNAL_CASH
	
	jm.logger.Printf("Journaling cash: %s %s from %s to %s", 
		req.Amount.String(), req.Currency, req.FromAccount[:8]+"...", req.ToAccount[:8]+"...")
	
	// Validate cash journal request
	if err := jm.validateCashJournal(req); err != nil {
		return nil, err
	}
	
	// In real implementation, this would call:
	// POST /v1/journals
	
	// Simulate journal creation
	journal := &JournalResponse{
		ID:          generateJournalID(),
		FromAccount: req.FromAccount,
		ToAccount:   req.ToAccount,
		EntryType:   req.EntryType,
		Status:      STATUS_QUEUED,
		Amount:      req.Amount,
		NetAmount:   req.Amount, // In real API, fees might be deducted
		Currency:    req.Currency,
		Description: req.Description,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	
	// Simulate status progression
	go jm.simulateJournalProcessing(journal)
	
	jm.journals = append(jm.journals, journal)
	jm.totalCashMoved = jm.totalCashMoved.Add(req.Amount)
	jm.journalsToday++
	
	jm.logger.Printf("✅ Cash journal created: %s (%s)", journal.ID, journal.Status)
	return journal, nil
}

// JournalSecurities moves securities between accounts (JNLS)
func (jm *JournalManager) JournalSecurities(req JournalRequest) (*JournalResponse, error) {
	req.EntryType = JOURNAL_SECURITIES
	
	jm.logger.Printf("Journaling securities: %s shares of %s from %s to %s",
		req.Qty.String(), req.Symbol, req.FromAccount[:8]+"...", req.ToAccount[:8]+"...")
	
	// Validate securities journal request
	if err := jm.validateSecuritiesJournal(req); err != nil {
		return nil, err
	}
	
	// In real implementation, this would call:
	// POST /v1/journals
	
	// Simulate journal creation
	journal := &JournalResponse{
		ID:          generateJournalID(),
		FromAccount: req.FromAccount,
		ToAccount:   req.ToAccount,
		EntryType:   req.EntryType,
		Status:      STATUS_QUEUED,
		Symbol:      req.Symbol,
		Qty:         req.Qty,
		Price:       req.Price,
		Description: req.Description,
		CreatedAt:   time.Now(),
		UpdatedAt:   time.Now(),
	}
	
	// Simulate status progression
	go jm.simulateJournalProcessing(journal)
	
	jm.journals = append(jm.journals, journal)
	jm.totalSharesMoved = jm.totalSharesMoved.Add(req.Qty)
	jm.journalsToday++
	
	jm.logger.Printf("✅ Securities journal created: %s (%s)", journal.ID, journal.Status)
	return journal, nil
}

// CashPoolingDeposit simulates instant funding via cash pooling
func (jm *JournalManager) CashPoolingDeposit(userAccountID string, amount decimal.Decimal, currency string) (*JournalResponse, error) {
	jm.logger.Printf("💰 Cash pooling deposit: %s %s to user %s", 
		amount.String(), currency, userAccountID[:8]+"...")
	
	// Journal from sweep account to user account
	req := JournalRequest{
		FromAccount:  jm.sweepAccountID,
		ToAccount:    userAccountID,
		Amount:       amount,
		Currency:     currency,
		Description:  "Cash pooling instant deposit",
		TransmitterName: "Firm Sweep Account",
		TransmitterFinancialInst: "Alpaca Securities LLC",
	}
	
	return jm.JournalCash(req)
}

// RewardUser journals free shares to user account
func (jm *JournalManager) RewardUser(userAccountID, symbol string, qty decimal.Decimal, price decimal.Decimal) (*JournalResponse, error) {
	jm.logger.Printf("🎁 Rewarding user %s: %s shares of %s", 
		userAccountID[:8]+"...", qty.String(), symbol)
	
	// Journal from firm account to user account
	req := JournalRequest{
		FromAccount: jm.firmAccountID,
		ToAccount:   userAccountID,
		Symbol:      symbol,
		Qty:         qty,
		Price:       price,
		Description: fmt.Sprintf("Welcome bonus: %s shares of %s", qty.String(), symbol),
	}
	
	return jm.JournalSecurities(req)
}

// GetJournal retrieves a specific journal by ID
func (jm *JournalManager) GetJournal(journalID string) (*JournalResponse, error) {
	// In real implementation: GET /v1/journals/{journal_id}
	
	for _, journal := range jm.journals {
		if journal.ID == journalID {
			return journal, nil
		}
	}
	
	return nil, fmt.Errorf("journal not found: %s", journalID)
}

// GetJournals retrieves journal history
func (jm *JournalManager) GetJournals() ([]*JournalResponse, error) {
	jm.logger.Printf("📋 Retrieving journal history (%d journals)", len(jm.journals))
	
	// In real implementation: GET /v1/journals
	return jm.journals, nil
}

// CancelJournal cancels a pending journal
func (jm *JournalManager) CancelJournal(journalID string) error {
	// In real implementation: DELETE /v1/journals/{journal_id}
	
	journal, err := jm.GetJournal(journalID)
	if err != nil {
		return err
	}
	
	if journal.Status == STATUS_EXECUTED {
		return fmt.Errorf("cannot cancel executed journal: %s", journalID)
	}
	
	journal.Status = STATUS_CANCELED
	journal.UpdatedAt = time.Now()
	
	jm.logger.Printf("❌ Canceled journal: %s", journalID)
	return nil
}

// Validation functions

func (jm *JournalManager) validateCashJournal(req JournalRequest) error {
	if req.FromAccount == "" {
		return fmt.Errorf("from_account is required")
	}
	if req.ToAccount == "" {
		return fmt.Errorf("to_account is required")
	}
	if req.Amount.IsZero() || req.Amount.IsNegative() {
		return fmt.Errorf("amount must be positive")
	}
	if req.Currency == "" {
		req.Currency = "USD" // Default to USD
	}
	
	// Travel Rule compliance for amounts > $3,000
	if req.Amount.GreaterThan(decimal.NewFromInt(3000)) {
		if req.TransmitterName == "" {
			return fmt.Errorf("transmitter_name required for amounts > $3,000 (Travel Rule)")
		}
	}
	
	return nil
}

func (jm *JournalManager) validateSecuritiesJournal(req JournalRequest) error {
	if req.FromAccount == "" {
		return fmt.Errorf("from_account is required")
	}
	if req.ToAccount == "" {
		return fmt.Errorf("to_account is required")
	}
	if req.Symbol == "" {
		return fmt.Errorf("symbol is required")
	}
	if req.Qty.IsZero() || req.Qty.IsNegative() {
		return fmt.Errorf("quantity must be positive")
	}
	
	// Securities journals can only go FROM firm TO customer
	if req.FromAccount != jm.firmAccountID {
		return fmt.Errorf("securities journals can only originate from firm account")
	}
	
	return nil
}

// Helper functions

func (jm *JournalManager) simulateJournalProcessing(journal *JournalResponse) {
	// Simulate journal processing states
	time.Sleep(1 * time.Second)
	journal.Status = STATUS_SENT_CLEARING
	journal.UpdatedAt = time.Now()
	jm.logger.Printf("📤 Journal %s: %s", journal.ID[:8]+"...", journal.Status)
	
	time.Sleep(2 * time.Second)
	journal.Status = STATUS_EXECUTED
	journal.UpdatedAt = time.Now()
	settleDate := time.Now().Add(24 * time.Hour)
	journal.SettleDate = &settleDate
	jm.logger.Printf("✅ Journal %s: %s", journal.ID[:8]+"...", journal.Status)
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

func generateJournalID() string {
	return fmt.Sprintf("jnl_%d_%s", time.Now().Unix(), generateRandomHex(8))
}

// GetJournalStats returns journaling statistics
func (jm *JournalManager) GetJournalStats() map[string]interface{} {
	stats := make(map[string]interface{})
	
	// Count by status
	statusCounts := make(map[string]int)
	for _, journal := range jm.journals {
		statusCounts[journal.Status]++
	}
	
	stats["total_journals"] = len(jm.journals)
	stats["journals_today"] = jm.journalsToday
	stats["total_cash_moved"] = jm.totalCashMoved.String()
	stats["total_shares_moved"] = jm.totalSharesMoved.String()
	stats["status_breakdown"] = statusCounts
	
	return stats
}

// Demo function for Journals API
func RunJournalsDemo() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║              JOURNALS API DEMO                ║")
	fmt.Println("║          Cash & Securities Movement            ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	// Initialize journal manager
	apiKey := os.Getenv("APCA_API_KEY_ID")
	apiSecret := os.Getenv("ALPACA_API_SECRET")
	if apiSecret == "" {
		apiSecret = os.Getenv("APCA_API_SECRET_KEY")
	}
	
	firmAccountID := "firm-abc123"
	journalManager := NewJournalManager(apiKey, apiSecret, firmAccountID, true)
	
	fmt.Printf("\n💼 Journal Manager initialized\n")
	fmt.Printf("🏢 Firm Account: %s\n", firmAccountID)
	fmt.Printf("🏦 Sweep Account: %s\n", journalManager.sweepAccountID)
	
	// Test accounts
	userAccount1 := "user-12345"
	userAccount2 := "user-67890"
	
	// 1. Cash pooling simulation
	fmt.Println("\n1️⃣ === CASH POOLING (INSTANT FUNDING) ===")
	
	// Simulate bulk wire received into firm account, now distribute to users
	deposits := []struct {
		userID   string
		amount   decimal.Decimal
		currency string
	}{
		{userAccount1, decimal.NewFromInt(5000), "USD"},
		{userAccount2, decimal.NewFromInt(10000), "USD"},
	}
	
	for _, deposit := range deposits {
		journal, err := journalManager.CashPoolingDeposit(deposit.userID, deposit.amount, deposit.currency)
		if err != nil {
			fmt.Printf("❌ Cash pooling failed for %s: %v\n", deposit.userID[:8]+"...", err)
		} else {
			fmt.Printf("✅ Instant funding: $%s to %s (ID: %s)\n",
				deposit.amount.String(), deposit.userID[:8]+"...", journal.ID[:12]+"...")
		}
	}
	
	// 2. Manual cash journal
	fmt.Println("\n2️⃣ === MANUAL CASH JOURNAL ===")
	cashReq := JournalRequest{
		FromAccount:  userAccount1,
		ToAccount:    firmAccountID,
		Amount:       decimal.NewFromInt(2000),
		Currency:     "USD",
		Description:  "Withdrawal to firm account",
		TransmitterName: "John Doe",
		TransmitterFinancialInst: "Bank of America",
	}
	
	cashJournal, err := journalManager.JournalCash(cashReq)
	if err != nil {
		fmt.Printf("❌ Cash journal failed: %v\n", err)
	} else {
		fmt.Printf("✅ Cash journal created: $%s from user to firm (ID: %s)\n",
			cashJournal.Amount.String(), cashJournal.ID[:12]+"...")
	}
	
	// 3. Securities rewards
	fmt.Println("\n3️⃣ === SECURITIES REWARDS ===")
	rewards := []struct {
		userID string
		symbol string
		qty    decimal.Decimal
		price  decimal.Decimal
		desc   string
	}{
		{userAccount1, "AAPL", decimal.NewFromFloat(0.5), decimal.NewFromInt(150), "Sign-up bonus"},
		{userAccount2, "MSFT", decimal.NewFromFloat(0.25), decimal.NewFromInt(380), "Referral bonus"},
	}
	
	for _, reward := range rewards {
		_, err := journalManager.RewardUser(reward.userID, reward.symbol, reward.qty, reward.price)
		if err != nil {
			fmt.Printf("❌ Reward failed for %s: %v\n", reward.userID[:8]+"...", err)
		} else {
			fmt.Printf("✅ Reward: %s shares of %s to %s (%s)\n",
				reward.qty.String(), reward.symbol, reward.userID[:8]+"...", reward.desc)
		}
	}
	
	// 4. Manual securities journal
	fmt.Println("\n4️⃣ === MANUAL SECURITIES JOURNAL ===")
	secReq := JournalRequest{
		FromAccount: firmAccountID,
		ToAccount:   userAccount1,
		Symbol:      "GOOGL",
		Qty:         decimal.NewFromFloat(0.1),
		Price:       decimal.NewFromInt(140),
		Description: "Promotional share grant",
	}
	
	secJournal, err := journalManager.JournalSecurities(secReq)
	if err != nil {
		fmt.Printf("❌ Securities journal failed: %v\n", err)
	} else {
		fmt.Printf("✅ Securities journal: %s %s to user (ID: %s)\n",
			secJournal.Qty.String(), secJournal.Symbol, secJournal.ID[:12]+"...")
	}
	
	// 5. Wait for processing and check status
	fmt.Println("\n5️⃣ === JOURNAL PROCESSING STATUS ===")
	fmt.Println("⏳ Waiting for journal processing...")
	time.Sleep(4 * time.Second)
	
	// Check all journal statuses
	journals, err := journalManager.GetJournals()
	if err != nil {
		fmt.Printf("❌ Failed to get journals: %v\n", err)
	} else {
		fmt.Printf("📋 Journal Status Report (%d journals):\n", len(journals))
		for _, journal := range journals {
			typeIcon := "💰"
			if journal.EntryType == JOURNAL_SECURITIES {
				typeIcon = "📈"
			}
			
			statusIcon := "⏳"
			switch journal.Status {
			case STATUS_EXECUTED:
				statusIcon = "✅"
			case STATUS_REJECTED, STATUS_REFUSED:
				statusIcon = "❌"
			case STATUS_CANCELED:
				statusIcon = "🚫"
			}
			
			description := journal.Description
			if len(description) > 30 {
				description = description[:27] + "..."
			}
			
			fmt.Printf("   %s %s %s: %s (%s)\n",
				typeIcon, statusIcon, journal.ID[:12]+"...", description, journal.Status)
		}
	}
	
	// 6. Journal statistics
	fmt.Println("\n6️⃣ === JOURNAL STATISTICS ===")
	stats := journalManager.GetJournalStats()
	fmt.Printf("📊 Total journals: %v\n", stats["total_journals"])
	fmt.Printf("📅 Journals today: %v\n", stats["journals_today"])
	fmt.Printf("💵 Total cash moved: $%v\n", stats["total_cash_moved"])
	fmt.Printf("📈 Total shares moved: %v\n", stats["total_shares_moved"])
	
	if statusBreakdown, ok := stats["status_breakdown"].(map[string]int); ok {
		fmt.Println("📋 Status breakdown:")
		for status, count := range statusBreakdown {
			fmt.Printf("   %s: %d\n", status, count)
		}
	}
	
	fmt.Println("\n╔════════════════════════════════════════════════╗")
	fmt.Println("║            JOURNALS API COMPLETE!             ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  ✅ Cash pooling for instant funding         ║")
	fmt.Println("║  ✅ Securities rewards and bonuses            ║")
	fmt.Println("║  ✅ Travel Rule compliance                    ║")
	fmt.Println("║  ✅ Real-time status tracking                 ║")
	fmt.Println("║  ✅ Firm-to-customer transfers               ║")
	fmt.Println("║  ✅ Automated settlement processing           ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  THE GREAT SYNAPSE MASTERS FUND MOVEMENT!     ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	fmt.Println("\n📝 Journal Types:")
	fmt.Println("   • JNLC: Cash movement between accounts")
	fmt.Println("   • JNLS: Securities movement (firm → customer only)")
	fmt.Println("   • Travel Rule: Compliance for transfers > $3,000")
	fmt.Println("   • Cash Pooling: Instant funding from bulk deposits")
	fmt.Println("   • Status Tracking: Real-time processing updates")
}

func main() {
	RunJournalsDemo()
}