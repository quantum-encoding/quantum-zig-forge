package crypto

import (
	"fmt"
	"log"
	"sync"
	"time"

	"github.com/shopspring/decimal"
)

// Fee structure based on Alpaca's volume-tiered system
type FeeTier struct {
	TierNumber         int             `json:"tier"`
	MinVolume          decimal.Decimal `json:"min_volume"`          // 30-day volume in USD
	MaxVolume          decimal.Decimal `json:"max_volume"`          // Max volume for tier (nil for highest)
	MakerFeeRate       decimal.Decimal `json:"maker_fee_rate"`      // Fee rate in basis points
	TakerFeeRate       decimal.Decimal `json:"taker_fee_rate"`      // Fee rate in basis points
	MakerFeePercent    decimal.Decimal `json:"maker_fee_percent"`   // Fee as percentage
	TakerFeePercent    decimal.Decimal `json:"taker_fee_percent"`   // Fee as percentage
}

// Alpaca crypto fee tiers (as of documentation)
var AlpacaCryptoFeeTiers = []FeeTier{
	{
		TierNumber:      1,
		MinVolume:       decimal.NewFromInt(0),
		MaxVolume:       decimal.NewFromInt(100000),
		MakerFeeRate:    decimal.NewFromInt(15),    // 15 bps
		TakerFeeRate:    decimal.NewFromInt(25),    // 25 bps
		MakerFeePercent: decimal.NewFromFloat(0.0015), // 0.15%
		TakerFeePercent: decimal.NewFromFloat(0.0025), // 0.25%
	},
	{
		TierNumber:      2,
		MinVolume:       decimal.NewFromInt(100000),
		MaxVolume:       decimal.NewFromInt(500000),
		MakerFeeRate:    decimal.NewFromInt(12),    // 12 bps
		TakerFeeRate:    decimal.NewFromInt(22),    // 22 bps
		MakerFeePercent: decimal.NewFromFloat(0.0012), // 0.12%
		TakerFeePercent: decimal.NewFromFloat(0.0022), // 0.22%
	},
	{
		TierNumber:      3,
		MinVolume:       decimal.NewFromInt(500000),
		MaxVolume:       decimal.NewFromInt(1000000),
		MakerFeeRate:    decimal.NewFromInt(10),    // 10 bps
		TakerFeeRate:    decimal.NewFromInt(20),    // 20 bps
		MakerFeePercent: decimal.NewFromFloat(0.001), // 0.10%
		TakerFeePercent: decimal.NewFromFloat(0.002), // 0.20%
	},
	{
		TierNumber:      4,
		MinVolume:       decimal.NewFromInt(1000000),
		MaxVolume:       decimal.NewFromInt(10000000),
		MakerFeeRate:    decimal.NewFromInt(8),     // 8 bps
		TakerFeeRate:    decimal.NewFromInt(18),    // 18 bps
		MakerFeePercent: decimal.NewFromFloat(0.0008), // 0.08%
		TakerFeePercent: decimal.NewFromFloat(0.0018), // 0.18%
	},
	{
		TierNumber:      5,
		MinVolume:       decimal.NewFromInt(10000000),
		MaxVolume:       decimal.NewFromInt(25000000),
		MakerFeeRate:    decimal.NewFromInt(5),     // 5 bps
		TakerFeeRate:    decimal.NewFromInt(15),    // 15 bps
		MakerFeePercent: decimal.NewFromFloat(0.0005), // 0.05%
		TakerFeePercent: decimal.NewFromFloat(0.0015), // 0.15%
	},
	{
		TierNumber:      6,
		MinVolume:       decimal.NewFromInt(25000000),
		MaxVolume:       decimal.NewFromInt(50000000),
		MakerFeeRate:    decimal.NewFromInt(2),     // 2 bps
		TakerFeeRate:    decimal.NewFromInt(13),    // 13 bps
		MakerFeePercent: decimal.NewFromFloat(0.0002), // 0.02%
		TakerFeePercent: decimal.NewFromFloat(0.0013), // 0.13%
	},
	{
		TierNumber:      7,
		MinVolume:       decimal.NewFromInt(50000000),
		MaxVolume:       decimal.NewFromInt(100000000),
		MakerFeeRate:    decimal.NewFromInt(2),     // 2 bps
		TakerFeeRate:    decimal.NewFromInt(12),    // 12 bps
		MakerFeePercent: decimal.NewFromFloat(0.0002), // 0.02%
		TakerFeePercent: decimal.NewFromFloat(0.0012), // 0.12%
	},
	{
		TierNumber:      8,
		MinVolume:       decimal.NewFromInt(100000000),
		MaxVolume:       decimal.Zero, // No maximum
		MakerFeeRate:    decimal.NewFromInt(0),     // 0 bps
		TakerFeeRate:    decimal.NewFromInt(10),    // 10 bps
		MakerFeePercent: decimal.NewFromFloat(0.0000), // 0.00%
		TakerFeePercent: decimal.NewFromFloat(0.0010), // 0.10%
	},
}

