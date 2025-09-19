#!/usr/bin/env bash

tmux_sessions=$(tmux list-sessions -F '#S')
project_directories=$(
    find -L ~/git ~/git-work -mindepth 1 -maxdepth 1 -type d
    find -L ~ -mindepth 1 -maxdepth 1 -type d -name '[A-Z]*'
)

function session_name() {
    basename $1 | tr . _
}

function directory_name() {
    basename $1 | tr _ .
}

function get_marked_sessions() {
    current_session=$(tmux display-message -p '#S')

    # First, handle existing tmux sessions that don't have corresponding directories
    while IFS= read -r session; do
        dir_name="$(directory_name "$session")"
        if ! echo "$project_directories" | grep -q "$dir_name"; then
            if [[ "$session" == "$current_session" ]]; then
                echo -e "\033[0;32m$session\033[0m"
            else
                echo -e "\033[0;36m$session\033[0m"
            fi
        fi
    done <<< "$tmux_sessions"

    # Then, handle directories, marking those that have sessions
    while IFS= read -r directory; do
        sess_name="$(session_name "$directory")"
        if echo "$tmux_sessions" | grep -q "^${sess_name}$"; then
            if [[ "$sess_name" == "$current_session" ]]; then
                echo -e "\033[0;32m$directory\033[0m"
            else
                echo -e "\033[0;36m$directory\033[0m"
            fi
        else
            echo "$directory"
        fi
    done <<< "$project_directories"
}

selected_project=$(get_marked_sessions | sort | fzf-tmux \
    --ansi -p100%,100% -m --reverse \
    --prompt='Open session > ' \
    --bind="ctrl-s:print-query" \
    --header='<ctrl-s> to use query' \
    --preview='
        session_name=$(basename {} | tr . _)
        if tmux has-session -t=$session_name 2>/dev/null; then
            # -e captures SGR escape sequences (colors)
            # -J disables word-wrap
            tmux capture-pane -e -J -t $session_name:1.1 -p
        else
            ls --group-directories-first --color=always -lahG {}
        fi
    ')

if [[ -z $selected_project ]]; then
    exit 0
fi

selected_name=$(session_name "$selected_project")

if ! tmux has-session -t=$selected_name 2> /dev/null; then
    tmux new-session -ds $selected_name -c $selected_project
fi

tmux switch-client -t $selected_name
