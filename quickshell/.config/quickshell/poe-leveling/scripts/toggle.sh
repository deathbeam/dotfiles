#!/bin/bash
# Toggle the PoE leveling panel; start the shell if it is not running.
set -u

CONFIG="poe-leveling"

if qs ipc -c "$CONFIG" call leveling toggle >/dev/null 2>&1; then
    exit 0
fi

quickshell -c "$CONFIG" -n -d