// Trade record for fee calculation
type CryptoTradeRecord struct {
	ID             string          `json:"id"`
	Symbol         string          `json:"symbol"`
	Side           string          `json:"side"`              // "buy" or "sell"
	OrderType      string          `json:"order_type"`        // "market", "limit", "stop_limit"
	Quantity       decimal.Decimal `json:"quantity"`
	Price          decimal.Decimal `json:"price"`
	NotionalValue  decimal.Decimal `json:"notional_value"`    // quantity × price
	IsMaker        bool            `json:"is_maker"`          // true if maker, false if taker
	Timestamp      time.Time       `json:"timestamp"`
	FeeAsset       string          `json:"fee_asset"`         // Asset in which fee is charged
	FeeAmount      decimal.Decimal `json:"fee_amount"`
	FeeRate        decimal.Decimal `json:"fee_rate"`
	FeeTier        int             `json:"fee_tier"`
}

// Volume tracker for 30-day rolling volume
type VolumeTracker struct {
	trades    []CryptoTradeRecord
	mu        sync.RWMutex
	volume30d decimal.Decimal
	logger    *log.Logger
}

func NewVolumeTracker() *VolumeTracker {
	return &VolumeTracker{
		trades:    make([]CryptoTradeRecord, 0),
		volume30d: decimal.Zero,
		logger:    log.New(log.Writer(), "[VOLUME] ", log.LstdFlags|log.Lmicroseconds),
	}
}

// CryptoFeeCalculator handles volume-tiered fee calculations
type CryptoFeeCalculator struct {
	volumeTracker *VolumeTracker
	feeTiers      []FeeTier
	currentTier   *FeeTier
	logger        *log.Logger
}

func NewCryptoFeeCalculator() *CryptoFeeCalculator {
	calculator := &CryptoFeeCalculator{
		volumeTracker: NewVolumeTracker(),
		feeTiers:      AlpacaCryptoFeeTiers,
		logger:        log.New(log.Writer(), "[FEES] ", log.LstdFlags|log.Lmicroseconds),
	}
	
	// Set initial tier (lowest)
	calculator.currentTier = &calculator.feeTiers[0]
	calculator.logger.Printf("Initialized fee calculator with tier %d", calculator.currentTier.TierNumber)
	
	return calculator
}

// Calculate30DayVolume calculates rolling 30-day volume
func (vt *VolumeTracker) Calculate30DayVolume() decimal.Decimal {
	vt.mu.Lock()
	defer vt.mu.Unlock()
	
	cutoff := time.Now().AddDate(0, 0, -30)
	totalVolume := decimal.Zero
	
	// Filter trades from last 30 days and calculate total volume
	validTrades := make([]CryptoTradeRecord, 0)
	for _, trade := range vt.trades {
		if trade.Timestamp.After(cutoff) {
			validTrades = append(validTrades, trade)
			totalVolume = totalVolume.Add(trade.NotionalValue)
		}
	}
	
	// Update trades list to only include last 30 days
	vt.trades = validTrades
	vt.volume30d = totalVolume
	
	return totalVolume
}

// AddTrade adds a trade to volume tracking
func (vt *VolumeTracker) AddTrade(trade CryptoTradeRecord) {
	vt.mu.Lock()
	defer vt.mu.Unlock()
	
	vt.trades = append(vt.trades, trade)
	vt.logger.Printf("Added trade: %s %s @ $%s (Volume: $%s)",
		trade.Quantity.String(), trade.Symbol, trade.Price.String(), trade.NotionalValue.String())
}

