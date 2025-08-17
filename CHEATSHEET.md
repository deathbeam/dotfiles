# System Cheatsheet

## Zsh Aliases & Functions
| Name | Value | Type |
|------|-------|------|
| `a` | `fasd -a` | alias |
| `chmod` | `chmod --preserve-root -v` | alias |
| `chown` | `chown --preserve-root -v` | alias |
| `d` | `fasd -d` | alias |
| `df` | `df -h` | alias |
| `du` | `du -h` | alias |
| `f` | `fasd -f` | alias |
| `fsh-alias` | `fast-theme` | alias |
| `g` | `git` | alias |
| `g..` | `cd $(git-root || print .)` | alias |
| `gCO` | `gCo $(gCl)` | alias |
| `gCT` | `gCt $(gCl)` | alias |
| `gCa` | `git add $(gCl)` | alias |
| `gCe` | `git mergetool $(gCl)` | alias |
| `gCl` | `git --no-pager diff --name-only --diff-filter=U` | alias |
| `gCo` | `git checkout --ours --` | alias |
| `gCt` | `git checkout --theirs --` | alias |
| `gR` | `git remote` | alias |
| `gRS` | `git remote set-url` | alias |
| `gRa` | `git remote add` | alias |
| `gRl` | `git remote --verbose` | alias |
| `gRm` | `git remote rename` | alias |
| `gRp` | `git remote prune` | alias |
| `gRs` | `git remote show` | alias |
| `gRu` | `git remote update` | alias |
| `gRx` | `git remote rm` | alias |
| `gS` | `git submodule` | alias |
| `gSI` | `git submodule update --init --recursive` | alias |
| `gSa` | `git submodule add` | alias |
| `gSf` | `git submodule foreach` | alias |
| `gSi` | `git submodule init` | alias |
| `gSl` | `git submodule status` | alias |
| `gSm` | `git-submodule-move` | alias |
| `gSs` | `git submodule sync` | alias |
| `gSu` | `git submodule update --remote` | alias |
| `gSx` | `git-submodule-remove` | alias |
| `gW` | `git worktree` | alias |
| `gWX` | `git worktree remove --force` | alias |
| `gWa` | `git worktree add` | alias |
| `gWl` | `git worktree list` | alias |
| `gWm` | `git worktree move` | alias |
| `gWp` | `git worktree prune` | alias |
| `gWx` | `git worktree remove` | alias |
| `gb` | `git branch` | alias |
| `gbG` | `git-branch-remote-tracking gone | xargs -r git branch --delete --force` | alias |
| `gbL` | `git branch --list -vv --all` | alias |
| `gbM` | `git branch --move --force` | alias |
| `gbR` | `git branch --force` | alias |
| `gbS` | `git show-branch --all` | alias |
| `gbX` | `git-branch-delete-interactive --force` | alias |
| `gbc` | `git checkout -b` | alias |
| `gbd` | `git checkout --detach` | alias |
| `gbl` | `git branch --list -vv` | alias |
| `gbm` | `git branch --move` | alias |
| `gbn` | `git branch --no-contains` | alias |
| `gbs` | `git show-branch` | alias |
| `gbu` | `git branch --unset-upstream` | alias |
| `gbx` | `git-branch-delete-interactive` | alias |
| `gc` | `git commit --signoff --verbose` | alias |
| `gcA` | `git commit --signoff --verbose --patch` | alias |
| `gcF` | `git commit --verbose --amend` | alias |
| `gcO` | `git checkout --patch` | alias |
| `gcP` | `git cherry-pick --no-commit` | alias |
| `gcR` | `git reset HEAD^` | alias |
| `gcS` | `git commit --verbose -S` | alias |
| `gcU` | `git commit --squash` | alias |
| `gca` | `git commit --signoff --verbose --all` | alias |
| `gcf` | `git commit --amend --reuse-message HEAD` | alias |
| `gcm` | `git commit --signoff --message` | alias |
| `gco` | `git checkout` | alias |
| `gcp` | `git cherry-pick` | alias |
| `gcr` | `git revert` | alias |
| `gcs` | `git show --pretty=format:${_git_log_fuller_format}` | alias |
| `gcu` | `git commit --fixup` | alias |
| `gcv` | `git verify-commit` | alias |
| `gd` | `git ls-files` | alias |
| `gdI` | `git ls-files --ignored --exclude-per-directory=.gitignore --cached` | alias |
| `gdc` | `git ls-files --cached` | alias |
| `gdi` | `git status --porcelain --ignored=matching | sed -n s/^!! //p` | alias |
| `gdk` | `git ls-files --killed` | alias |
| `gdm` | `git ls-files --modified` | alias |
| `gdu` | `git ls-files --other --exclude-standard` | alias |
| `gdx` | `git ls-files --deleted` | alias |
| `get` | `wget --continue --progress=bar --timestamping` | alias |
| `gf` | `git fetch` | alias |
| `gfa` | `git fetch --all` | alias |
| `gfc` | `git clone` | alias |
| `gfm` | `git pull --no-rebase` | alias |
| `gfp` | `git fetch --all --prune` | alias |
| `gfr` | `git pull --rebase` | alias |
| `gfu` | `git pull --ff-only --all --prune` | alias |
| `gg` | `git grep` | alias |
| `ggL` | `git grep --files-without-match` | alias |
| `ggi` | `git grep --ignore-case` | alias |
| `ggl` | `git grep --files-with-matches` | alias |
| `ggv` | `git grep --invert-match` | alias |
| `ggw` | `git grep --word-regexp` | alias |
| `ghw` | `git help --web` | alias |
| `giA` | `git add --patch` | alias |
| `giD` | `git diff --no-ext-diff --cached --word-diff` | alias |
| `giR` | `git reset --patch` | alias |
| `giU` | `git add --verbose --all` | alias |
| `giX` | `git rm --cached -rf` | alias |
| `gia` | `git add --verbose` | alias |
| `gid` | `git diff --no-ext-diff --cached` | alias |
| `gir` | `git reset` | alias |
| `giu` | `git add --verbose --update` | alias |
| `gix` | `git rm --cached -r` | alias |
| `gl` | `git log --date-order --pretty=format:${_git_log_fuller_format}` | alias |
| `glG` | `git log --date-order --graph --pretty=format:${_git_log_oneline_medium_format}` | alias |
| `glO` | `git log --date-order --pretty=format:${_git_log_oneline_medium_format}` | alias |
| `glc` | `git shortlog --summary --numbered` | alias |
| `gld` | `git log --date-order --stat --patch --pretty=format:${_git_log_fuller_format}` | alias |
| `glf` | `git log --date-order --stat --patch --follow --pretty=format:${_git_log_fuller_format}` | alias |
| `glg` | `git log --date-order --graph --pretty=format:${_git_log_oneline_format}` | alias |
| `glo` | `git log --date-order --pretty=format:${_git_log_oneline_format}` | alias |
| `glr` | `git reflog` | alias |
| `gls` | `git log --date-order --stat --pretty=format:${_git_log_fuller_format}` | alias |
| `glv` | `git log --date-order --show-signature --pretty=format:${_git_log_fuller_format}` | alias |
| `gm` | `git merge` | alias |
| `gmC` | `git merge --no-commit` | alias |
| `gmF` | `git merge --no-ff` | alias |
| `gmS` | `git merge -S` | alias |
| `gma` | `git merge --abort` | alias |
| `gmc` | `git merge --continue` | alias |
| `gms` | `git merge --squash` | alias |
| `gmt` | `git mergetool` | alias |
| `gmv` | `git merge --verify-signatures` | alias |
| `gp` | `git push` | alias |
| `gpA` | `git push --all && git push --tags --no-verify` | alias |
| `gpF` | `git push --force` | alias |
| `gpa` | `git push --all` | alias |
| `gpc` | `git push --set-upstream origin $(git-branch-current 2>/dev/null)` | alias |
| `gpf` | `git push --force-with-lease` | alias |
| `gpp` | `git pull origin $(git-branch-current 2>/dev/null) && git push origin $(git-branch-current 2>/dev/null)` | alias |
| `gpt` | `git push --tags` | alias |
| `gr` | `git rebase` | alias |
| `grS` | `git rebase --exec git commit --amend --no-edit --no-verify -S` | alias |
| `gra` | `git rebase --abort` | alias |
| `grc` | `git rebase --continue` | alias |
| `grep` | `grep --color=auto` | alias |
| `gri` | `git rebase --interactive --autosquash` | alias |
| `grs` | `git rebase --skip` | alias |
| `gs` | `git stash` | alias |
| `gsS` | `git stash save --patch --no-keep-index` | alias |
| `gsX` | `git-stash-clear-interactive` | alias |
| `gsa` | `git stash apply` | alias |
| `gsd` | `git stash show --patch --stat` | alias |
| `gsi` | `git stash push --staged` | alias |
| `gsl` | `git stash list` | alias |
| `gsp` | `git stash pop` | alias |
| `gsr` | `git-stash-recover` | alias |
| `gss` | `git stash save --include-untracked` | alias |
| `gsu` | `git stash show --patch | git apply --reverse` | alias |
| `gsw` | `git stash save --include-untracked --keep-index` | alias |
| `gsx` | `git stash drop` | alias |
| `gt` | `git tag` | alias |
| `gtl` | `git tag --list --sort=-committerdate` | alias |
| `gts` | `git tag --sign` | alias |
| `gtv` | `git verify-tag` | alias |
| `gtx` | `git tag --delete` | alias |
| `gwC` | `git clean -d --force` | alias |
| `gwD` | `git diff --no-ext-diff --word-diff` | alias |
| `gwM` | `git mv -f` | alias |
| `gwR` | `git reset --hard` | alias |
| `gwS` | `git status` | alias |
| `gwX` | `git rm -rf` | alias |
| `gwc` | `git clean --dry-run` | alias |
| `gwd` | `git diff --no-ext-diff` | alias |
| `gwm` | `git mv` | alias |
| `gwr` | `git reset --soft` | alias |
| `gws` | `git status --short --branch` | alias |
| `gwx` | `git rm -r` | alias |
| `gy` | `git switch` | alias |
| `gyc` | `git switch --create` | alias |
| `gyd` | `git switch --detach` | alias |
| `k` | `kubectl` | alias |
| `kaf` | `kubectl apply -f` | alias |
| `kc` | `kubectl` | alias |
| `kcc` | `kubectl config get-contexts` | alias |
| `kcf` | `kubectl create -f` | alias |
| `kcl` | `kubectl logs` | alias |
| `kctx` | `kubectx` | alias |
| `kd` | `kubectl delete` | alias |
| `kdc` | `kubectl delete cronjobs` | alias |
| `kdcm` | `kubectl delete configmaps` | alias |
| `kdd` | `kubectl delete deployment` | alias |
| `kdds` | `kubectl delete daemonsets` | alias |
| `kdf` | `kubectl delete -f` | alias |
| `kdi` | `kubectl delete ingress` | alias |
| `kdj` | `kubectl delete job` | alias |
| `kdns` | `kubectl delete namespaces` | alias |
| `kdp` | `kubectl delete pod` | alias |
| `kdpv` | `kubectl delete persistentvolumes` | alias |
| `kdpvc` | `kubectl delete persistentvolumeclaims` | alias |
| `kds` | `kubectl delete services` | alias |
| `kdsc` | `kubectl describe cronjobs` | alias |
| `kdscm` | `kubectl describe configmaps` | alias |
| `kdsd` | `kubectl describe deployments` | alias |
| `kdsds` | `kubectl describe daemonsets` | alias |
| `kdsf` | `kubectl describe -f` | alias |
| `kdsi` | `kubectl describe ingress` | alias |
| `kdsj` | `kubectl describe jobs` | alias |
| `kdsn` | `kubectl describe nodes` | alias |
| `kdsns` | `kubectl describe namespaces` | alias |
| `kdsp` | `kubectl describe pods` | alias |
| `kdspv` | `kubectl describe persistentvolumes` | alias |
| `kdspvc` | `kubectl describe persistentvolumeclaims` | alias |
| `kdss` | `kubectl describe services` | alias |
| `kdssc` | `kubectl describe secrets` | alias |
| `ke` | `kubectl edit` | alias |
| `kec` | `kubectl edit cronjobs` | alias |
| `kecm` | `kubectl edit configmaps` | alias |
| `ked` | `kubectl edit deployments` | alias |
| `keds` | `kubectl edit daemonsets` | alias |
| `kef` | `kubectl edit -f` | alias |
| `kei` | `kubectl edit ingress` | alias |
| `keit` | `kubectl exec -it --` | alias |
| `kej` | `kubectl edit jobs` | alias |
| `ken` | `kubectl edit nodes` | alias |
| `kens` | `kubectl edit namespaces` | alias |
| `kep` | `kubectl edit pods` | alias |
| `kepv` | `kubectl edit persistentvolumes` | alias |
| `kepvc` | `kubectl edit persistentvolumeclaims` | alias |
| `kes` | `kubectl edit services` | alias |
| `kesc` | `kubectl edit secrets` | alias |
| `kg` | `kubectl get` | alias |
| `kga` | `kubectl get --all-namespaces` | alias |
| `kgac` | `get_cluster_resources cronjobs` | alias |
| `kgacm` | `get_cluster_resources configmaps` | alias |
| `kgads` | `get_cluster_resources daemonsets` | alias |
| `kgai` | `get_cluster_resources ingress` | alias |
| `kgaj` | `get_cluster_resources jobs` | alias |
| `kgap` | `get_cluster_resources pods` | alias |
| `kgapvc` | `get_cluster_resources persistentvolumeclaims` | alias |
| `kgas` | `get_cluster_resources services` | alias |
| `kgasc` | `get_cluster_resources secrets` | alias |
| `kgc` | `kubectl get cronjobs` | alias |
| `kgcm` | `kubectl get configmaps` | alias |
| `kgcmy` | `kubectl get configmaps -o yaml` | alias |
| `kgcr` | `kubectl get clusterroles` | alias |
| `kgcrb` | `kubectl get clusterrolebindings` | alias |
| `kgcrd` | `kubectl get customresourcedefinition` | alias |
| `kgcrv` | `kubectl get controllerrevisions` | alias |
| `kgcs` | `kubectl get componentstatus` | alias |
| `kgcsr` | `kubectl get certificatesigningrequests` | alias |
| `kgcw` | `watch kubectl get cronjobs` | alias |
| `kgcy` | `kubectl get cronjobs -o yaml` | alias |
| `kgd` | `kubectl get deployments` | alias |
| `kgds` | `kubectl get daemonsets` | alias |
| `kgdsw` | `watch kubectl get daemonsets` | alias |
| `kgdsy` | `kubectl get daemonsets -o yaml` | alias |
| `kgdw` | `watch kubectl get deployments` | alias |
| `kgdy` | `kubectl get deployments -o yaml` | alias |
| `kgep` | `kubectl get endpoints` | alias |
| `kgev` | `kubectl get events` | alias |
| `kgf` | `kubectl get -f` | alias |
| `kghpa` | `kubectl get horizontalpodautoscalers` | alias |
| `kgi` | `kubectl get ingress` | alias |
| `kgiy` | `kubectl get ingress -o yaml` | alias |
| `kgj` | `kubectl get jobs` | alias |
| `kgjw` | `watch kubectl get jobs` | alias |
| `kgjy` | `kubectl get jobs -o yaml` | alias |
| `kglr` | `kubectl get limitranges` | alias |
| `kgn` | `kubectl get nodes` | alias |
| `kgnp` | `kubectl get networkpolicies` | alias |
| `kgns` | `kubectl get namespaces` | alias |
| `kgnsy` | `kubectl get namespaces -o yaml` | alias |
| `kgny` | `kubectl get nodes -o yaml` | alias |
| `kgp` | `kubectl get pods` | alias |
| `kgpdb` | `kubectl get poddisruptionbudgets` | alias |
| `kgpp` | `kubectl get podpreset` | alias |
| `kgpv` | `kubectl get persistentvolumes` | alias |
| `kgpvc` | `kubectl get persistentvolumeclaims` | alias |
| `kgpvcy` | `kubectl get persistentvolumeclaims -o yaml` | alias |
| `kgpvy` | `kubectl get persistentvolumes -o yaml` | alias |
| `kgpw` | `watch kubectl get pods` | alias |
| `kgpy` | `kubectl get pods -o yaml` | alias |
| `kgr` | `kubectl get roles` | alias |
| `kgrb` | `kubectl get rolebindings` | alias |
| `kgrc` | `kubectl get replicationcontrollers` | alias |
| `kgrq` | `kubectl get resourcequotas` | alias |
| `kgs` | `kubectl get services` | alias |
| `kgsa` | `kubectl get serviceaccounts` | alias |
| `kgsc` | `kubectl get secrets` | alias |
| `kgscy` | `kubectl get secrets -o yaml` | alias |
| `kgss` | `kubectl get statefulsets` | alias |
| `kgsy` | `kubectl get services -o yaml` | alias |
| `kl` | `kubectl logs` | alias |
| `klf` | `kubectl logs -f` | alias |
| `kns` | `kubens` | alias |
| `kpsp` | `kubectl get podsecuritypolicies` | alias |
| `kpt` | `kubectl get podtemplates` | alias |
| `krs` | `kubectl get replicasets` | alias |
| `ktn` | `kubectl top nodes` | alias |
| `ktp` | `kubectl top pods` | alias |
| `kube` | `kubectl` | alias |
| `l` | `ll -A` | alias |
| `lc` | `lt -c` | alias |
| `lk` | `ll -Sr` | alias |
| `ll` | `ls -lh` | alias |
| `lm` | `l | less` | alias |
| `lr` | `ll -R` | alias |
| `ls` | `ls --group-directories-first --color=auto` | alias |
| `lt` | `ll -tr` | alias |
| `lx` | `ll -X` | alias |
| `nvimf` | `nvim -c FzfLua files` | alias |
| `nviml` | `nvim --listen /tmp/nvim.pipe` | alias |
| `pac` | `yay -Rns $(yay -Qtdq)` | alias |
| `pai` | `yay -Sy` | alias |
| `paii` | `yay -Sy --noconfirm` | alias |
| `pam` | `rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist` | alias |
| `pan` | `yay -Qqd | yay -Rsu --print -` | alias |
| `par` | `yay -Rnsu` | alias |
| `parr` | `yay -Rnsu --noconfirm` | alias |
| `pau` | `yay -Syu` | alias |
| `pauu` | `yay -Syu --noconfirm` | alias |
| `reset` | `command reset   && [ -f /home/deathbeam/.config/tinted-theming/base16_shell_theme ]   && . /home/deathbeam/.config/tinted-theming/base16_shell_theme` | alias |
| `run-help` | `man` | alias |
| `s` | `fasd -si` | alias |
| `sd` | `fasd -sid` | alias |
| `sf` | `fasd -sif` | alias |
| `v` | `f -e vim -b viminfo` | alias |
| `vim` | `nvim` | alias |
| `vimdiff` | `nvim -d` | alias |
| `vimf` | `nvimf` | alias |
| `viml` | `nviml` | alias |
| `which-command` | `whence` | alias |
| `z` | `fasd_cd -d` | alias |
| `zz` | `fasd_cd -d -i` | alias |
| `ast-highlight-main-type` | | function |

