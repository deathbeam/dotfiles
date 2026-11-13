#!/bin/bash
# Run the overlay against a fake Client.txt and feed it zone changes.
# Usage: ./scripts/test_overlay.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEST_LOG="${POE_LOG_PATH:-/tmp/poe_test_client.txt}"
export POE_LOG_PATH="$TEST_LOG"

: >"$TEST_LOG"

echo "fake log: $TEST_LOG"
echo "starting quickshell (Ctrl+C to stop)..."
quickshell -p "$PROJECT_DIR" -n &
QUICKSHELL_PID=$!
trap 'kill $QUICKSHELL_PID 2>/dev/null || true' EXIT

sleep 2
if ! kill -0 "$QUICKSHELL_PID" 2>/dev/null; then
    echo "quickshell failed to start" >&2
    exit 1
fi

log() {
    echo "2026/01/01 12:00:00 123456789 abc [INFO Client 1234] $1" >>"$TEST_LOG"
    echo "  $1"
}

log ": TestChar (Witch) is now level 2"
for zone in "1_1_1:1" "1_1_town:1" "1_1_2:2" "1_1_4_1:4" "1_2_1:10"; do
    log "Generating level ${zone##*:} area \"${zone%%:*}\" with seed 1"
    sleep 5
done

echo ""
echo "IPC commands (also available from Hyprland):"
echo "  qs ipc -p $PROJECT_DIR call leveling next"
echo "  qs ipc -p $PROJECT_DIR call leveling prev"
echo "  qs ipc -p $PROJECT_DIR call leveling toggle"
echo "  qs ipc -p $PROJECT_DIR call leveling hints"
echo ""
echo "Ctrl+C to stop."
while true; do sleep 1; done
