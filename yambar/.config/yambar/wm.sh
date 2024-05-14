#!/bin/sh

scriptpath=$(dirname $(realpath $0))

if [ -n "$(pgrep -x bspwm)" ]; then
    exec $scriptpath/bspwm.sh
elif [ -n "$(pgrep -x Hyprland)" ]; then
    exec $scriptpath/hyprland.sh
fi

