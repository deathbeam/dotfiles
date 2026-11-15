# Hyprland Keybindings
| Key | Action |
|-----|--------|
| `SUPER+Return` | terminal |
| `SUPER+Tab` | switch |
| `SUPER+space` | run |
| `SUPER+p` | passwords |
| `SUPER+x` | execute |
| `SUPER+c` | copy |
| `SUPER+g` | games |
| `SUPER+i` | install |
| `SUPER+n` | notifications |
| `SUPER+u` | urls |
| `SUPER+e` | lock screen |
| `SUPER+v` | flux |
| `SUPER+slash` | cheatsheet |
| `SUPER+b` | btop |
| `SUPER+d` | discord |
| `SUPER+y` | youtube |
| `SUPER+o` | kubernetes |
| `SUPER+SHIFT+o` | docker |
| `SUPER+a` | wifi |
| `SUPER+z` | poe leveling toggle |
| `SUPER+Left` | poe previous |
| `SUPER+Right` | poe next |
| `SUPER+SHIFT+Left` | poe reset |
| `SUPER+SHIFT+z` | poe hints |
| `switch:Lid Switch` | lock screen |
| `Print` | screenshot |
| `SUPER+Print` | screen recorder |
| `XF86AudioRaiseVolume` | volume up |
| `XF86AudioLowerVolume` | volume down |
| `XF86AudioMute` | mute |
| `XF86AudioMicMute` | mic mute |
| `XF86MonBrightnessUp` | brightness up |
| `XF86MonBrightnessDown` | brightness down |
| `XF86KbdBrightnessUp` | keyboard brightness up |
| `XF86KbdBrightnessDown` | keyboard brightness down |
| `XF86Launch1` | rog control center |
| `XF86Launch3` | led mode |
| `XF86Launch4` | profile |
| `SUPER+SHIFT+escape` | exit |
| `SUPER+escape` | reload config |
| `SUPER+W` | close window |
| `SUPER+S` | toggle float |
| `SUPER+M` | maximize |
| `SUPER+F` | fullscreen |
| `SUPER+T` | toggle group |
| `SUPER+H` | focus left |
| `SUPER+L` | focus right |
| `SUPER+K` | focus up |
| `SUPER+J` | focus down |
| `SUPER+SHIFT+H` | move left |
| `SUPER+SHIFT+L` | move right |
| `SUPER+SHIFT+K` | move up |
| `SUPER+SHIFT+J` | move down |
| `SUPER+R` | enter resize mode |
| `resize: H` | resize left |
| `resize: L` | resize right |
| `resize: K` | resize up |
| `resize: J` | resize down |
| `resize: SHIFT+H` | move left |
| `resize: SHIFT+L` | move right |
| `resize: SHIFT+K` | move up |
| `resize: SHIFT+J` | move down |
| `resize: escape` | exit resize mode |
| `resize: Return` | exit resize mode |
| `SUPER+1` | workspace 1 |
| `SUPER+2` | workspace 2 |
| `SUPER+3` | workspace 3 |
| `SUPER+4` | workspace 4 |
| `SUPER+5` | workspace 5 |
| `SUPER+6` | workspace 6 |
| `SUPER+7` | workspace 7 |
| `SUPER+8` | workspace 8 |
| `SUPER+9` | workspace 9 |
| `SUPER+grave` | toggle special workspace |
| `SUPER+SHIFT+1` | move to workspace 1 |
| `SUPER+SHIFT+2` | move to workspace 2 |
| `SUPER+SHIFT+3` | move to workspace 3 |
| `SUPER+SHIFT+4` | move to workspace 4 |
| `SUPER+SHIFT+5` | move to workspace 5 |
| `SUPER+SHIFT+6` | move to workspace 6 |
| `SUPER+SHIFT+7` | move to workspace 7 |
| `SUPER+SHIFT+8` | move to workspace 8 |
| `SUPER+SHIFT+9` | move to workspace 9 |
| `SUPER+SHIFT+grave` | move to special workspace |

