#!/bin/sh

if [ ! -d /sys/class/net/wlan0 ]; then
    exit 1
fi

if ! command -v iwctl > /dev/null; then
    exit 1
fi

iwctl station wlan0 show | grep 'Connected network' | awk '{print $3}'
