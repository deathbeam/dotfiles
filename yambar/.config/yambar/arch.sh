#!/bin/sh
set -e

# Check for updates in the official repositories
official_updates=$(checkupdates 2>/dev/null | wc -l)

# Check for updates in the AUR
aur_updates=$(yay -Qum 2>/dev/null | wc -l)

# Add the numbers together
total_updates=$((official_updates + aur_updates))

echo "updates|int|$total_updates"
echo ""