// GetCurrentTier determines fee tier based on 30-day volume
func (fc *CryptoFeeCalculator) GetCurrentTier() *FeeTier {
	volume30d := fc.volumeTracker.Calculate30DayVolume()
	
	// Find appropriate tier
	for i := len(fc.feeTiers) - 1; i >= 0; i-- {
		tier := &fc.feeTiers[i]
		if volume30d.GreaterThanOrEqual(tier.MinVolume) {
			if tier.MaxVolume.IsZero() || volume30d.LessThan(tier.MaxVolume) {
				if fc.currentTier.TierNumber != tier.TierNumber {
					fc.logger.Printf("✅ Fee tier updated: %d → %d (Volume: $%s)",
						fc.currentTier.TierNumber, tier.TierNumber, volume30d.String())
					fc.currentTier = tier
				}
				return tier
			}
		}
	}
	
	// Default to tier 1
	return &fc.feeTiers[0]
}

// CalculateFee calculates fee for a crypto trade
func (fc *CryptoFeeCalculator) CalculateFee(order CryptoOrder, isMaker bool) (*CryptoTradeRecord, error) {
	// Parse order details
	quantity, err := decimal.NewFromString(order.Qty)
	if err != nil {
		if order.Notional != "" {
			// If notional is provided but no quantity, we need price to calculate quantity
			// For demo purposes, use a simulated price
			price := getCryptoPrice(order.Symbol, "close")
			notional, err := decimal.NewFromString(order.Notional)
			if err != nil {
				return nil, fmt.Errorf("invalid notional: %s", order.Notional)
			}
			quantity = notional.Div(decimal.NewFromFloat(price))
		} else {
			return nil, fmt.Errorf("invalid quantity: %s", order.Qty)
		}
	}
	
	// Get or simulate price
	var price decimal.Decimal
	if order.LimitPrice != "" {
		price, err = decimal.NewFromString(order.LimitPrice)
		if err != nil {
			return nil, fmt.Errorf("invalid limit price: %s", order.LimitPrice)
		}
	} else {
		// Use market price simulation
		price = decimal.NewFromFloat(getCryptoPrice(order.Symbol, "close"))
	}
	
	// Calculate notional value
	notionalValue := quantity.Mul(price)
	
	// Get current fee tier
	tier := fc.GetCurrentTier()
	
	// Select appropriate fee rate
	var feeRate decimal.Decimal
	if isMaker {
		feeRate = tier.MakerFeePercent
	} else {
		feeRate = tier.TakerFeePercent
	}
	
	// Calculate fee amount
	feeAmount := notionalValue.Mul(feeRate)
	
	// Determine fee asset (what you receive)
	feeAsset := fc.determineFeeAsset(order.Symbol, order.Side)
	
	// Create trade record
	trade := &CryptoTradeRecord{
		ID:            generateID(),
		Symbol:        order.Symbol,
		Side:          order.Side,
		OrderType:     order.Type,
		Quantity:      quantity,
		Price:         price,
		NotionalValue: notionalValue,
		IsMaker:       isMaker,
		Timestamp:     time.Now(),
		FeeAsset:      feeAsset,
		FeeAmount:     feeAmount,
		FeeRate:       feeRate,
		FeeTier:       tier.TierNumber,
	}
	
	// Add to volume tracking
	fc.volumeTracker.AddTrade(*trade)
	
	fc.logger.Printf("💰 Fee calculated: $%s (%s%%) on $%s trade (Tier %d, %s)",
		feeAmount.StringFixed(6), feeRate.Mul(decimal.NewFromInt(100)).StringFixed(3),
		notionalValue.StringFixed(2), tier.TierNumber, 
		map[bool]string{true: "Maker", false: "Taker"}[isMaker])
	
	return trade, nil
}

// Determine which asset the fee is charged in
func (fc *CryptoFeeCalculator) determineFeeAsset(symbol, side string) string {
	// Fee is charged on what you receive
	// Buy ETH/USD → receive ETH → fee in ETH
	// Sell ETH/USD → receive USD → fee in USD
	// Buy ETH/BTC → receive ETH → fee in ETH  
	// Sell ETH/BTC → receive BTC → fee in BTC
	
	parts := []string{symbol[:3], symbol[4:]} // Split "ETH/USD" into ["ETH", "USD"]
	if len(parts) < 2 {
		return "USD" // Default fallback
	}
	
	if side == "buy" {
		return parts[0] // Base asset (what you're buying)
	} else {
		return parts[1] // Quote asset (what you receive when selling)
	}
}