## Tmux Keybindings
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
| | `v` | capture-pane `-S - \; save-buffer /tmp/tmux_buffer.txt \; split-window nvim + normal G\$?. /tmp/tmux_buffer.txt && rm /tmp/tmux_buffer.txt`
| | `s` | run-shell `-b $HOME/.tmux/switch-session.sh`

## Hyprland Keybindings
| Key | Action |
|-----|--------|
| `SUPER+Return` | exec `terminal` |
| `SUPER+Tab` | exec `switchmenu -p "switch"` |
| `SUPER+space` | exec `runmenu -p "run"` |
| `SUPER+z` | exec `passmenu -p "pass"` |
| `SUPER+x` | exec `procmenu -p "proc"` |
| `SUPER+c` | exec `clipmenu -p "clip"` |
| `SUPER+v` | exec `steammenu -p "steam"` |
| `SUPER+n` | exec `notificationsmenu -p "notifications"` |
| `SUPER+e` | exec `swaylock -f -i $WALLPAPER` |
| `SUPER+g` | exec `pkill -USR1 gammastep` |
| `Print` | exec `sleep 1 && grim -t ppm - | satty -f - -o "$HOME/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.png"` |
| `SUPER+Print` | exec `screenrecorder` |
| `XF86AudioRaiseVolume` | exec `amixer -q set Master 5%+ on` |
| `XF86AudioLowerVolume` | exec `amixer -q set Master 5%-` |
| `XF86AudioMute` | exec `amixer -q set Master toggle` |
| `XF86AudioMicMute` | exec `amixer -q set Capture toggle` |
| `XF86MonBrightnessUp` | exec `brightnessctl s +5%` |
| `XF86MonBrightnessDown` | exec `brightnessctl s 5%-` |
| `XF86KbdBrightnessUp` | exec `asusctl -n` |
| `XF86KbdBrightnessDown` | exec `asusctl -p` |
| `XF86Launch1` | exec `rog-control-center` |
| `XF86Launch3` | exec `asusctl led-mode -n` |
| `XF86Launch4` | exec `asusctl profile -p` |
| `SUPER_SHIFT+escape` | exit |
| `SUPER+escape` | exec `hyprctl reload` |
| `SUPER+W` | killactive |
| `SUPER+S` | togglefloating |
| `SUPER+M` | fullscreen `1` |
| `SUPER+F` | fullscreen `0` |
| `SUPER+H` | movefocus `l` |
| `SUPER+L` | movefocus `r` |
| `SUPER+K` | movefocus `u` |
| `SUPER+J` | movefocus `d` |
| `SUPER_SHIFT+H` | movewindow `l` |
| `SUPER_SHIFT+L` | movewindow `r` |
| `SUPER_SHIFT+K` | movewindow `u` |
| `SUPER_SHIFT+J` | movewindow `d` |
| `SUPER+R` | submap `resize` |
| `escape` | submap `reset` |
| `Return` | submap `reset` |
| `SUPER+1` | workspace `1` |
| `SUPER+2` | workspace `2` |
| `SUPER+3` | workspace `3` |
| `SUPER+4` | workspace `4` |
| `SUPER+5` | workspace `5` |
| `SUPER+6` | workspace `6` |
| `SUPER+7` | workspace `7` |
| `SUPER+8` | workspace `8` |
| `SUPER+9` | workspace `9` |
| `SUPER+grave` | togglespecialworkspace |
| `SUPER_SHIFT+1` | movetoworkspace `1` |
| `SUPER_SHIFT+2` | movetoworkspace `2` |
| `SUPER_SHIFT+3` | movetoworkspace `3` |
| `SUPER_SHIFT+4` | movetoworkspace `4` |
| `SUPER_SHIFT+5` | movetoworkspace `5` |
| `SUPER_SHIFT+6` | movetoworkspace `6` |
| `SUPER_SHIFT+7` | movetoworkspace `7` |
| `SUPER_SHIFT+8` | movetoworkspace `8` |
| `SUPER_SHIFT+9` | movetoworkspace `9` |
| `SUPER_SHIFT+grave` | movetoworkspace `special` |

