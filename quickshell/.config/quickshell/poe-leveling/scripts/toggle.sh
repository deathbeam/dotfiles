#!/bin/bash

if pgrep -f "quickshell -c poe-leveling" > /dev/null; then
    pkill -f "quickshell -c poe-leveling"
    notify-send "PoE Overlay" "Stopped" -t 2000
else
    quickshell -c poe-leveling -n &
    notify-send "PoE Overlay" "Started" -t 2000
fi
