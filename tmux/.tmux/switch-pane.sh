#!/usr/bin/env bash

panes=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: [#{pane_current_command}] #T")
target=$(
    echo "$panes" \
    | fzf-tmux \
    -p100%,100% \
    --reverse \
    --preview-window=follow:~20 \
    --prompt='Find pane > ' \
    --preview="echo {} | sed 's/: .*$//' | xargs -I{} tmux capture-pane -ep -t {}" \
    | sed 's/: .*//'
)

if [ -z "$target" ]; then
    exit 0
fi

session=$(echo "$target" | cut -d: -f1)
window=$(echo "$target" | cut -d: -f2 | cut -d. -f1)
pane=$(echo "$target" | cut -d: -f2 | cut -d. -f2)
tmux switch-client -t "$session"
tmux select-window -t "$session:$window"
tmux select-pane -t "$session:$window.$pane"
