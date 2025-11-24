#!/bin/bash

# Run All Strategy Optimizations Script
# Execute parameter optimization for each strategy using Bayesian optimization
# with walk-forward validation as per Sage's directive

echo "═══════════════════════════════════════════════════════════════"
echo "      THE GREAT SYNAPSE - PARAMETER OPTIMIZATION SUITE"
echo "═══════════════════════════════════════════════════════════════"
echo "Starting comprehensive parameter optimization at $(date)"
echo ""

# Configuration
OUTPUT_DIR="optimized_params_$(date +%Y%m%d_%H%M%S)"
LOG_DIR="optimization_logs"
START_DATE="2022-01-01"
END_DATE="2024-01-01"
MODE="bayesian"  # Efficient for high-dimensional search
OBJECTIVE="sharpe"  # Primary objective function

# Create directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$LOG_DIR"

# Function to run optimization and capture results
run_optimization() {
    local strategy=$1
    local symbol=$2
    local log_file="$LOG_DIR/${strategy}_${symbol}.log"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Optimizing: $strategy for $symbol"
    echo "Start: $(date)"
    
    go run run_optimization.go \
        -strategy "$strategy" \
        -symbol "$symbol" \
        -start "$START_DATE" \
        -end "$END_DATE" \
        -mode "$MODE" \
        -objective "$OBJECTIVE" \
        -walk=true \
        -output "$OUTPUT_DIR" \
        2>&1 | tee "$log_file"
    
    if [ ${PIPESTATUS[0]} -eq 0 ]; then
        echo "✓ Success: $strategy/$symbol completed at $(date)"
    else
        echo "✗ Failed: $strategy/$symbol - check $log_file for details"
    fi
    echo ""
}

# Core Strategies - Test on SPY (broad market)
echo "═══════════════════════════════════════════════════════════════"
echo "PHASE 1: CORE STRATEGIES ON SPY"
echo "═══════════════════════════════════════════════════════════════"
run_optimization "rsi" "SPY"
run_optimization "ma" "SPY"
run_optimization "bb" "SPY"
run_optimization "macd" "SPY"

# High Volatility Test - Test on TSLA
echo "═══════════════════════════════════════════════════════════════"
echo "PHASE 2: HIGH VOLATILITY TEST ON TSLA"
echo "═══════════════════════════════════════════════════════════════"
run_optimization "rsi" "TSLA"
run_optimization "bb" "TSLA"

# Crypto Test - Test on BTCUSD
echo "═══════════════════════════════════════════════════════════════"
echo "PHASE 3: CRYPTO STRATEGIES ON BTCUSD"
echo "═══════════════════════════════════════════════════════════════"
run_optimization "ma" "BTCUSD"
run_optimization "macd" "BTCUSD"

# Tech Stocks Test
echo "═══════════════════════════════════════════════════════════════"
echo "PHASE 4: TECH SECTOR OPTIMIZATION"
echo "═══════════════════════════════════════════════════════════════"
run_optimization "rsi" "AAPL"
run_optimization "bb" "NVDA"

# ML Strategy (if model exists)
echo "═══════════════════════════════════════════════════════════════"
echo "PHASE 5: ML STRATEGY OPTIMIZATION"
echo "═══════════════════════════════════════════════════════════════"
if [ -f "../models/trading_lstm.onnx" ]; then
    run_optimization "ml" "SPY"
else
    echo "⚠ ONNX model not found, skipping ML optimization"
fi

# Generate Summary Report
echo "═══════════════════════════════════════════════════════════════"
echo "GENERATING OPTIMIZATION SUMMARY REPORT"
echo "═══════════════════════════════════════════════════════════════"

cat > "$OUTPUT_DIR/optimization_summary.md" << EOF
# The Great Synapse - Optimization Results
Generated: $(date)

## Configuration
- Date Range: $START_DATE to $END_DATE
- Optimization Mode: $MODE
- Objective Function: $OBJECTIVE
- Walk-Forward Validation: Enabled

## Optimized Parameters

EOF

# Parse JSON results and add to summary
for file in "$OUTPUT_DIR"/*.json; do
    if [ -f "$file" ]; then
        basename=$(basename "$file" .json)
        echo "### $basename" >> "$OUTPUT_DIR/optimization_summary.md"
        echo '```json' >> "$OUTPUT_DIR/optimization_summary.md"
        cat "$file" >> "$OUTPUT_DIR/optimization_summary.md"
        echo '```' >> "$OUTPUT_DIR/optimization_summary.md"
        echo "" >> "$OUTPUT_DIR/optimization_summary.md"
    fi
done

echo "## Logs" >> "$OUTPUT_DIR/optimization_summary.md"
echo "Detailed logs available in: $LOG_DIR/" >> "$OUTPUT_DIR/optimization_summary.md"

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "OPTIMIZATION SUITE COMPLETE"
echo "Results saved to: $OUTPUT_DIR/"
echo "Summary report: $OUTPUT_DIR/optimization_summary.md"
echo "Completed at: $(date)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "1. Review optimized parameters in $OUTPUT_DIR/"
echo "2. Run comprehensive backtests with optimized parameters"
echo "3. Deploy top performers to paper trading"