#!/bin/bash
# Feed a fake Client.txt through the parser and print the state it emits.
# Usage: ./scripts/test_overlay.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TMP_DIR="$(mktemp -d)"

LOG="$TMP_DIR/Client.txt"
: >"$LOG"
echo "fake log: $LOG"

mkfifo "$TMP_DIR/state"
python3 "$SCRIPT_DIR/poe_parser.py" --log "$LOG" --data "$PROJECT_DIR/data" --state "$TMP_DIR/state.json" >"$TMP_DIR/state" &
PARSER_PID=$!
grep --line-buffered -v '^{"tick": true' "$TMP_DIR/state" &
FILTER_PID=$!
trap 'kill "$PARSER_PID" "$FILTER_PID" 2>/dev/null || true; rm -rf "$TMP_DIR"' EXIT

log() {
    echo "2026/01/01 12:00:00 123456789 abc [INFO Client 1234] $1" >>"$LOG"
    echo "  $1"
}

log ": TestChar (Witch) is now level 2"
for zone in "1_1_1:1" "1_1_town:1" "1_1_2:2" "1_1_4_1:4" "1_2_1:10"; do
    log "Generating level ${zone##*:} area \"${zone%%:*}\" with seed 1"
    sleep 2
done

echo ""
echo "In a running overlay: qs ipc -c poe-leveling call leveling next|prev|reset|toggle|hints"
