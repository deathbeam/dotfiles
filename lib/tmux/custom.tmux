#!/usr/bin/env bash

# Pipe entire current buffer to vim and load copied text to tmux buffer
if [ "$(uname -s)" = Darwin]; then
  tmux bind e capture-pane -S - '\;' split-window -v "tmux show-buffer | sed '/^\s*$/d' | reattach-to-user-namespace view
  - +'$' +'set clipboard=unnamed'; reattach-to-user-namespace pbpaste | tmux load-buffer -"
else
  tmux bind e capture-pane -S - '\;' split-window -v "tmux show-buffer | sed '/^\s*$/d' | view - +'$' +'set clipboard=unnamed'; pbpaste | tmux load-buffer -"
fi
