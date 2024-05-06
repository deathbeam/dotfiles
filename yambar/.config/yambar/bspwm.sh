#!/bin/sh

IFS=':'
while read l; do
    line=$(bspc wm -g)
    monitor=
    monocle=false
    floating=false
    fullscreen=false
    for tag in $line; do
        name=${tag#?}
        case $tag in
            W[mM]*)
                monitor=${name#?}
                ;;
            L*)
                if [ "$name" = "M" ]; then
                    monocle=true
                fi
                ;;
            T*)
                if [ "$name" = "=" ]; then
                    fullscreen=true
                elif [ "$name" = "F" ]; then
                    floating=true
                fi
                ;;
            f*)
                echo "ws${tag:1}_state|string|empty"
                ;;
            F*)
                echo "ws${tag:1}_state|string|focused"
                ;;
            o*)
                echo "ws${tag:1}_state|string|occupied"
                ;;
            O*)
                echo "ws${tag:1}_state|string|focused"
                ;;
            u*)
                echo "ws${tag:1}_state|string|urgent"
                ;;
            U*)
                echo "ws${tag:1}_state|string|urgent"
                ;;
        esac
    done

    echo "monitor|string|$monitor"
    echo "monocle|bool|$monocle"
    echo "floating|bool|$floating"
    echo "fullscreen|bool|$fullscreen"

    window_id=$(xdotool getactivewindow)
    if [ -n "$window_id" ]; then
        pid=$(xdotool getwindowpid "$window_id")
        process_name=$(ps -p "$pid" -o comm=)
        window_title=$(xdotool getwindowname "$window_id")
        echo "process|string|$process_name"
        echo "title|string|$window_title"
    fi

    echo ""
done < <(exec xtitle -sf 'T%s\n' & exec bspc subscribe report)
