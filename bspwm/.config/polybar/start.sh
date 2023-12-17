#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 1; done

# Start polybar
for m in $(polybar --list-monitors | cut -d":" -f1); do
  MONITOR=$m polybar --reload main & disown
done
