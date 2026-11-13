#!/usr/bin/env bash
# Import PoE1 leveling data from an Exile-UI checkout into ./data.
# Usage: ./scripts/import_exile_data.sh [path-to-Exile-UI]
set -euo pipefail

EXILE_UI_DIR="${1:-$HOME/git/Exile-UI}"
DATA_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/data"

AREAS="$EXILE_UI_DIR/data/english/[leveltracker] areas.json"
GUIDE="$EXILE_UI_DIR/data/english/[leveltracker] default guide.json"
HINTS="$EXILE_UI_DIR/img/GUI/leveling tracker/hints"
ICONS="$EXILE_UI_DIR/img/GUI/leveling tracker"

for file in "$AREAS" "$GUIDE"; do
    if [ ! -f "$file" ]; then
        echo "missing: $file" >&2
        exit 1
    fi
done

# Replace instead of merge so removed hints and icons do not linger.
rm -rf "${DATA_DIR:?}/hints" "${DATA_DIR:?}/icons"
mkdir -p "$DATA_DIR/hints" "$DATA_DIR/icons"

cp -f "$AREAS" "$DATA_DIR/areas.json"
cp -f "$GUIDE" "$DATA_DIR/guide.json"
cp -f "$HINTS"/*.jpg "$HINTS"/*.png "$DATA_DIR/hints/" 2>/dev/null || true
# inline icons for "(img:<name>)"
cp -f "$ICONS"/*.png "$DATA_DIR/icons/" 2>/dev/null || true
cp -f "$EXILE_UI_DIR/img/GUI/help.png" "$DATA_DIR/icons/help.png" 2>/dev/null || true

echo "areas: $(basename "$AREAS")"
echo "guide: $(basename "$GUIDE")"
echo "hints: $(find "$DATA_DIR/hints" -type f | wc -l) images"
echo "icons: $(find "$DATA_DIR/icons" -type f | wc -l) images"
