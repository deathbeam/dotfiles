#!/bin/sh

iwctl station wlan0 show | grep 'Connected network' | awk '{print $3}'
