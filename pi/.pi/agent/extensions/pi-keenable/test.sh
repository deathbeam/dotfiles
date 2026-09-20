#!/usr/bin/env bash
# Self-check: exercises both tools' code paths (key + API calls) without starting pi.
set -euo pipefail
: "${KEENABLE_API_KEY:?KEENABLE_API_KEY not set}"
S=$(curl -sS -X POST https://api.keenable.ai/v1/search -H "X-API-Key: $KEENABLE_API_KEY" -H 'Content-Type: application/json' -d '{"query":"keenable ai","max_results":3}')
echo "$S" | grep -q '"results"' || { echo "FAIL: search: $S"; exit 1; }
F=$(curl -sS "https://api.keenable.ai/v1/fetch?url=https://example.com&maxChars=200&live=true" -H "X-API-Key: $KEENABLE_API_KEY")
echo "$F" | grep -q 'Example Domain' || { echo "FAIL: fetch: $F"; exit 1; }
echo "OK: search + fetch"
