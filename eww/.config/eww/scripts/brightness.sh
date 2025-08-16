#!/bin/sh

percent=$(brightnessctl -m | awk -F, '{print $4}' | tr -d '%')
echo "brightness|int|$percent"
echo ""
