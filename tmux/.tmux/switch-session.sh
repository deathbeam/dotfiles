#!/usr/bin/env bash

selected_project=$(find ~/git -mindepth 1 -maxdepth 1 -type d | fzf-tmux \
    -p100%,100% -m --reverse \
    --preview-window=follow:~20 \
    --prompt='Open session > ' \
    --preview="tree {}")

if [[ -z $selected_project ]]; then
    exit 0
fi

selected_name=$(basename "$selected_project" | tr . _)

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected_project
fi

tmux switch-client -t $selected_name
