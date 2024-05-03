#!/bin/sh

if ! command -v amixer > /dev/null; then
    exit 1
fi

amixer get Master | awk -F'[]%[]' '/Left:/ {if ($5 == "off") { print 0 } else { print $2 }}'
