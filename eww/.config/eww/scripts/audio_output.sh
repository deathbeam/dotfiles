#!/bin/bash

# Get audio output status
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '\d+(?=%)' | head -1)
muted=$(pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes' && echo true || echo false)

echo "{\"volume\": $volume, \"muted\": $muted}"