# Tmux Keybindings
| Mode | Key | Action |
|------|-----|--------|
| | `C-space` | send-prefix
| | `c` | new-window `-c #{pane_current_path}`
| | `C` | new-session `-c #{pane_current_path}`
| | `'"'` | split-window `-h -c #{pane_current_path}`
| | `%` | split-window `-v -c #{pane_current_path}`
| | `&` | kill-window
| | `x` | kill-pane
| | `X` | kill-session
| `copy-mode-vi` | `v` | send-keys -X begin-selection |
| `copy-mode-vi` | `y` | send-keys -X copy-selection-and-cancel |
| `copy-mode-vi` | `Escape` | send-keys -X cancel |
| | `M-Enter` | if-shell `[ $(($(tmux display -p 8*#{pane_width}-20*#{pane_height}))) -lt 0 ] splitw -v -c #{pane_current_path} splitw -h -c #{pane_current_path}`
| | `M-v` | capture-pane `-S - \; save-buffer /tmp/tmux_buffer.txt \; split-window nvim + normal G\$?. /tmp/tmux_buffer.txt && rm /tmp/tmux_buffer.txt`
| | `s` | run-shell `-b $HOME/.tmux/switch-session.sh`

# Neovim Keybindings
| Mode | Key | Description |
|------|-----|-------------|
| n | `<Space>mD` | Bookmarks Delete All |
| n | `<Space>md` | Bookmarks Delete Buffer |
| n | `<Space>mq` | Bookmarks Quickfix |
| n | `<Space>mm` | Bookmarks Select |
| n | `<Space>dp` | Breakpoints |
| n | `<Space>db` | Debug Breakpoint |
| n | `<Space>dB` | Debug Conditional Breakpoint |
| n | `<Space>dc` | Debug Console |
| n | `<Space>dd` | Debug Continue [R] |
| n | `<Space>dx` | Debug Exit |
| nv | `<Space>de` | Debug Expression |
| n | `<Space>df` | Debug Frames |
| n | `<Space>dL` | Debug Log Point |
| n | `<Space>dP` | Debug Prints |
| n | `<Space>d<Space>` | Debug REPL |
| n | `<Space>dr` | Debug Restart |
| n | `<Space>ds` | Debug Scopes |
| n | `<Space>dk` | Debug Step Back (up) [R] |
| n | `<Space>dl` | Debug Step Into (right) [R] |
| n | `<Space>dh` | Debug Step Out (left) [R] |
| n | `<Space>dj` | Debug Step Over (down) [R] |
| n | `<Space>dt` | Debug Threads |
| n | `<Space>fa` | Find Actions |
| n | `<Space>fD` | Find All Diagnostics |
| n | `<Space>fC` | Find All Git Commits |
| n | `<Space>fS` | Find All Symbols |
| nv | `<Space>fc` | Find Buffer Git Commits |
| v | `<Space>fc` | Find Buffer Git Commits No mapping found |
| n | `<Space>fb` | Find Buffers |
| n | `<Space>fd` | Find Diagnostics |
| n | `<Space>ff` | Find Files |
| n | `<Space>fF` | Find Git Files |
| n | `<Space>fG` | Find Git Grep |
| n | `<Space>fg` | Find Grep |
| n | `<Space>f?` | Find Help |
| n | `<Space>fh` | Find History |
| n | `<Space>fj` | Find Jumps |
| n | `<Space>fk` | Find Keymaps |
| n | `<Space>fm` | Find Marks |
| n | `<Space>fq` | Find Quickfix |
| n | `<Space><Space>` | Find Resume |
| n | `<Space>fs` | Find Symbols |
| n | `<Space>he` | HTTP Environment |
| n | `<Space>hh` | HTTP Run |
| n | `<Space>hH` | HTTP Run All |
| n | `<Space>ho` | HTTP Toggle |
| n | `<Space>u` | Open undotree |
| n | `<Space>q` | Toggle quickfix |
| n | `<Space>wd` | Wiki Diary List |
| n | `<Space>ww` | Wiki List |
| n | `<Space>wn` | Wiki New |
| n | `<Space>wt` | Wiki Today |
| n | `<Space>z` | Zoom |

