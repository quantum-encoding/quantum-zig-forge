package strategies

import (
	"fmt"
	"log"
	"math"
	"net/http"
	"sync"
	"time"
)

// SentimentFilter provides sentiment analysis overlay for trading strategies
// Can be integrated with any strategy to filter signals based on market sentiment
type SentimentFilter struct {
	// Configuration
	MinPositiveSentiment float64 // Minimum sentiment for buy signals (0-1)
	MaxNegativeSentiment float64 // Maximum negative sentiment for sell signals
	CacheExpiry          time.Duration
	
	// State
	mu              sync.RWMutex
	sentimentCache  map[string]*SentimentData
	logger          *log.Logger
	
	// Metrics
	sentimentHits   int
	sentimentMisses int
	falsePositives  int
}

// SentimentData holds sentiment analysis results
type SentimentData struct {
	Symbol      string
	Score       float64   // -1.0 (bearish) to 1.0 (bullish)
	Confidence  float64   // 0-1 confidence in the score
	Volume      int       // Number of mentions/posts analyzed
	Keywords    []string  // Key terms found
	Timestamp   time.Time
	Source      string    // "twitter", "news", "reddit", etc.
}

// SentimentProvider interface for different sentiment sources
type SentimentProvider interface {
	GetSentiment(symbol string) (*SentimentData, error)
	GetBulkSentiment(symbols []string) (map[string]*SentimentData, error)
}

// NewSentimentFilter creates a new sentiment filter
func NewSentimentFilter() *SentimentFilter {
	return &SentimentFilter{
		MinPositiveSentiment: 0.3,  // Moderate positive sentiment required
		MaxNegativeSentiment: -0.3, // Moderate negative sentiment threshold
		CacheExpiry:          15 * time.Minute,
		sentimentCache:       make(map[string]*SentimentData),
		logger:               log.New(log.Writer(), "[SENTIMENT] ", log.LstdFlags),
	}
}

// GetSentiment retrieves sentiment score for a symbol
func (f *SentimentFilter) GetSentiment(symbol string) *SentimentData {
	f.mu.RLock()
	cached, exists := f.sentimentCache[symbol]
	f.mu.RUnlock()
	
	// Check cache
	if exists && time.Since(cached.Timestamp) < f.CacheExpiry {
		f.sentimentHits++
		return cached
	}
	
	f.sentimentMisses++
	
	// Fetch new sentiment data
	sentiment := f.fetchSentiment(symbol)
	
	// Update cache
	f.mu.Lock()
	f.sentimentCache[symbol] = sentiment
	f.mu.Unlock()
	
	return sentiment
}

// fetchSentiment fetches real-time sentiment data
// In production, this would call external APIs or services
func (f *SentimentFilter) fetchSentiment(symbol string) *SentimentData {
	// For demo purposes, we'll simulate sentiment analysis
	// In production, integrate with:
	// - Twitter/X API for social sentiment
	// - News API for news sentiment
	// - Reddit API for WSB sentiment
	// - StockTwits API
	
	sentiment := &SentimentData{
		Symbol:    symbol,
		Timestamp: time.Now(),
		Source:    "composite",
	}
	
	// Simulate different data sources
	twitterScore := f.getTwitterSentiment(symbol)
	newsScore := f.getNewsSentiment(symbol)
	redditScore := f.getRedditSentiment(symbol)
	
	// Weighted average (Twitter has more real-time signal)
	sentiment.Score = (twitterScore*0.5 + newsScore*0.3 + redditScore*0.2)
	
	// Confidence based on volume of data
	sentiment.Volume = f.getMentionVolume(symbol)
	if sentiment.Volume > 1000 {
		sentiment.Confidence = 0.9
	} else if sentiment.Volume > 100 {
		sentiment.Confidence = 0.7
	} else {
		sentiment.Confidence = 0.5
	}
	
	// Extract keywords
	sentiment.Keywords = f.extractKeywords(symbol)
	
	f.logger.Printf("%s sentiment: Score=%.2f, Confidence=%.2f, Volume=%d",
		symbol, sentiment.Score, sentiment.Confidence, sentiment.Volume)
	
	return sentiment
}

