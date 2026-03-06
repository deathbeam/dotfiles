#!/usr/bin/env bash
# Import leveling tracker data from Exile-UI directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 <exile-ui-directory> [poe-version]"
    echo ""
    echo "Arguments:"
    echo "  exile-ui-directory  Path to Exile-UI directory"
    echo "  poe-version         Optional: '1' for PoE1, '2' for PoE2 (default: 1)"
    echo ""
    echo "Example:"
    echo "  $0 /home/user/git/Exile-UI 1     # Import PoE1 data"
    echo "  $0 /home/user/git/Exile-UI 2     # Import PoE2 data"
    exit 1
fi

EXILE_UI_DIR="$1"
POE_VERSION="${2:-1}"  # Default to PoE1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POE_LEVELING_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$POE_LEVELING_DIR/data"
HINTS_DIR="$DATA_DIR/hints"

# Validate Exile-UI directory
if [ ! -d "$EXILE_UI_DIR" ]; then
    print_error "Directory does not exist: $EXILE_UI_DIR"
    exit 1
fi

print_info "Exile-UI directory: $EXILE_UI_DIR"
print_info "PoE version: $POE_VERSION"
print_info "Output directory: $DATA_DIR"
echo ""

# Find the required files based on version
print_info "Searching for PoE${POE_VERSION} leveltracker data files..."

if [ "$POE_VERSION" = "1" ]; then
    AREAS_FILE=$(find "$EXILE_UI_DIR/data" -name "*areas.json" | grep leveltracker | grep -v " 2.json" | head -1)
    GUIDE_FILE=$(find "$EXILE_UI_DIR/data" -name "*default guide.json" | grep leveltracker | grep -v " 2.json" | head -1)
    GEMS_FILE=$(find "$EXILE_UI_DIR/data" -name "*gems.json" | grep leveltracker | grep -v " 2.json" | head -1)
    HINTS_SOURCE_DIR=$(find "$EXILE_UI_DIR/img" -type d -name "hints" | grep "leveling tracker" | grep -v "hints 2" | head -1)
else
    AREAS_FILE=$(find "$EXILE_UI_DIR/data" -name "*areas 2.json" | grep leveltracker | head -1)
    GUIDE_FILE=$(find "$EXILE_UI_DIR/data" -name "*default guide 2.json" | grep leveltracker | head -1)
    GEMS_FILE=$(find "$EXILE_UI_DIR/data" -name "*gems 2.json" | grep leveltracker | head -1)
    HINTS_SOURCE_DIR=$(find "$EXILE_UI_DIR/img" -type d -name "hints 2" | grep "leveling tracker" | head -1)
fi

# Validate files found
if [ -z "$AREAS_FILE" ]; then
    print_error "Could not find areas JSON file in $EXILE_UI_DIR"
    exit 1
fi

if [ -z "$GUIDE_FILE" ]; then
    print_error "Could not find default guide JSON file in $EXILE_UI_DIR"
    exit 1
fi

if [ -z "$GEMS_FILE" ]; then
    print_error "Could not find gems JSON file in $EXILE_UI_DIR"
    exit 1
fi

if [ -z "$HINTS_SOURCE_DIR" ]; then
    print_warn "Could not find hints directory, will skip copying hint images"
else
    print_info "Found hints directory: $HINTS_SOURCE_DIR"
fi

print_info "Found areas file: $AREAS_FILE"
print_info "Found guide file: $GUIDE_FILE"
print_info "Found gems file: $GEMS_FILE"
echo ""

# Create data directories
mkdir -p "$DATA_DIR"
mkdir -p "$HINTS_DIR"

# Just copy the files directly - no conversion needed!
print_info "Copying data files..."
cp "$AREAS_FILE" "$DATA_DIR/areas.json"
cp "$GUIDE_FILE" "$DATA_DIR/guide.json"
cp "$GEMS_FILE" "$DATA_DIR/gems.json"
print_info "  → Copied areas.json, guide.json, and gems.json"

# Copy hint images if available
if [ -n "$HINTS_SOURCE_DIR" ] && [ -d "$HINTS_SOURCE_DIR" ]; then
    print_info "Copying hint images..."
    
    # Copy all images
    cp -v "$HINTS_SOURCE_DIR"/*.{jpg,jpeg,png,JPG,JPEG,PNG} "$HINTS_DIR/" 2>/dev/null || true
    
    # Count copied images
    IMAGE_COUNT=$(find "$HINTS_DIR" -type f | wc -l)
    
    print_info "  → Copied hint images to $HINTS_DIR (total: $IMAGE_COUNT files)"
fi

echo ""
print_info "Import complete!"
print_info "Data directory: $DATA_DIR"
print_info ""
print_info "To use this overlay, run:"
echo "  cd $POE_LEVELING_DIR"
echo "  quickshell -c shell.qml"
