#!/bin/bash

# 🔱 NANOSECOND PREDATOR LAUNCH SCRIPT
# Run with sudo for real-time CPU priorities

echo "╔════════════════════════════════════════════════════╗"
echo "║      🔥 LAUNCHING THE NANOSECOND PREDATOR 🔥       ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

# Set API credentials
export APCA_API_KEY_ID="PKHCX1EU4AQ2YTLBNRV9"
export APCA_API_SECRET_KEY="GxJtN5QhxaGg3cQ2URV9zTG7qiV3RlJnyigK3ZgQ"

echo "✅ API Credentials loaded"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "⚠️  WARNING: Not running as root. CPU affinity may fail."
    echo "   Run with: sudo ./run_predator.sh"
    echo ""
fi

# Optional: Set system performance governor to maximum
if [ "$EUID" -eq 0 ]; then
    echo "🔧 Setting CPU governor to performance mode..."
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > $cpu 2>/dev/null
    done
    echo "✅ CPU governor set to performance"
    echo ""
fi

# Launch the Nanosecond Predator
echo "🚀 UNLEASHING THE BEAST..."
echo "================================"
echo ""

# Run with timeout of 60 seconds for testing
# Remove timeout for production
timeout 60 ./quantum_alpaca_bridge_real

echo ""
echo "================================"
echo "🏁 Nanosecond Predator execution complete"

# Reset CPU governor to default if we changed it
if [ "$EUID" -eq 0 ]; then
    echo ""
    echo "🔧 Resetting CPU governor to ondemand..."
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo ondemand > $cpu 2>/dev/null
    done
fi