## Neovim <leader> Keybindings
| Mode | Key | Description |
|------|-----|-------------|
| nv | `<Space>ad` | AI Documentation |
| nv | `<Space>ae` | AI Explain |
| nv | `<Space>af` | AI Fix |
| nv | `<Space>ac` | AI Generate Commit |
| n | `<Space>am` | AI Models |
| v | `<Space>aa` | AI Open |
| nv | `<Space>ao` | AI Optimize |
| nv | `<Space>ap` | AI Prompts |
| nv | `<Space>aq` | AI Question |
| n | `<Space>ax` | AI Reset |
| nv | `<Space>ar` | AI Review |
| n | `<Space>as` | AI Stop |
| nv | `<Space>at` | AI Tests |
| n | `<Space>aa` | AI Toggle |
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
| n | `<Space>fu` | Find Undo History |
| n | `<Space>he` | HTTP Environment |
| n | `<Space>hh` | HTTP Run |
| n | `<Space>hH` | HTTP Run All |
| n | `<Space>ho` | HTTP Toggle |
| n | `<Space>wd` | Wiki Diary List |
| n | `<Space>ww` | Wiki List |
| n | `<Space>wn` | Wiki New |
| n | `<Space>wt` | Wiki Today |
| n | `<Space>z` | Zoom |

