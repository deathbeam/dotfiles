#!/bin/sh
p="$(dirname $(realpath $0))"

COLOR_BG="#073642"
COLOR_FG="#93A1A1"
COLOR_MONITOR_FG=$COLOR_BG
COLOR_MONITOR_BG="#6C71C4"
COLOR_FOCUSED_MONITOR_FG=$COLOR_BG
COLOR_FOCUSED_MONITOR_BG="#2AA198"
COLOR_FREE_FG=$COLOR_FG
COLOR_FREE_BG="#002B36"
COLOR_A_FREE_FG=$COLOR_FREE_BG
COLOR_A_FREE_BG="#268BD2"
COLOR_OCCUPIED_FG=$COLOR_FG
COLOR_OCCUPIED_BG=$COLOR_BG
COLOR_A_OCCUPIED_FG=$COLOR_A_FREE_FG
COLOR_A_OCCUPIED_BG=$COLOR_A_FREE_BG
COLOR_URGENT_FG=$COLOR_BG
COLOR_URGENT_BG="#DC322F"
COLOR_STATE_FG=$COLOR_FREE_FG
COLOR_STATE_BG=$COLOR_FREE_BG

function bat {
    echo " $($p/bat.sh)%"
}

function cpu {
    echo " $($p/cpu.sh)%"
}

function mem {
    echo " $($p/mem.sh)%"
}

function gpu {
    echo " $($p/gpu.sh)%"
}

function vol {
    echo " $($p/vol.sh)%"
}

function bright {
    echo " $($p/bright.sh)%"
}

function clock {
    echo " $($p/clock.sh)"
}

function title {
    echo "$($p/title.sh)"
}

function wifi {
    echo " $($p/wifi.sh)"
}

function bspwm {
    num_mon=$(bspc query -M | wc -l)
    line=$(bspc wm -g)
    wm=
    IFS=':'
    set -- ${line#?}
    while [ $# -gt 0 ] ; do
        item=$1
        name=${item#?}
        case $item in
            [mM]*)
                case $item in
                    m*)
                        # monitor
                        FG=$COLOR_MONITOR_FG
                        BG=$COLOR_MONITOR_BG
                        ;;
                    M*)
                        # focused monitor
                        FG=$COLOR_FOCUSED_MONITOR_FG
                        BG=$COLOR_FOCUSED_MONITOR_BG
                        ;;
                esac
                wm="${wm}%{F${FG}}%{B${BG}} ${name} %{B-}%{F-}"
                ;;
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
            [LTG]*)
                # layout, state and flags
                if [ -n "$name" ]; then
                    wm="${wm}%{F$COLOR_STATE_FG}%{B$COLOR_STATE_BG} ${name} %{B-}%{F-}"
                fi
                ;;
        esac
        shift
    done
    echo $wm
}

# Create fifo
PANEL_FIFO=/tmp/panel-fifo
[ -e "$PANEL_FIFO" ] && rm "$PANEL_FIFO"
mkfifo "$PANEL_FIFO"
while true; do
    echo "\n" > "$PANEL_FIFO"
    sleep 1
done &

# Subscribe to updates
clock -s > "$PANEL_FIFO" &
pactl subscribe | grep --line-buffered "sink" > "$PANEL_FIFO" &
xtitle -s > "$PANEL_FIFO" &
bspc subscribe report > "$PANEL_FIFO" &

# Get screen width
WIDTH=$(xdpyinfo | awk '/dimensions:/ {print $2}' | cut -d'x' -f1)
while read -r line; do
    echo "%{l}$(bspwm) $(title) %{r}$(wifi) $(cpu) $(mem) $(gpu) $(vol) $(bright) $(bat) $(clock) "
done < "$PANEL_FIFO" | lemonbar -f 'Terminess Nerd Font:size=12' -B $COLOR_BG -F $COLOR_FG -g ${WIDTH}x60+0+0
