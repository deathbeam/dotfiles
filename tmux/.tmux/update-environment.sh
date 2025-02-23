#!/usr/bin/env bash

eval "$(tmux show-environment -s)"

ENV_VARS=(
    ALACRITTY_SOCKET
    ALACRITTY_LOG
    ALACRITTY_WINDOW_ID
)

for var in "${ENV_VARS[@]}"; do
    if [[ -n "${!var}" ]]; then
        tmux setenv -g "$var" "${!var}"
    fi
done