// getTwitterSentiment simulates Twitter/X sentiment analysis
func (f *SentimentFilter) getTwitterSentiment(symbol string) float64 {
	// In production, use Twitter API or X semantic search
	// Example implementation with X tool:
	/*
	query := fmt.Sprintf("$%s stock sentiment", symbol)
	results := xSemanticSearch(query, 100)
	
	positive := 0
	negative := 0
	for _, tweet := range results {
		if containsPositiveWords(tweet) {
			positive++
		} else if containsNegativeWords(tweet) {
			negative++
		}
	}
	
	if positive + negative == 0 {
		return 0
	}
	return float64(positive - negative) / float64(positive + negative)
	*/
	
	// Simulation based on common patterns
	bullishKeywords := []string{"moon", "rocket", "bullish", "buy", "long", "calls", "breakthrough", "beat"}
	bearishKeywords := []string{"crash", "sell", "puts", "bearish", "short", "dump", "overvalued", "bubble"}
	
	// Simulate scoring
	score := 0.0
	
	// Production would analyze these keywords in social media posts
	// For simulation, we use length as a proxy for sentiment analysis
	score += float64(len(bullishKeywords)-len(bearishKeywords)) * 0.001
	
	// Some symbols tend to have more positive sentiment
	techStocks := []string{"AAPL", "GOOGL", "MSFT", "NVDA", "TSLA"}
	for _, tech := range techStocks {
		if symbol == tech {
			score += 0.2
			break
		}
	}
	
	// Add some randomness for realism (would be real data in production)
	hash := 0
	for _, c := range symbol {
		hash += int(c)
	}
	noise := float64((hash%20)-10) / 100.0
	score += noise
	
	// Clamp to [-1, 1]
	if score > 1 {
		score = 1
	} else if score < -1 {
		score = -1
	}
	
	return score
}

// getNewsSentiment simulates news sentiment analysis
func (f *SentimentFilter) getNewsSentiment(symbol string) float64 {
	// In production, use news APIs like:
	// - Alpha Vantage News Sentiment
	// - NewsAPI
	// - Benzinga
	
	// Simulate based on market conditions
	// Would actually parse headlines and articles
	
	return 0.1 // Slightly positive baseline
}

// getRedditSentiment simulates Reddit/WSB sentiment
func (f *SentimentFilter) getRedditSentiment(symbol string) float64 {
	// In production, use Reddit API to analyze:
	// - r/wallstreetbets
	// - r/stocks
	// - r/investing
	
	// WSB tends to be bullish on meme stocks
	memeStocks := []string{"GME", "AMC", "BB", "BBBY"}
	for _, meme := range memeStocks {
		if symbol == meme {
			return 0.7 // Very bullish
		}
	}
	
	return 0.0 // Neutral default
}

// getMentionVolume simulates mention volume tracking
func (f *SentimentFilter) getMentionVolume(symbol string) int {
	// In production, count actual mentions across platforms
	
	// Popular stocks have more mentions
	popularStocks := map[string]int{
		"AAPL": 5000,
		"TSLA": 8000,
		"SPY":  3000,
		"GME":  10000,
		"NVDA": 4000,
	}
	
	if volume, exists := popularStocks[symbol]; exists {
		return volume
	}
	
	return 100 // Default volume
}

// extractKeywords extracts relevant keywords from sentiment data
func (f *SentimentFilter) extractKeywords(symbol string) []string {
	// In production, use NLP to extract actual keywords
	
	keywords := []string{}
	
	// Add some common keywords based on sentiment
	sentiment := f.sentimentCache[symbol]
	if sentiment != nil && sentiment.Score > 0.5 {
		keywords = append(keywords, "bullish", "upgrade", "beat", "strong")
	} else if sentiment != nil && sentiment.Score < -0.5 {
		keywords = append(keywords, "bearish", "downgrade", "miss", "weak")
	}
	
	return keywords
}

