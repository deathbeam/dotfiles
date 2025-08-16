#!/bin/bash

# Check network status
wifi_interface=$(ip route | grep '^default' | grep -o 'dev [^ ]*' | head -1 | cut -d' ' -f2)
ethernet_interface=$(ip route | grep '^default' | grep -o 'dev [^ ]*' | grep -E 'eth|enp' | head -1 | cut -d' ' -f2)

if [[ $wifi_interface =~ ^wl ]]; then
    ssid=$(iwgetid -r)
    echo "{\"type\": \"wifi\", \"ssid\": \"$ssid\"}"
elif [[ -n $ethernet_interface ]]; then
    ipv4=$(ip route get 8.8.8.8 | grep -oP 'src \K\S+')
    echo "{\"type\": \"ethernet\", \"ipv4\": \"$ipv4\"}"
else
    echo "{\"type\": \"disconnected\"}"
fi
