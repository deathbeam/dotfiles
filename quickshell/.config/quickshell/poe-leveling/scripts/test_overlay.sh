#!/bin/bash
# Test script for PoE leveling overlay
# Starts quickshell and simulates Client.txt zone changes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_LOG="/tmp/poe_test_client.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== PoE Leveling Overlay Test ===${NC}"
echo ""

# Check if quickshell is available
if ! command -v quickshell &> /dev/null; then
    echo -e "${RED}Error: quickshell not found${NC}"
    echo "Please install quickshell first"
    exit 1
fi

# Check if data exists
if [ ! -f "$PROJECT_DIR/data/areas.json" ]; then
    echo -e "${RED}Error: data/areas.json not found${NC}"
    echo "Run ./scripts/import_exile_data.sh first"
    exit 1
fi

# Create test log file
echo -e "${YELLOW}Creating test log file: $TEST_LOG${NC}"
cat > "$TEST_LOG" << 'EOF'
2024/01/01 12:00:00 123456789 [INFO Client 1234] Starting game...
EOF

# Start quickshell in background
echo -e "${YELLOW}Starting quickshell...${NC}"
POE_LOG_PATH="$TEST_LOG" quickshell -c "$PROJECT_DIR" &
QUICKSHELL_PID=$!

# Give quickshell time to start
sleep 2

# Check if quickshell is running
if ! kill -0 $QUICKSHELL_PID 2>/dev/null; then
    echo -e "${RED}Error: quickshell failed to start${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Quickshell started (PID: $QUICKSHELL_PID)${NC}"
echo ""

# Test sequence - zones from PoE1 with different content types
echo -e "${YELLOW}Test Sequence:${NC}"
echo "  1. Twilight Strand - No guide (starting zone)"
echo "  2. The Coast - Guide only"
echo "  3. Ship Graveyard - Guide + text hints"
echo "  4. The Wetlands - Guide + image hints (between 2 pillars)"
echo "  5. The Grand Arena - Guide + image hints (opposite corners)"
echo ""

declare -a ZONES=(
    "1:Twilight Strand"
    "2:The Coast"
    "9:Ship Graveyard"
    "15:The Wetlands"
    "30:The Grand Arena"
)

echo -e "${GREEN}=== Starting Zone Change Simulation ===${NC}"
echo ""
echo "The overlay should appear at the bottom of your screen."
echo "Watch for zone changes and guide updates."
echo ""
echo "You can also test IPC commands in another terminal:"
echo "  echo 'next' | socat - UNIX-CONNECT:/tmp/poe-leveling.sock"
echo "  echo 'prev' | socat - UNIX-CONNECT:/tmp/poe-leveling.sock"
echo "  echo 'toggle' | socat - UNIX-CONNECT:/tmp/poe-leveling.sock"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo -e "${YELLOW}Cleaning up...${NC}"
    kill $QUICKSHELL_PID 2>/dev/null || true
    rm -f "$TEST_LOG"
    rm -f /tmp/poe-leveling.sock
    echo -e "${GREEN}Done${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Simulate zone changes
for zone in "${ZONES[@]}"; do
    level="${zone%%:*}"
    name="${zone#*:}"
    
    echo -e "${GREEN}[$((i++))] Entering zone: ${YELLOW}$name${GREEN} (level $level)${NC}"
    
    # Append zone change to log file (simulating PoE2 writing to Client.txt)
    echo "2024/01/01 12:00:00 123456789 [INFO Client 1234] Generating level $level area \"$name\"" >> "$TEST_LOG"
    
    # Wait before next zone
    echo "   Waiting 8 seconds..."
    sleep 8
    echo ""
done

echo -e "${GREEN}=== Zone sequence complete ===${NC}"
echo ""
echo "Test is still running. Try the IPC commands or press Ctrl+C to exit."
echo ""

# Keep running until user interrupts
while true; do
    sleep 1
done
