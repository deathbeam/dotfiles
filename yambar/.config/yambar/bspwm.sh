#!/bin/sh

IFS=':'
bspc subscribe report | while read line; do
    monitor=
    layout=
    for tag in $line; do
        name=${tag#?}
        case $tag in
            W[mM]*)
                monitor=${name#?}
                ;;
            [LT]*)
                if [ -n "$name" ]; then
                    layout="$layout${name}"
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

    if [ -z "$layout" ]; then
        layout="--"
    fi
    if [ ${#layout} -lt 2 ]; then
        layout="$layout-"
    fi

    echo "monitor|string|$monitor"
    echo "layout|string|$layout"

    window_id=$(xdotool getactivewindow)
    if [ -n "$window_id" ]; then
        pid=$(xdotool getwindowpid "$window_id")
        process_name=$(ps -p "$pid" -o comm=)
        window_title=$(xdotool getwindowname "$window_id")
        echo "process|string|$process_name"
        echo "title|string|$window_title"
    fi

    echo ""
done