// GetVolumeStatistics returns volume and tier information
func (fc *CryptoFeeCalculator) GetVolumeStatistics() (decimal.Decimal, *FeeTier, int) {
	volume30d := fc.volumeTracker.Calculate30DayVolume()
	tier := fc.GetCurrentTier()
	tradeCount := len(fc.volumeTracker.trades)
	
	return volume30d, tier, tradeCount
}

// EstimateFeeSavings calculates potential savings from higher tiers
func (fc *CryptoFeeCalculator) EstimateFeeSavings(targetVolume decimal.Decimal, tradeValue decimal.Decimal, isMaker bool) map[int]decimal.Decimal {
	savings := make(map[int]decimal.Decimal)
	
	currentTier := fc.GetCurrentTier()
	var currentFeeRate decimal.Decimal
	if isMaker {
		currentFeeRate = currentTier.MakerFeePercent
	} else {
		currentFeeRate = currentTier.TakerFeePercent
	}
	
	currentFee := tradeValue.Mul(currentFeeRate)
	
	// Calculate fees for each tier
	for _, tier := range fc.feeTiers {
		if tier.TierNumber <= currentTier.TierNumber {
			continue
		}
		
		var tierFeeRate decimal.Decimal
		if isMaker {
			tierFeeRate = tier.MakerFeePercent
		} else {
			tierFeeRate = tier.TakerFeePercent
		}
		
		tierFee := tradeValue.Mul(tierFeeRate)
		savings[tier.TierNumber] = currentFee.Sub(tierFee)
	}
	
	_ = targetVolume // Suppress unused variable warning
	
	return savings
}