## Common Commands (tldr)
### ls
ls
  List directory contents.  More information: https://www.gnu.org/software/coreutils/manual/html_node/ls-invocation.html.
  - List files one per line:    ls -1
  - List all files, including hidden files:    ls --all
  - List files with a trailing symbol to indicate file type (directory/, symbolic_link@, executable*, ...):    ls --classify
  - List all files in [l]ong format (permissions, ownership, size, and modification date):    ls -l --all
  - List files in [l]ong format with size displayed using human-readable units (KiB, MiB, GiB):    ls -l --human-readable
  - List files in [l]ong format, sorted by [S]ize (descending) recursively:    ls -lS --recursive
  - List files in [l]ong format, sorted by [t]ime the file was modified and in reverse order (oldest first):    ls -lt --reverse
  - Only list directories:    ls --directory */

### grep
grep
  Find patterns in files using `regex`es.  More information: https://www.gnu.org/software/grep/manual/grep.html.
  - Search for a pattern within a file:    grep "search_pattern" path/to/file
  - Search for an exact string (disables [3mregex[23mes):    grep --fixed-strings "exact_string" path/to/file
  - Search for a pattern in all files recursively in a directory, showing line numbers of matches, ignoring binary files:    grep --recursive --line-number --binary-files=without-match "search_pattern" path/to/directory
  - Use extended [3mregex[23mes (supports [3m?[23m, [3m+[23m, [3m{}[23m, [3m()[23m, and [3m|[23m), in case-insensitive mode:    grep --extended-regexp --ignore-case "search_pattern" path/to/file
  - Print 3 lines of [C]ontext around, [B]efore or [A]fter each match:    grep --context|--before-context|--after-context 3 "search_pattern" path/to/file
  - Print file name and line number for each match with color output:    grep --with-filename --line-number --color=always "search_pattern" path/to/file
  - Search for lines matching a pattern, printing only the matched text:    grep --only-matching "search_pattern" path/to/file
  - Search [3mstdin[23m for lines that do not match a pattern:    cat path/to/file | grep --invert-match "search_pattern"

### tmux
tmux
  Terminal multiplexer.  It allows multiple sessions with windows, panes, and more.  See also: `zellij`, `screen`.  More information: https://github.com/tmux/tmux.
  - Start a new session:    tmux
  - Start a new named [s]ession:    tmux new-session -s name
  - List existing sessions:    tmux list-sessions
  - Attach to the most recently used session:    tmux attach
  - Detach from the current session (inside a tmux session):    <Ctrl b><d>
  - Create a new window (inside a tmux session):    <Ctrl b><c>
  - Switch between sessions and windows (inside a tmux session):    <Ctrl b><w>
  - Kill a session by [t]arget name:    tmux kill-session -t name

### nvim
nvim
  Neovim, a programmer's text editor based on Vim, provides several modes for different kinds of text manipulation.  Pressing `i` in normal mode enters insert mode. `Esc` or `Ctrl c` goes back to normal mode, which doesn't allow regular text insertion.  See also: `vim`, `vimtutor`, `vimdiff`.  More information: https://neovim.io.
  - Open a file:    nvim path/to/file
  - Enter text editing mode (insert mode):    <Esc><i>
  - Copy ("yank") or cut ("delete") the current line (paste it with [3m<p>[23m):    <Esc><y><y>|<d><d>
  - Enter normal mode and undo the last operation:    <Esc><u>
  - Search for a pattern in the file (press [3m<n>[23m/[3m<N>[23m to go to next/previous match):    <Esc></>search_pattern<Enter>
  - Perform a [3mregex[23m substitution in the whole file:    <Esc><:>%s/regex/replacement/g<Enter>
  - Enter normal mode and save (write) the file, and quit:    <Esc><Z><Z>|<Esc><:>x<Enter>|<Esc><:>wq<Enter>
  - Quit without saving:    <Esc><:>q!<Enter>

### git
git
  Distributed version control system.  Some subcommands such as `commit`, `add`, `branch`, `switch`, `push`, etc. have their own usage documentation.  More information: https://git-scm.com/docs/git.
  - Create an empty Git repository:    git init
  - Clone a remote Git repository from the internet:    git clone https://example.com/repo.git
  - View the status of the local repository:    git status
  - Stage all changes for a commit:    git add --all
  - Commit changes to version history:    git commit --message message_text
  - Push local commits to a remote repository:    git push
  - Pull any changes made to a remote:    git pull
  - Reset everything the way it was in the latest commit:    git reset --hard; git clean --force

### docker
docker
  Manage Docker containers and images.  Some subcommands such as `run` have their own usage documentation.  More information: https://docs.docker.com/reference/cli/docker/.
  - List all Docker containers (running and stopped):    docker ps --all
  - Start a container from an image, with a custom name:    docker run --name container_name image
  - Start or stop an existing container:    docker start|stop container_name
  - Pull an image from a Docker registry:    docker pull image
  - Display the list of already downloaded images:    docker images
  - Open an interactive tty with Bourne shell ([3msh[23m) inside a running container:    docker exec --interactive --tty container_name sh
  - Remove stopped containers:    docker rm container1 container2 ...
  - Fetch and follow the logs of a container:    docker logs --follow container_name

### yay
yay
  Yet Another Yogurt: build and install packages from the Arch User Repository.  See also: `pacman`.  More information: https://github.com/Jguer/yay.
  - Interactively search and install packages from the repos and AUR:    yay package_name|search_term
  - Synchronize and update all packages from the repos and AUR:    yay
  - Install a new package from the repos and AUR and do not ask to confirm transactions:    yay -S package --noconfirm
  - Remove an installed package and both its dependencies and configuration files:    yay -Rns package
  - Search the package database for a keyword from the repos and AUR:    yay -Ss keyword
  - Remove orphaned packages (installed as dependencies but not required by any package):    yay -Yc
  - Clean [3mpacman[23m and [3myay[23m caches (old package versions kept for rollback and downgrade purposes):    yay -Scc
  - Show statistics for installed packages and system health:    yay -Ps

### pacman
pacman
  Arch Linux package manager utility.  See also: `pacman-sync`, `pacman-remove`, `pacman-query`, `pacman-upgrade`, `pacman-files`, `pacman-database`, `pacman-deptest`, `pacman-key`, `pacman-mirrors`.  For equivalent commands in other package managers, see https://wiki.archlinux.org/title/Pacman/Rosetta.  More information: https://manned.org/pacman.8.
  - [S]ynchronize and update all packages:    sudo pacman -Syu
  - Install a new package:    sudo pacman -S package
  - [R]emove a package and its dependencies:    sudo pacman -Rs package
  - Search ([s]) the package database for a [3mregex[23m or keyword:    pacman -Ss "search_pattern"
  - Search the database for packages containing a specific [F]ile:    pacman -F "file_name"
  - List only the [e]xplicitly installed packages and versions:    pacman -Qe
  - List orphan packages (installed as [d]ependencies but not actually required by any package):    pacman -Qtdq
  - Empty the entire [3mpacman[23m cache:    sudo pacman -Scc

