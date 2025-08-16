#!/bin/sh

scriptpath=$(dirname $(realpath $0))

if [ -n "$(pgrep -x Hyprland)" ]; then
    exec $scriptpath/hyprland.sh
fi

