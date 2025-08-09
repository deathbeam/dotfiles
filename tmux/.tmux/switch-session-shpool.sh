#!/usr/bin/env bash

shpool_sessions=$(shpool list | awk 'NR>1 {print $1}')
project_directories=$(find ~/git -mindepth 1 -maxdepth 1 -type d ; find ~ -mindepth 1 -maxdepth 1 -type d -name '[A-Z]*')

function session_name() {
    basename "$1" | tr . _
}

function directory_name() {
    basename "$1" | tr _ .
}

function get_marked_sessions() {
    # Sessions not matching a directory
    while IFS= read -r session; do
        dir_name="$(directory_name "$session")"
        if ! echo "$project_directories" | grep -q "$dir_name"; then
            echo -e "\033[0;36m$session\033[0m"
        fi
    done <<< "$shpool_sessions"

    # Directories, mark those with active sessions
    while IFS= read -r directory; do
        sess_name="$(session_name "$directory")"
        if echo "$shpool_sessions" | grep -q "^${sess_name}$"; then
            echo -e "\033[0;36m$directory\033[0m"
        else
            echo "$directory"
        fi
    done <<< "$project_directories"
}

selected_project=$(get_marked_sessions | sort | fzf \
    --ansi -m --reverse \
    --prompt='Open session > ' \
    --bind="ctrl-s:print-query" \
    --header='<ctrl-s> to use query' \
    --preview='
        session_name=$(basename {} | tr . _)
        if shpool list | awk "NR>1 {print \$1}" | grep -q "^$session_name$"; then
            echo "Active shpool session: $session_name"
        else
            ls --group-directories-first --color=always -lahG {}
        fi
    ')

if [[ -z $selected_project ]]; then
    exit 0
fi

selected_name=$(session_name "$selected_project")
shpool detach; shpool attach "$selected_name" -c "$SHELL -c 'cd $selected_project; $SHELL'"
