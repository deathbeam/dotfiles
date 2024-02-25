#!/usr/bin/env bash

tmux_sessions=$(tmux list-sessions -F '#S')
all_sessions=$(find ~/git -mindepth 1 -maxdepth 1 -type d | sort)

function session_name() {
    basename $1 | tr . _
}

function get_marked_sessions() {
    for session in $all_sessions; do
        local name="$(session_name $session)"
        if [[ $tmux_sessions == *$name* ]]; then
            echo -e "\033[0;34m$session\033[0m"
        fi
    done
    for session in $all_sessions; do
        local name="$(session_name $session)"
        if [[ $tmux_sessions != *$name* ]]; then
            echo $session
        fi
    done
}

selected_project=$(get_marked_sessions | fzf-tmux \
    --ansi -p100%,100% -m --reverse \
    --prompt='Open session > ' \
    --preview='ls --group-directories-first --color=always -lahG {}')

if [[ -z $selected_project ]]; then
    exit 0
fi

# Remove * from selected project
selected_name=$(basename "$selected_project" | tr . _)

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected_project
fi

tmux switch-client -t $selected_name
