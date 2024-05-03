#!/bin/sh

COLOR_FREE_FG=$COLOR_FG
COLOR_FREE_BG=$COLOR_INACTIVE
COLOR_A_FREE_FG=$COLOR_FREE_BG
COLOR_A_FREE_BG=$COLOR_ACTIVE
COLOR_OCCUPIED_FG=$COLOR_FG
COLOR_OCCUPIED_BG=$COLOR_BG
COLOR_A_OCCUPIED_FG=$COLOR_A_FREE_FG
COLOR_A_OCCUPIED_BG=$COLOR_A_FREE_BG
COLOR_URGENT_FG=$COLOR_BG
COLOR_URGENT_BG=$COLOR_DANGER
COLOR_MONITOR_FG=$COLOR_FREE_FG
COLOR_MONITOR_BG=$COLOR_FREE_BG
COLOR_FOCUSED_MONITOR_FG=$COLOR_FG
COLOR_FOCUSED_MONITOR_BG=$COLOR_BG
COLOR_STATE_FG=$COLOR_FREE_FG
COLOR_STATE_BG=$COLOR_FREE_BG

line=$(bspc wm -g)
workspaces=
monitor=
IFS=':'
for item in $line; do
    name=${item#?}
    bg=''
    fg=''
    case $item in
        W[mM]*)
            # monitor
            monitor=${name#?}
            ;;
        f*)
            # free desktop
            fg=$COLOR_FREE_FG
            bg=$COLOR_FREE_BG
            ;;
        F*)
            # active free desktop
            fg=$COLOR_A_FREE_FG
            bg=$COLOR_A_FREE_BG
            ;;
        o*)
            # occupied desktop
            fg=$COLOR_OCCUPIED_FG
            bg=$COLOR_OCCUPIED_BG
            ;;
        O*)
            # active occupied desktop
            fg=$COLOR_A_OCCUPIED_FG
            bg=$COLOR_A_OCCUPIED_BG
            ;;
        u*)
            # urgent desktop
            fg=$COLOR_URGENT_FG
            bg=$COLOR_URGENT_BG
            ;;
        U*)
            # active urgent desktop
            fg=$COLOR_URGENT_FG
            bg=$COLOR_URGENT_BG
            ;;
        [LT]*)
            # layout, state
            if [ -n "$name" ]; then
                layout="$layout${name}"
            fi
    esac
    if [ -n "$bg" ]; then
        workspaces="${workspaces}%{F${fg}}%{B${bg}} ${name} %{B-}%{F-}"
    fi
done

if [ -z "$layout" ]; then
    layout="--"
fi
if [ ${#layout} -lt 2 ]; then
    layout="$layout-"
fi
layout="%{F${COLOR_FREE_FG}}%{B${COLOR_FREE_BG}} ${layout} %{B-}%{F-}"

window_id=$(xdotool getactivewindow)
if [ -z "$window_id" ]; then
    echo " $monitor $layout$workspaces"
    return
fi

pid=$(xdotool getwindowpid "$window_id")
process_name=$(ps -p "$pid" -o comm=)
window_title=$(xdotool getwindowname "$window_id")
title="$window_title"
echo " $monitor $layout$workspaces%{B${COLOR_ACTIVE}}%{F${COLOR_BG}} $process_name %{B-}%{F-} $window_title"
