#!/usr/bin/env bash

command="$1"
key="$2"
wanted_title="Boosteroid"
poe_title="$(xdotool getactivewindow getwindowname)"

if [[ "$wanted_title" != "$poe_title" ]]; then
  xdotool getwindowfocus key --window %@ "$2"
  exit
fi

sleep .5

if [[ $command = "onetwo" ]]; then
  xdotool getwindowfocus type --window %@ --clearmodifiers --delay 50 "12345"
elif [[ $command = "home" ]]; then
  xdotool getwindowfocus key --window %@ Return
  xdotool getwindowfocus type --window %@ --clearmodifiers --delay 50 "/hideout"
  xdotool getwindowfocus key --window %@ Return
fi
