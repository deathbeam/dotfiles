#!/bin/sh

if [ ! -d /sys/class/net/eth0 ]; then
    exit 1
fi

ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
