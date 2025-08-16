#!/bin/bash

# Get battery capacity
if [ -f /sys/class/power_supply/BAT0/capacity ]; then
    capacity=$(cat /sys/class/power_supply/BAT0/capacity)
    echo "{\"capacity\": $capacity}"
else
    echo "{\"capacity\": 100}"
fi
