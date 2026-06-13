#!/usr/bin/env bash

matches=$(
    comm -12 <(pacman -Qq | sort) <(curl -s 'https://md.archlinux.org/s/SxbqukK6IA' | \
        perl -n0777E 'm{<div id="doc".*?>(.*?)</div>}s and say $1' | \
        tr ' ' '\n' | \
        sort));

if [ -z "$matches" ]; then
    echo "CLEAN: No compromised packages found.";
else
    echo -e "WARNING: Found matches:\n$matches";
fi