# Zsh Aliases
| Type | Name | Value |
|------|------|-------|
| alias | `chmod` | `chmod --preserve-root -v`
| alias | `chown` | `chown --preserve-root -v`
| alias | `df` | `df -h`
| alias | `du` | `du -h`
| alias | `fsh-alias` | `fast-theme`
| alias | `g` | `git`
| alias | `g..` | `cd $(git-root \|\| print .)`
| alias | `gCE` | `git-edit-unmerged`
| alias | `gCO` | `git -C $(git-root) checkout --ours -- ${(f)$(gCl 2>/dev/null)}`
| alias | `gCT` | `git -C $(git-root) checkout --theirs -- ${(f)$(gCl 2>/dev/null)}`
| alias | `gCa` | `git -C $(git-root) add ${(f)$(gCl 2>/dev/null)}`
| alias | `gCe` | `git -C $(git-root) mergetool ${(f)$(gCl 2>/dev/null)}`
| alias | `gCl` | `git --no-pager diff --name-only --diff-filter=U`
| alias | `gCo` | `git checkout --ours --`
| alias | `gCt` | `git checkout --theirs --`
| alias | `gR` | `git remote`
| alias | `gRS` | `git remote set-url`
| alias | `gRa` | `git remote add`
| alias | `gRl` | `git remote --verbose`
| alias | `gRm` | `git remote rename`
| alias | `gRp` | `git remote prune`
| alias | `gRs` | `git remote show`
| alias | `gRu` | `git remote update`
| alias | `gRx` | `git remote rm`
| alias | `gS` | `git submodule`
| alias | `gSI` | `git submodule update --init --recursive`
| alias | `gSa` | `git submodule add`
| alias | `gSf` | `git submodule foreach`
| alias | `gSi` | `git submodule init`
| alias | `gSl` | `git submodule status`
| alias | `gSm` | `git-submodule-move`
| alias | `gSs` | `git submodule sync`
| alias | `gSu` | `git submodule update --remote`
| alias | `gSx` | `git-submodule-remove`
| alias | `gW` | `git worktree`
| alias | `gWX` | `git worktree remove --force`
| alias | `gWa` | `git worktree add`
| alias | `gWl` | `git worktree list`
| alias | `gWm` | `git worktree move`
| alias | `gWp` | `git worktree prune`
| alias | `gWx` | `git worktree remove`
| alias | `gb` | `git branch`
| alias | `gbG` | `git-branch-remote-tracking gone \| xargs -r git branch --delete --force`
| alias | `gbL` | `git branch --list -vv --all`
| alias | `gbM` | `git branch --move --force`
| alias | `gbR` | `git branch --force`
| alias | `gbS` | `git show-branch --all`
| alias | `gbX` | `git-branch-delete-interactive --force`
| alias | `gbc` | `git checkout -b`
| alias | `gbd` | `git checkout --detach`
| alias | `gbl` | `git branch --list -vv`
| alias | `gbm` | `git branch --move`
| alias | `gbn` | `git branch --no-contains`
| alias | `gbs` | `git show-branch`
| alias | `gbu` | `git branch --unset-upstream`
| alias | `gbx` | `git-branch-delete-interactive`
| alias | `gc` | `git commit --signoff --verbose`
| alias | `gcA` | `git commit --signoff --verbose --patch`
| alias | `gcF` | `git commit --verbose --amend`
| alias | `gcO` | `git checkout --patch`
| alias | `gcP` | `git cherry-pick --no-commit`
| alias | `gcR` | `git reset HEAD^`
| alias | `gcS` | `git commit --verbose -S`
| alias | `gcU` | `git commit --squash`
| alias | `gca` | `git commit --signoff --verbose --all`
| alias | `gcf` | `git commit --amend --reuse-message HEAD`
| alias | `gcm` | `git commit --signoff --message`
| alias | `gco` | `git checkout`
| alias | `gcp` | `git cherry-pick`
| alias | `gcr` | `git revert`
| alias | `gcs` | `git show --stat --patch --pretty=format:${_git_log_fuller_format}`
| alias | `gcu` | `git commit --fixup`
| alias | `gcv` | `git verify-commit`
| alias | `gd` | `git ls-files`
| alias | `gdI` | `git ls-files --ignored --exclude-per-directory=.gitignore --cached`
| alias | `gdc` | `git ls-files --cached`
| alias | `gdi` | `git status --porcelain --ignored=matching \| sed -n s/^!! //p`
| alias | `gdk` | `git ls-files --killed`
| alias | `gdm` | `git ls-files --modified`
| alias | `gdx` | `git ls-files --deleted`
| alias | `get` | `wget --continue --progress=bar --timestamping`
| alias | `gf` | `git fetch`
| alias | `gfa` | `git fetch --all`
| alias | `gfc` | `git clone`
| alias | `gfm` | `git pull --no-rebase`
| alias | `gfp` | `git fetch --all --prune`
| alias | `gfr` | `git pull --rebase`
| alias | `gfs` | `git-sync`
| alias | `gfu` | `git pull --ff-only --all --prune`
| alias | `gg` | `git grep`
| alias | `ggL` | `git grep --files-without-match`
| alias | `ggi` | `git grep --ignore-case`
| alias | `ggl` | `git grep --files-with-matches`
| alias | `ggv` | `git grep --invert-match`
| alias | `ggw` | `git grep --word-regexp`
| alias | `ghw` | `git help --web`
| alias | `giA` | `git add --patch`
| alias | `giD` | `git diff --no-ext-diff --cached --word-diff`
| alias | `giR` | `git reset --patch`
| alias | `giU` | `git add --verbose --all`
| alias | `giX` | `git rm --cached -rf`
| alias | `gia` | `git add --verbose`
| alias | `gid` | `git diff --no-ext-diff --cached`
| alias | `gir` | `git reset`
| alias | `giu` | `git add --verbose --update`
| alias | `gix` | `git rm --cached -r`
| alias | `gl` | `git log --date-order --pretty=format:${_git_log_fuller_format}`
| alias | `glG` | `git log --date-order --graph --pretty=format:${_git_log_oneline_medium_format}`
| alias | `glO` | `git log --date-order --pretty=format:${_git_log_oneline_medium_format}`
| alias | `glc` | `git shortlog --summary --numbered --no-merges`
| alias | `gld` | `git log --date-order --stat --patch --cc --pretty=format:${_git_log_fuller_format}`
| alias | `glf` | `git log --date-order --stat --patch --cc --follow --pretty=format:${_git_log_fuller_format}`
| alias | `glg` | `git log --date-order --graph --pretty=format:${_git_log_oneline_format}`
| alias | `glo` | `git log --date-order --pretty=format:${_git_log_oneline_format}`
| alias | `glr` | `git reflog`
| alias | `gls` | `git log --date-order --stat --pretty=format:${_git_log_fuller_format}`
| alias | `glv` | `git log --date-order --show-signature --pretty=format:${_git_log_fuller_format}`
| alias | `gm` | `git merge`
| alias | `gmC` | `git merge --no-commit`
| alias | `gmF` | `git merge --no-ff`
| alias | `gmS` | `git merge -S`
| alias | `gma` | `git merge --abort`
| alias | `gmc` | `git merge --continue`
| alias | `gms` | `git merge --squash`
| alias | `gmt` | `git mergetool`
| alias | `gmv` | `git merge --verify-signatures`
| alias | `gp` | `git push`
| alias | `gpA` | `git push --all && git push --tags --no-verify`
| alias | `gpF` | `git push --force`
| alias | `gpa` | `git push --all`
| alias | `gpc` | `git push --set-upstream origin $(git-branch-current 2>/dev/null)`
| alias | `gpf` | `git push --force-with-lease --force-if-includes`
| alias | `gpp` | `git pull origin $(git-branch-current 2>/dev/null) && git push origin $(git-branch-current 2>/dev/null)`
| alias | `gpt` | `git push --tags`
| alias | `gr` | `git rebase`
| alias | `grS` | `git rebase --exec git commit --amend --no-edit --no-verify -S`
| alias | `gra` | `git rebase --abort`
| alias | `grc` | `git rebase --continue`
| alias | `grep` | `grep --color=auto`
| alias | `gri` | `git rebase --interactive --autosquash`
| alias | `grs` | `git rebase --skip`
| alias | `gs` | `git stash`
| alias | `gsS` | `git stash push --patch --no-keep-index`
| alias | `gsX` | `git-stash-clear-interactive`
| alias | `gsa` | `git stash apply`
| alias | `gsd` | `git stash show --stat --patch --include-untracked`
| alias | `gsi` | `git stash push --staged`
| alias | `gsl` | `git stash list`
| alias | `gsp` | `git stash pop`
| alias | `gsr` | `git-stash-recover`
| alias | `gss` | `git stash push --include-untracked`
| alias | `gsu` | `git stash show --patch \| git apply --reverse`
| alias | `gsw` | `git stash push --include-untracked --keep-index`
| alias | `gsx` | `git stash drop`
| alias | `gt` | `git tag`
| alias | `gtl` | `git tag --list --sort=-committerdate`
| alias | `gts` | `git tag --sign`
| alias | `gtv` | `git verify-tag`
| alias | `gtx` | `git tag --delete`
| alias | `gu` | `git restore`
| alias | `gua` | `git restore --staged --worktree`
| alias | `gui` | `git restore --staged`
| alias | `gus` | `git restore --source`
| alias | `gwC` | `git clean -d --force`
| alias | `gwD` | `git diff --no-ext-diff --word-diff`
| alias | `gwM` | `git mv -f`
| alias | `gwR` | `git reset --hard`
| alias | `gwS` | `git status`
| alias | `gwX` | `git rm -rf`
| alias | `gwc` | `git clean --dry-run`
| alias | `gwd` | `git diff --no-ext-diff`
| alias | `gwk` | `git reset --keep`
| alias | `gwm` | `git mv`
| alias | `gwr` | `git reset --soft`
| alias | `gws` | `git status --short --branch`
| alias | `gwx` | `git rm -r`
| alias | `gy` | `git switch`
| alias | `gyc` | `git switch --create`
| alias | `gyd` | `git switch --detach`
| alias | `gym` | `git switch $(git-branch-default 2>/dev/null)`
| alias | `l` | `ll -A`
| alias | `lc` | `lt -c`
| alias | `lk` | `ll -Sr`
| alias | `ll` | `ls -lh`
| alias | `lm` | `l \| less`
| alias | `lr` | `ll -R`
| alias | `ls` | `ls --group-directories-first --color=auto`
| alias | `lt` | `ll -tr`
| alias | `lx` | `ll -X`
| alias | `nvimf` | `nvim -c FzfLua files`
| alias | `nviml` | `nvim --listen /tmp/nvim.pipe`
| alias | `pac` | `yay -Rns $(yay -Qtdq)`
| alias | `pai` | `yay -Sy`
| alias | `paii` | `yay -Sy --noconfirm`
| alias | `pam` | `rate-mirrors arch \| sudo tee /etc/pacman.d/mirrorlist`
| alias | `pan` | `yay -Qqd \| yay -Rsu --print -`
| alias | `par` | `yay -Rnsu`
| alias | `parr` | `yay -Rnsu --noconfirm`
| alias | `pau` | `yay -Syu`
| alias | `pauu` | `yay -Syu --noconfirm`
| alias | `pis` | `sandbox pi`
| alias | `piw` | `PI_CODING_AGENT_DIR=~/.pi/agent-work sandbox pi`
| alias | `reset` | `command reset   && [ -f /home/deathbeam/.config/tinted-theming/base16_shell_theme ]   && . /home/deathbeam/.config/tinted-theming/base16_shell_theme`
| alias | `run-help` | `man`
| alias | `vim` | `nvim`
| alias | `vimdiff` | `nvim -d`
| alias | `vimf` | `nvimf`
| alias | `viml` | `nviml`
| alias | `which-command` | `whence`
| alias | `why` | `witr`

# Useful Commands
_No tldr entry_

_No tldr entry_

_No tldr entry_

_No tldr entry_

_No tldr entry_

