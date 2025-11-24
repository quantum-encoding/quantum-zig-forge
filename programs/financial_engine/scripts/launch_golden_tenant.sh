#!/bin/bash

# Operation Midas Touch - Golden Tenant Launch Script
echo "🏛️ OPERATION MIDAS TOUCH: Launching the Golden Tenant..."

# Load environment
export APCA_API_KEY_ID="PKHCX1EU4AQ2YTLBNRV9"
export APCA_API_SECRET_KEY="GxJtN5QhxaGg3cQ2URV9zTG7qiV3RlJnyigK3ZgQ"
export APCA_API_BASE_URL="https://paper-api.alpaca.markets"
export LD_LIBRARY_PATH="/home/rich/productions/zig-financial-engine/go-bridge:$LD_LIBRARY_PATH"

# Build if needed
echo "⚙️ Building the Nanosecond Predator..."
zig build-exe src/multi_tenant_engine.zig -O ReleaseFast

# Launch the Golden Tenant
echo "💰 Activating Market Maker Strategy..."
./multi_tenant_engine

echo "✅ The Empire is operational. The first dollar awaits."