// Demo function for crypto fee calculation
func RunCryptoFeesDemo() {
	fmt.Println("╔════════════════════════════════════════════════╗")
	fmt.Println("║         CRYPTO FEES CALCULATION DEMO          ║")
	fmt.Println("║        Volume-Tiered Fee Structure            ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	feeCalculator := NewCryptoFeeCalculator()
	
	// Display fee tier structure
	fmt.Println("\n💳 ALPACA CRYPTO FEE TIERS:")
	fmt.Printf("%-4s %-20s %-12s %-12s\n", "Tier", "Volume Range (USD)", "Maker", "Taker")
	fmt.Println("────────────────────────────────────────────────────")
	
	for _, tier := range AlpacaCryptoFeeTiers {
		var volumeRange string
		if tier.MaxVolume.IsZero() {
			volumeRange = fmt.Sprintf("$%s+", tier.MinVolume.StringFixed(0))
		} else {
			volumeRange = fmt.Sprintf("$%s - $%s", tier.MinVolume.StringFixed(0), tier.MaxVolume.StringFixed(0))
		}
		
		fmt.Printf("%-4d %-20s %-12s %-12s\n",
			tier.TierNumber,
			volumeRange,
			tier.MakerFeeRate.String()+" bps",
			tier.TakerFeeRate.String()+" bps")
	}
	
	// Simulate trading progression through tiers
	fmt.Println("\n🚀 SIMULATING TRADING PROGRESSION:")
	
	testOrders := []struct {
		order    CryptoOrder
		isMaker  bool
		description string
	}{
		{
			order: CryptoOrder{Symbol: "BTC/USD", Side: "buy", Type: "limit", Qty: "0.1", LimitPrice: "65000"},
			isMaker: true,
			description: "Buy 0.1 BTC @ $65,000 (Limit Order - Maker)",
		},
		{
			order: CryptoOrder{Symbol: "ETH/USD", Side: "sell", Type: "market", Qty: "5"},
			isMaker: false,
			description: "Sell 5 ETH @ Market (Market Order - Taker)",
		},
		{
			order: CryptoOrder{Symbol: "BTC/USD", Side: "buy", Type: "limit", Qty: "1.5", LimitPrice: "66000"},
			isMaker: true,
			description: "Buy 1.5 BTC @ $66,000 (Limit Order - Maker)",
		},
		{
			order: CryptoOrder{Symbol: "ETH/USD", Side: "buy", Type: "market", Notional: "50000"},
			isMaker: false,
			description: "Buy $50,000 worth of ETH (Market Order - Taker)",
		},
	}
	
	var totalFees decimal.Decimal
	
	for i, test := range testOrders {
		fmt.Printf("\n%d️⃣ %s\n", i+1, test.description)
		
		trade, err := feeCalculator.CalculateFee(test.order, test.isMaker)
		if err != nil {
			fmt.Printf("   ❌ Error: %v\n", err)
			continue
		}
		
		totalFees = totalFees.Add(trade.FeeAmount)
		
		fmt.Printf("   💰 Trade Value: $%s\n", trade.NotionalValue.StringFixed(2))
		fmt.Printf("   📊 Fee Rate: %s%% (Tier %d %s)\n",
			trade.FeeRate.Mul(decimal.NewFromInt(100)).StringFixed(3),
			trade.FeeTier,
			map[bool]string{true: "Maker", false: "Taker"}[trade.IsMaker])
		fmt.Printf("   💸 Fee Amount: %s %s ($%.6f)\n",
			trade.FeeAmount.StringFixed(8), trade.FeeAsset, trade.FeeAmount)
		
		// Show volume progression
		volume30d, tier, tradeCount := feeCalculator.GetVolumeStatistics()
		fmt.Printf("   📈 30-day Volume: $%s (Tier %d, %d trades)\n",
			volume30d.StringFixed(2), tier.TierNumber, tradeCount)
	}
	
	// Final statistics
	fmt.Println("\n📊 FINAL TRADING STATISTICS:")
	volume30d, tier, tradeCount := feeCalculator.GetVolumeStatistics()
	fmt.Printf("   30-day Volume: $%s\n", volume30d.StringFixed(2))
	fmt.Printf("   Current Tier: %d\n", tier.TierNumber)
	fmt.Printf("   Total Trades: %d\n", tradeCount)
	fmt.Printf("   Total Fees Paid: $%s\n", totalFees.StringFixed(6))
	
	// Fee savings analysis
	fmt.Println("\n💡 FEE SAVINGS ANALYSIS:")
	fmt.Printf("For a $10,000 trade (Taker):\n")
	
	tradeValue := decimal.NewFromInt(10000)
	_ = feeCalculator.EstimateFeeSavings(volume30d, tradeValue, false) // Suppress unused variable
	
	currentTier := feeCalculator.GetCurrentTier()
	currentFee := tradeValue.Mul(currentTier.TakerFeePercent)
	fmt.Printf("   Current Fee (Tier %d): $%s\n", currentTier.TierNumber, currentFee.StringFixed(2))
	
	for _, nextTier := range AlpacaCryptoFeeTiers {
		if nextTier.TierNumber > currentTier.TierNumber {
			nextFee := tradeValue.Mul(nextTier.TakerFeePercent)
			saving := currentFee.Sub(nextFee)
			additionalVolume := nextTier.MinVolume.Sub(volume30d)
			
			fmt.Printf("   Tier %d Fee: $%s (Save $%s, need $%s more volume)\n",
				nextTier.TierNumber, nextFee.StringFixed(2),
				saving.StringFixed(2), additionalVolume.StringFixed(0))
		}
	}
	
	fmt.Println("\n╔════════════════════════════════════════════════╗")
	fmt.Println("║        CRYPTO FEES DEMO COMPLETE!             ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  ✅ Volume-tiered fee calculation             ║")
	fmt.Println("║  ✅ Maker/taker fee differentiation           ║")
	fmt.Println("║  ✅ 30-day rolling volume tracking            ║")
	fmt.Println("║  ✅ Automatic tier progression                ║")
	fmt.Println("║  ✅ Fee savings optimization                  ║")
	fmt.Println("║  ✅ Asset-specific fee charging               ║")
	fmt.Println("║                                                ║")
	fmt.Println("║  THE GREAT SYNAPSE OPTIMIZES EVERY BASIS POINT! ║")
	fmt.Println("╚════════════════════════════════════════════════╝")
	
	fmt.Println("\n📝 Fee Features:")
	fmt.Println("   • 8-tier volume structure: 0-25 bps fees")
	fmt.Println("   • Maker/taker distinction: Lower fees for liquidity providers")
	fmt.Println("   • Rolling 30-day calculation: Dynamic tier adjustments")
	fmt.Println("   • Asset-specific charging: Fees in received currency")
	fmt.Println("   • Institutional rates: 0% maker fees for $100M+ volume")
	fmt.Println("   • Real-time optimization: Maximize trading efficiency")
}