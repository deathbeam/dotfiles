#!/bin/sh

# Check for updates in the official repositories
official_updates=$(checkupdates 2>/dev/null | wc -l)

# Check for updates in the AUR
aur_updates=$(yay -Qum 2>/dev/null | wc -l)

# Add the numbers together
total_updates=$((official_updates + aur_updates))

echo "updates|int|$total_updates"

github_notifications=$(gh api notifications --jq 'length')

echo "github|int|$github_notifications"

echo ""
