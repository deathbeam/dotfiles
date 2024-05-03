#!/bin/sh

scriptpath=$(dirname $(realpath $0))

if [ -n "$(pgrep -x bspwm)" ]; then
    $scriptpath/bspwm.sh
fi

if [ -n "$(pgrep -x Hyprland)" ]; then
    $scriptpath/hyprland.sh
fi