// FilterBuySignal filters buy signals based on sentiment
func (f *SentimentFilter) FilterBuySignal(symbol string, originalSignal bool) bool {
	if !originalSignal {
		return false
	}
	
	sentiment := f.GetSentiment(symbol)
	
	// Require positive sentiment for buys
	if sentiment.Score < f.MinPositiveSentiment {
		f.logger.Printf("Buy signal filtered for %s: sentiment %.2f < %.2f",
			symbol, sentiment.Score, f.MinPositiveSentiment)
		return false
	}
	
	// Extra confidence required for low-volume sentiment
	if sentiment.Confidence < 0.5 && sentiment.Score < 0.5 {
		f.logger.Printf("Buy signal filtered for %s: low confidence %.2f",
			symbol, sentiment.Confidence)
		return false
	}
	
	return true
}

// FilterSellSignal filters sell signals based on sentiment
func (f *SentimentFilter) FilterSellSignal(symbol string, originalSignal bool) bool {
	if !originalSignal {
		return false
	}
	
	sentiment := f.GetSentiment(symbol)
	
	// Accelerate sells on very negative sentiment
	if sentiment.Score < f.MaxNegativeSentiment {
		f.logger.Printf("Sell signal reinforced for %s: sentiment %.2f < %.2f",
			symbol, sentiment.Score, f.MaxNegativeSentiment)
		return true
	}
	
	// Don't sell on very positive sentiment (might continue running)
	if sentiment.Score > 0.7 && sentiment.Confidence > 0.7 {
		f.logger.Printf("Sell signal filtered for %s: strong positive sentiment %.2f",
			symbol, sentiment.Score)
		return false
	}
	
	return true
}

// GetMarketSentiment returns overall market sentiment
func (f *SentimentFilter) GetMarketSentiment() *SentimentData {
	// Analyze broad market sentiment using indices
	indices := []string{"SPY", "QQQ", "DIA", "IWM"}
	
	totalScore := 0.0
	totalVolume := 0
	
	for _, index := range indices {
		sentiment := f.GetSentiment(index)
		totalScore += sentiment.Score
		totalVolume += sentiment.Volume
	}
	
	return &SentimentData{
		Symbol:    "MARKET",
		Score:     totalScore / float64(len(indices)),
		Volume:    totalVolume,
		Timestamp: time.Now(),
		Source:    "composite",
	}
}

// SentimentAlert represents a significant sentiment shift
type SentimentAlert struct {
	Symbol    string
	OldScore  float64
	NewScore  float64
	Change    float64
	Timestamp time.Time
	Alert     string
}

// DetectSentimentShift detects significant sentiment changes
func (f *SentimentFilter) DetectSentimentShift(symbol string) *SentimentAlert {
	current := f.GetSentiment(symbol)
	
	f.mu.RLock()
	previous, exists := f.sentimentCache[symbol]
	f.mu.RUnlock()
	
	if !exists || previous == current {
		return nil
	}
	
	change := current.Score - previous.Score
	
	// Alert on significant shifts (>0.3 change)
	if math.Abs(change) > 0.3 {
		alert := &SentimentAlert{
			Symbol:    symbol,
			OldScore:  previous.Score,
			NewScore:  current.Score,
			Change:    change,
			Timestamp: time.Now(),
		}
		
		if change > 0 {
			alert.Alert = "BULLISH_SHIFT"
		} else {
			alert.Alert = "BEARISH_SHIFT"
		}
		
		f.logger.Printf("SENTIMENT ALERT for %s: %.2f -> %.2f (%.2f change)",
			symbol, previous.Score, current.Score, change)
		
		return alert
	}
	
	return nil
}

