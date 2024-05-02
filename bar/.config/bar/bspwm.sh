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

num_mon=$(bspc query -M | wc -l)
line=$(bspc wm -g)
wm=
IFS=':'
set -- ${line#?}
while [ $# -gt 0 ] ; do
    item=$1
    name=${item#?}
    case $item in
        [fFoOuU]*)
            case $item in
                f*)
                    # free desktop
                    FG=$COLOR_FREE_FG
                    BG=$COLOR_FREE_BG
                    UL=$BG
                    ;;
                F*)
                    # active free desktop
                    FG=$COLOR_A_FREE_FG
                    BG=$COLOR_A_FREE_BG
                    ;;
                o*)
                    # occupied desktop
                    FG=$COLOR_OCCUPIED_FG
                    BG=$COLOR_OCCUPIED_BG
                    ;;
                O*)
                    # active occupied desktop
                    FG=$COLOR_A_OCCUPIED_FG
                    BG=$COLOR_A_OCCUPIED_BG
                    ;;
                u*)
                    # urgent desktop
                    FG=$COLOR_URGENT_FG
                    BG=$COLOR_URGENT_BG
                    ;;
                U*)
                    # active urgent desktop
                    FG=$COLOR_URGENT_FG
                    BG=$COLOR_URGENT_BG
                    ;;
            esac
            wm="${wm}%{F${FG}}%{B${BG}} ${name} %{B-}%{F-}"
            ;;
    esac
    shift
done
echo "$wm $(xtitle)"
