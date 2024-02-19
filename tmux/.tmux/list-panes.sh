#!/usr/bin/env bash

panes=$(tmux list-panes -a -F "#S:#{window_index}.#{pane_index}: [#{pane_current_command}] #T")
target_origin=$(echo "$panes" | fzf-tmux \
    -p100%,100% -m --reverse \
    --preview-window=follow:~20 \
    --prompt='Find pane > ' \
    --preview="echo {} | sed 's/: .*$//' | xargs -I{} tmux capture-pane -ep -t {}")
target=$(echo "$target_origin" | sed 's/: .*//')
echo "$target" | sed -E 's/:.*//g' | xargs -I{} tmux switch-client -t {}
echo "$target" | sed -E 's/\..*//g' | xargs -I{} tmux select-window -t {}
echo "$target" | xargs -I{} tmux select-pane -t {}