// GetStatistics returns sentiment filter performance metrics
func (f *SentimentFilter) GetStatistics() map[string]interface{} {
	f.mu.RLock()
	defer f.mu.RUnlock()
	
	hitRate := 0.0
	if (f.sentimentHits + f.sentimentMisses) > 0 {
		hitRate = float64(f.sentimentHits) / float64(f.sentimentHits + f.sentimentMisses) * 100
	}
	
	// Calculate average sentiment across cache
	totalScore := 0.0
	count := 0
	for _, sentiment := range f.sentimentCache {
		totalScore += sentiment.Score
		count++
	}
	
	avgSentiment := 0.0
	if count > 0 {
		avgSentiment = totalScore / float64(count)
	}
	
	return map[string]interface{}{
		"cache_hit_rate":    hitRate,
		"cache_size":        len(f.sentimentCache),
		"sentiment_queries": f.sentimentHits + f.sentimentMisses,
		"avg_sentiment":     avgSentiment,
		"false_positives":   f.falsePositives,
	}
}

// IntegrateWithStrategy shows how to integrate sentiment with existing strategies
func ExampleSentimentIntegration() {
	filter := NewSentimentFilter()
	_ = filter // Use the filter to avoid unused variable warning
	
	// Example: Enhance RSI strategy with sentiment
	// In your RSI strategy's generateSignal method:
	/*
	func (s *RSIMeanReversionStrategy) generateSignalWithSentiment(price float64) string {
		baseSignal := s.generateSignal(price)
		
		if baseSignal == "BUY" {
			// Filter buy signal through sentiment
			if !filter.FilterBuySignal(s.Symbol, true) {
				return "" // Skip buy if sentiment is negative
			}
		} else if baseSignal == "SELL" {
			// Filter sell signal through sentiment
			if !filter.FilterSellSignal(s.Symbol, true) {
				return "" // Skip sell if sentiment is very positive
			}
		}
		
		return baseSignal
	}
	*/
	
	// Example: Sentiment-based position sizing
	/*
	sentiment := filter.GetSentiment(symbol)
	
	// Adjust position size based on sentiment confidence
	if sentiment.Confidence > 0.8 && sentiment.Score > 0.5 {
		positionSize *= 1.5 // Increase size for high-confidence bullish
	} else if sentiment.Confidence < 0.5 {
		positionSize *= 0.5 // Reduce size for low-confidence signals
	}
	*/
	
	fmt.Println("Sentiment filter initialized and ready for integration")
}

// TwitterAPIClient implements real Twitter/X integration (example)
type TwitterAPIClient struct {
	APIKey    string
	APISecret string
	BaseURL   string
}

// GetSentiment implements SentimentProvider for Twitter
func (t *TwitterAPIClient) GetSentiment(symbol string) (*SentimentData, error) {
	// This would make actual API calls to Twitter/X
	// Using their sentiment analysis endpoints or processing raw tweets
	
	query := fmt.Sprintf("$%s OR %s stock", symbol, symbol)
	
	// Make API request (simplified)
	resp, err := http.Get(fmt.Sprintf("%s/search?q=%s", t.BaseURL, query))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()
	
	// Parse response and analyze sentiment
	// This would involve NLP processing of tweets
	
	return &SentimentData{
		Symbol:    symbol,
		Score:     0.0, // Calculate from tweet analysis
		Timestamp: time.Now(),
		Source:    "twitter",
	}, nil
}

// GetBulkSentiment batch fetches sentiment for multiple symbols
func (t *TwitterAPIClient) GetBulkSentiment(symbols []string) (map[string]*SentimentData, error) {
	results := make(map[string]*SentimentData)
	
	for _, symbol := range symbols {
		sentiment, err := t.GetSentiment(symbol)
		if err != nil {
			continue
		}
		results[symbol] = sentiment
	}
	
	return results, nil
}