#!/bin/sh

bspc subscribe report | while read line; do
    oldIFS=$IFS
    IFS=':'
    for tag in $line; do
        case $tag in
            f*)
                echo "tag${tag:1}_state|string|empty"
                ;;
            F*)
                echo "tag${tag:1}_state|string|focused"
                ;;
            o*)
                echo "tag${tag:1}_state|string|occupied"
                ;;
            O*)
                echo "tag${tag:1}_state|string|focused"
                ;;
            u*)
                echo "tag${tag:1}_state|string|urgent"
                ;;
            U*)
                echo "tag${tag:1}_state|string|urgent"
                ;;
        esac
    done
    echo ""
    IFS=$oldIFS
done
