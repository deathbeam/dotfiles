#!/usr/bin/env bash

tmux_sessions=$(tmux list-sessions -F '#S')
project_directories=$(find ~/git -mindepth 1 -maxdepth 1 -type d ; find ~ -mindepth 1 -maxdepth 1 -type d -name '[A-Z]*')

function session_name() {
    basename $1 | tr . _
}

function directory_name() {
    basename $1 | tr _ .
}

function get_marked_sessions() {
    for session in $tmux_sessions; do
        local name="$(directory_name $session)"
        if [[ $project_directories != *$name* ]]; then
            echo -e "\033[0;32m$session\033[0m"
        fi
    done
    for session in $project_directories; do
        local name="$(session_name $session)"
        if [[ $tmux_sessions == *$name* ]]; then
            echo -e "\033[0;34m$session\033[0m"
        else
            echo $session
        fi
    done
}

selected_project=$(get_marked_sessions | sort | fzf-tmux \
    --ansi -p100%,100% -m --reverse \
    --prompt='Open session > ' \
    --bind="ctrl-s:print-query" \
    --header='<ctrl-s> to use query' \
    --preview='ls --group-directories-first --color=always -lahG {}')

if [[ -z $selected_project ]]; then
    exit 0
fi

selected_name=$(session_name "$selected_project")

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected_project
fi

tmux switch-client -t $selected_name
