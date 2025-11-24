#!/bin/bash

# The Great Synapse - Full Optimization and Backtesting Pipeline
# Execute parameter optimization followed by comprehensive backtesting

set -e  # Exit on error

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         THE GREAT SYNAPSE - FULL PIPELINE EXECUTION          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Starting at: $(date)"
echo ""

# Check for API credentials
if [ -z "$APCA_API_KEY_ID" ] || [ -z "$APCA_API_SECRET_KEY" ]; then
    echo "❌ ERROR: Alpaca API credentials not found"
    echo "Please set APCA_API_KEY_ID and APCA_API_SECRET_KEY environment variables"
    exit 1
fi

# Create base directories
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BASE_DIR="pipeline_run_$TIMESTAMP"
OPTIMIZE_DIR="$BASE_DIR/optimized_params"
BACKTEST_DIR="$BASE_DIR/backtest_results"
REPORTS_DIR="$BASE_DIR/reports"

mkdir -p "$OPTIMIZE_DIR"
mkdir -p "$BACKTEST_DIR"
mkdir -p "$REPORTS_DIR"

echo "📁 Output directory: $BASE_DIR"
echo ""

# Phase 1: Quick optimization test (reduced scope for testing)
echo "═══════════════════════════════════════════════════════════════"
echo "PHASE 1: PARAMETER OPTIMIZATION (Quick Test)"
echo "═══════════════════════════════════════════════════════════════"
echo ""

# Run limited optimization for testing (full optimization takes hours)
echo "Running optimization for RSI strategy on SPY..."
go run run_optimization.go \
    -strategy "rsi" \
    -symbol "SPY" \
    -start "2023-01-01" \
    -end "2024-01-01" \
    -mode "random" \
    -objective "sharpe" \
    -walk=false \
    -output "$OPTIMIZE_DIR" \
    2>&1 | tee "$REPORTS_DIR/optimization_rsi_spy.log"

echo ""
echo "Running optimization for MA strategy on SPY..."
go run run_optimization.go \
    -strategy "ma" \
    -symbol "SPY" \
    -start "2023-01-01" \
    -end "2024-01-01" \
    -mode "random" \
    -objective "sharpe" \
    -walk=false \
    -output "$OPTIMIZE_DIR" \
    2>&1 | tee "$REPORTS_DIR/optimization_ma_spy.log"

echo ""
echo "✅ Optimization phase complete"
echo ""

# Phase 2: Comprehensive backtesting
echo "═══════════════════════════════════════════════════════════════"
echo "PHASE 2: COMPREHENSIVE BACKTESTING"
echo "═══════════════════════════════════════════════════════════════"
echo ""

echo "Running backtests with optimized parameters..."
go run run_comprehensive_backtests.go \
    -params "$OPTIMIZE_DIR" \
    -output "$BACKTEST_DIR" \
    -verbose=true \
    2>&1 | tee "$REPORTS_DIR/backtests.log"

echo ""
echo "✅ Backtesting phase complete"
echo ""

# Phase 3: Generate final report
echo "═══════════════════════════════════════════════════════════════"
echo "PHASE 3: GENERATING FINAL REPORT"
echo "═══════════════════════════════════════════════════════════════"
echo ""

cat > "$REPORTS_DIR/pipeline_summary.md" << EOF
# The Great Synapse - Pipeline Execution Report
Generated: $(date)

## Pipeline Configuration
- Execution ID: $TIMESTAMP
- Base Directory: $BASE_DIR

## Phase 1: Parameter Optimization
- Strategies Optimized: RSI, MA
- Symbol: SPY
- Date Range: 2023-01-01 to 2024-01-01
- Optimization Mode: Random Search
- Objective Function: Sharpe Ratio

### Optimized Parameters
EOF

# Add optimized parameters to report
for file in "$OPTIMIZE_DIR"/*.json; do
    if [ -f "$file" ]; then
        echo "" >> "$REPORTS_DIR/pipeline_summary.md"
        echo "#### $(basename $file .json)" >> "$REPORTS_DIR/pipeline_summary.md"
        echo '```json' >> "$REPORTS_DIR/pipeline_summary.md"
        jq '.' "$file" >> "$REPORTS_DIR/pipeline_summary.md" 2>/dev/null || cat "$file" >> "$REPORTS_DIR/pipeline_summary.md"
        echo '```' >> "$REPORTS_DIR/pipeline_summary.md"
    fi
done

cat >> "$REPORTS_DIR/pipeline_summary.md" << EOF

## Phase 2: Comprehensive Backtesting
- Backtests Run: $(ls -1 $BACKTEST_DIR/*.json 2>/dev/null | wc -l)
- Reports Generated:
  - Comparison Report: $BACKTEST_DIR/comparison_report.md
  - Performance Summary: $BACKTEST_DIR/performance_summary.md
  - Risk Report: $BACKTEST_DIR/risk_report.md

## Next Steps
1. Review performance metrics in comparison report
2. Select top-performing strategies for paper trading
3. Deploy to paper trading environment
4. Monitor real-time performance

## Logs
- Optimization logs: $REPORTS_DIR/optimization_*.log
- Backtest logs: $REPORTS_DIR/backtests.log
EOF

echo "Final report saved to: $REPORTS_DIR/pipeline_summary.md"
echo ""

# Display summary
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                   PIPELINE EXECUTION COMPLETE                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📊 Results Summary:"
echo "  • Optimized Parameters: $OPTIMIZE_DIR/"
echo "  • Backtest Results: $BACKTEST_DIR/"
echo "  • Reports: $REPORTS_DIR/"
echo ""
echo "📈 Key Reports:"
if [ -f "$BACKTEST_DIR/comparison_report.md" ]; then
    echo "  ✓ Comparison Report generated"
fi
if [ -f "$BACKTEST_DIR/performance_summary.md" ]; then
    echo "  ✓ Performance Summary generated"
fi
if [ -f "$BACKTEST_DIR/risk_report.md" ]; then
    echo "  ✓ Risk Report generated"
fi
echo ""
echo "🚀 Ready for paper trading deployment!"
echo ""
echo "Completed at: $(date)"