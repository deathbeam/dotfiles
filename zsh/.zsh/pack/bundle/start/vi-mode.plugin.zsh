# Updates editor information when the keymap changes.
function zle-keymap-select() {
  vi_precmd
  zle reset-prompt
}

zle -N zle-keymap-select
zle -N edit-command-line

bindkey -v

# allow v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

# allow ctrl-p, ctrl-n, j and k for navigate history (standard behaviour)
# bindkey '^P' up-history
# bindkey '^N' down-history
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# allow ctrl-r to perform backward search in history
bindkey '^r' history-incremental-search-backward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# if mode indicator wasn't setup by theme, define default
if [[ "$MODE_INDICATOR" == "" ]]; then
  MODE_INDICATOR="%{$fg_bold[red]%}<%{$fg[red]%}<<%{$reset_color%}"
  MODE_INDICATOR="%{$FX[bold]%}%{$FG[2]%}-- INSERT --%{$FX[reset]%}"
fi

vi_mode_prompt_info() {
  echo "${${KEYMAP/vicmd/$MODE_INDICATOR}/(main|viins)/}"
}

vi_precmd() {
  # define right prompt, if it wasn't defined by a theme
  RPROMPT="`vi_mode_prompt_info`"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd vi_precmd
