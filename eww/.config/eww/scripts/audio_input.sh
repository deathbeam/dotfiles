#!/bin/bash

# Get audio input status
volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -Po '\d+(?=%)' | head -1)
muted=$(pactl get-source-mute @DEFAULT_SOURCE@ | grep -q 'yes' && echo true || echo false)

echo "{\"volume\": $volume, \"muted\": $muted}"
