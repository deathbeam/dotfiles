# Hyprland Keybindings
| Key | Action |
|-----|--------|
| `SUPER+Return` | exec `terminal                         # terminal` |
| `SUPER+Tab` | exec `menu-switch -p "switch"             # switch` |
| `SUPER+space` | exec `menu-run -p "run"                 # run` |
| `SUPER+p` | exec `menu-pass -p "pass"                   # passwords` |
| `SUPER+x` | exec `menu-proc -p "proc"                   # execute` |
| `SUPER+c` | exec `menu-clip -p "clip"                   # copy` |
| `SUPER+g` | exec `menu-steam -p "steam"                 # games` |
| `SUPER+i` | exec `menu-yay -p "yay"                     # install` |
| `SUPER+n` | exec `menu-notifications -p "notifications" # notifications` |
| `SUPER+u` | exec `menu-qutebrowser -p "url"             # urls` |
| `SUPER+e` | exec `swaylock -f -e -s fill -i $WALLPAPER  # lock screen` |
| `SUPER+v` | exec `pkill -USR1 gammastep                 # flux` |
| `SUPER+slash` | togglespecialworkspace `cheatsheet      # cheatsheet` |
| `SUPER+b` | togglespecialworkspace `btop                # btop` |
| `SUPER+d` | togglespecialworkspace `discord             # discord` |
| `SUPER+y` | togglespecialworkspace `youtubemusic        # youtube` |
| `SUPER+o` | togglespecialworkspace `kubernetes          # kubernetes` |
| `SUPER_SHIFT+o` | togglespecialworkspace `docker        # docker` |
| `Print` | exec `quickshell -c hyprquickshot -n` |
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
| `SUPER+escape` | exec `hyprctl reload && notify-send "Hyprland config reloaded"` |
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
| | `v` | capture-pane `-S - \; save-buffer /tmp/tmux_buffer.txt \; split-window nvim + normal G\$?. /tmp/tmux_buffer.txt && rm /tmp/tmux_buffer.txt`
| | `s` | run-shell `-b $HOME/.tmux/switch-session.sh`

# Neovim Keybindings
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
| alias | `gCO` | `gCo $(gCl)`
| alias | `gCT` | `gCt $(gCl)`
| alias | `gCa` | `git add $(gCl)`
| alias | `gCe` | `git mergetool $(gCl)`
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
| alias | `gcs` | `git show --pretty=format:${_git_log_fuller_format}`
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
| alias | `glc` | `git shortlog --summary --numbered`
| alias | `gld` | `git log --date-order --stat --patch --pretty=format:${_git_log_fuller_format}`
| alias | `glf` | `git log --date-order --stat --patch --follow --pretty=format:${_git_log_fuller_format}`
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
| alias | `gpf` | `git push --force-with-lease`
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
| alias | `gsS` | `git stash save --patch --no-keep-index`
| alias | `gsX` | `git-stash-clear-interactive`
| alias | `gsa` | `git stash apply`
| alias | `gsd` | `git stash show --patch --stat`
| alias | `gsi` | `git stash push --staged`
| alias | `gsl` | `git stash list`
| alias | `gsp` | `git stash pop`
| alias | `gsr` | `git-stash-recover`
| alias | `gss` | `git stash save --include-untracked`
| alias | `gsu` | `git stash show --patch \| git apply --reverse`
| alias | `gsw` | `git stash save --include-untracked --keep-index`
| alias | `gsx` | `git stash drop`
| alias | `gt` | `git tag`
| alias | `gtl` | `git tag --list --sort=-committerdate`
| alias | `gts` | `git tag --sign`
| alias | `gtv` | `git verify-tag`
| alias | `gtx` | `git tag --delete`
| alias | `gwC` | `git clean -d --force`
| alias | `gwD` | `git diff --no-ext-diff --word-diff`
| alias | `gwM` | `git mv -f`
| alias | `gwR` | `git reset --hard`
| alias | `gwS` | `git status`
| alias | `gwX` | `git rm -rf`
| alias | `gwc` | `git clean --dry-run`
| alias | `gwd` | `git diff --no-ext-diff`
| alias | `gwm` | `git mv`
| alias | `gwr` | `git reset --soft`
| alias | `gws` | `git status --short --branch`
| alias | `gwx` | `git rm -r`
| alias | `gy` | `git switch`
| alias | `gyc` | `git switch --create`
| alias | `gyd` | `git switch --detach`
| alias | `k` | `kubectl`
| alias | `kaf` | `kubectl apply -f`
| alias | `kc` | `kubectl`
| alias | `kcc` | `kubectl config get-contexts`
| alias | `kcf` | `kubectl create -f`
| alias | `kcl` | `kubectl logs`
| alias | `kctx` | `kubectx`
| alias | `kd` | `kubectl delete`
| alias | `kdc` | `kubectl delete cronjobs`
| alias | `kdcm` | `kubectl delete configmaps`
| alias | `kdd` | `kubectl delete deployment`
| alias | `kdds` | `kubectl delete daemonsets`
| alias | `kdf` | `kubectl delete -f`
| alias | `kdi` | `kubectl delete ingress`
| alias | `kdj` | `kubectl delete job`
| alias | `kdns` | `kubectl delete namespaces`
| alias | `kdp` | `kubectl delete pod`
| alias | `kdpv` | `kubectl delete persistentvolumes`
| alias | `kdpvc` | `kubectl delete persistentvolumeclaims`
| alias | `kds` | `kubectl delete services`
| alias | `kdsc` | `kubectl describe cronjobs`
| alias | `kdscm` | `kubectl describe configmaps`
| alias | `kdsd` | `kubectl describe deployments`
| alias | `kdsds` | `kubectl describe daemonsets`
| alias | `kdsf` | `kubectl describe -f`
| alias | `kdsi` | `kubectl describe ingress`
| alias | `kdsj` | `kubectl describe jobs`
| alias | `kdsn` | `kubectl describe nodes`
| alias | `kdsns` | `kubectl describe namespaces`
| alias | `kdsp` | `kubectl describe pods`
| alias | `kdspv` | `kubectl describe persistentvolumes`
| alias | `kdspvc` | `kubectl describe persistentvolumeclaims`
| alias | `kdss` | `kubectl describe services`
| alias | `kdssc` | `kubectl describe secrets`
| alias | `ke` | `kubectl edit`
| alias | `kec` | `kubectl edit cronjobs`
| alias | `kecm` | `kubectl edit configmaps`
| alias | `ked` | `kubectl edit deployments`
| alias | `keds` | `kubectl edit daemonsets`
| alias | `kef` | `kubectl edit -f`
| alias | `kei` | `kubectl edit ingress`
| alias | `keit` | `kubectl exec -it --`
| alias | `kej` | `kubectl edit jobs`
| alias | `ken` | `kubectl edit nodes`
| alias | `kens` | `kubectl edit namespaces`
| alias | `kep` | `kubectl edit pods`
| alias | `kepv` | `kubectl edit persistentvolumes`
| alias | `kepvc` | `kubectl edit persistentvolumeclaims`
| alias | `kes` | `kubectl edit services`
| alias | `kesc` | `kubectl edit secrets`
| alias | `kg` | `kubectl get`
| alias | `kga` | `kubectl get --all-namespaces`
| alias | `kgac` | `get_cluster_resources cronjobs`
| alias | `kgacm` | `get_cluster_resources configmaps`
| alias | `kgads` | `get_cluster_resources daemonsets`
| alias | `kgai` | `get_cluster_resources ingress`
| alias | `kgaj` | `get_cluster_resources jobs`
| alias | `kgap` | `get_cluster_resources pods`
| alias | `kgapvc` | `get_cluster_resources persistentvolumeclaims`
| alias | `kgas` | `get_cluster_resources services`
| alias | `kgasc` | `get_cluster_resources secrets`
| alias | `kgc` | `kubectl get cronjobs`
| alias | `kgcm` | `kubectl get configmaps`
| alias | `kgcmy` | `kubectl get configmaps -o yaml`
| alias | `kgcr` | `kubectl get clusterroles`
| alias | `kgcrb` | `kubectl get clusterrolebindings`
| alias | `kgcrd` | `kubectl get customresourcedefinition`
| alias | `kgcrv` | `kubectl get controllerrevisions`
| alias | `kgcs` | `kubectl get componentstatus`
| alias | `kgcsr` | `kubectl get certificatesigningrequests`
| alias | `kgcw` | `watch kubectl get cronjobs`
| alias | `kgcy` | `kubectl get cronjobs -o yaml`
| alias | `kgd` | `kubectl get deployments`
| alias | `kgds` | `kubectl get daemonsets`
| alias | `kgdsw` | `watch kubectl get daemonsets`
| alias | `kgdsy` | `kubectl get daemonsets -o yaml`
| alias | `kgdw` | `watch kubectl get deployments`
| alias | `kgdy` | `kubectl get deployments -o yaml`
| alias | `kgep` | `kubectl get endpoints`
| alias | `kgev` | `kubectl get events`
| alias | `kgf` | `kubectl get -f`
| alias | `kghpa` | `kubectl get horizontalpodautoscalers`
| alias | `kgi` | `kubectl get ingress`
| alias | `kgiy` | `kubectl get ingress -o yaml`
| alias | `kgj` | `kubectl get jobs`
| alias | `kgjw` | `watch kubectl get jobs`
| alias | `kgjy` | `kubectl get jobs -o yaml`
| alias | `kglr` | `kubectl get limitranges`
| alias | `kgn` | `kubectl get nodes`
| alias | `kgnp` | `kubectl get networkpolicies`
| alias | `kgns` | `kubectl get namespaces`
| alias | `kgnsy` | `kubectl get namespaces -o yaml`
| alias | `kgny` | `kubectl get nodes -o yaml`
| alias | `kgp` | `kubectl get pods`
| alias | `kgpdb` | `kubectl get poddisruptionbudgets`
| alias | `kgpp` | `kubectl get podpreset`
| alias | `kgpv` | `kubectl get persistentvolumes`
| alias | `kgpvc` | `kubectl get persistentvolumeclaims`
| alias | `kgpvcy` | `kubectl get persistentvolumeclaims -o yaml`
| alias | `kgpvy` | `kubectl get persistentvolumes -o yaml`
| alias | `kgpw` | `watch kubectl get pods`
| alias | `kgpy` | `kubectl get pods -o yaml`
| alias | `kgr` | `kubectl get roles`
| alias | `kgrb` | `kubectl get rolebindings`
| alias | `kgrc` | `kubectl get replicationcontrollers`
| alias | `kgrq` | `kubectl get resourcequotas`
| alias | `kgs` | `kubectl get services`
| alias | `kgsa` | `kubectl get serviceaccounts`
| alias | `kgsc` | `kubectl get secrets`
| alias | `kgscy` | `kubectl get secrets -o yaml`
| alias | `kgss` | `kubectl get statefulsets`
| alias | `kgsy` | `kubectl get services -o yaml`
| alias | `kl` | `kubectl logs`
| alias | `klf` | `kubectl logs -f`
| alias | `kns` | `kubens`
| alias | `kpsp` | `kubectl get podsecuritypolicies`
| alias | `kpt` | `kubectl get podtemplates`
| alias | `krs` | `kubectl get replicasets`
| alias | `ktn` | `kubectl top nodes`
| alias | `ktp` | `kubectl top pods`
| alias | `kube` | `kubectl`
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
| alias | `reset` | `command reset   && [ -f /home/deathbeam/.config/tinted-theming/base16_shell_theme ]   && . /home/deathbeam/.config/tinted-theming/base16_shell_theme`
| alias | `run-help` | `man`
| alias | `vim` | `nvim`
| alias | `vimdiff` | `nvim -d`
| alias | `vimf` | `nvimf`
| alias | `viml` | `nviml`
| alias | `which-command` | `whence`
| alias | `why` | `witr`

# Useful Commands
## yay

> Yet Another Yogurt: build and install packages from the Arch User Repository.
> See also: `pacman`.
> More information: <https://github.com/Jguer/yay#first-use>.

- Interactively search and install packages from the repos and AUR:

`yay {{package_name|search_term}}`

- Synchronize and update all packages from the repos and AUR:

`yay`

- Install a new package from the repos and AUR and do not ask to confirm transactions:

`yay -S {{package}} --noconfirm`

- Remove an installed package and both its dependencies and configuration files:

`yay -Rns {{package}}`

- Search the package database for a keyword from the repos and AUR:

`yay -Ss {{keyword}}`

- Remove orphaned packages (installed as dependencies but not required by any package):

`yay -Yc`

- Clean `pacman` and `yay` caches (old package versions kept for rollback and downgrade purposes):

`yay -Scc`

- Show statistics for installed packages and system health:

`yay -Ps`

## git

> Distributed version control system.
> Some subcommands such as `commit`, `add`, `branch`, `switch`, `push`, etc. have their own usage documentation.
> More information: <https://git-scm.com/docs/git>.

- Create an empty Git repository:

`git init`

- Clone a remote Git repository from the internet:

`git clone {{https://example.com/repo.git}}`

- View the status of the local repository:

`git status`

- Stage all changes for a commit:

`git add {{[-A|--all]}}`

- Commit changes to version history:

`git commit {{[-m|--message]}} {{message_text}}`

- Push local commits to a remote repository:

`git push`

- Pull any changes made to a remote:

`git pull`

- Reset everything the way it was in the latest commit:

`git reset --hard; git clean {{[-f|--force]}}`

## docker

> Manage Docker containers and images.
> Some subcommands such as `container` and `image` have their own usage documentation.
> More information: <https://docs.docker.com/reference/cli/docker/>.

- List all Docker containers (running and stopped):

`docker {{[ps|container ls]}} {{[-a|--all]}}`

- Start a container from an image, with a custom name:

`docker {{[run|container run]}} --name {{container_name}} {{image}}`

- Start or stop an existing container:

`docker container {{start|stop}} {{container_name}}`

- Pull an image from a Docker registry:

`docker {{[pull|image pull]}} {{image}}`

- Display the list of already downloaded images:

`docker {{[images|image ls]}}`

- Open an interactive tty with Bourne shell (`sh`) inside a running container:

`docker {{[exec|container exec]}} {{[-it|--interactive --tty]}} {{container_name}} {{sh}}`

- Remove stopped containers:

`docker {{[rm|container rm]}} {{container1 container2 ...}}`

- Fetch and follow the logs of a container:

`docker {{[logs|container logs]}} {{[-f|--follow]}} {{container_name}}`

## rg

> Ripgrep, a recursive line-oriented search tool.
> Aims to be a faster alternative to `grep`.
> More information: <https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md>.

- Recursively search current directory for a pattern (`regex`):

`rg {{pattern}}`

- Recursively search for a pattern in a file or directory:

`rg {{pattern}} {{path/to/file_or_directory}}`

- Search for a literal string pattern:

`rg {{[-F|--fixed-strings]}} -- {{string}}`

- Include hidden files and entries listed in `.gitignore`:

`rg {{[-.|--hidden]}} --no-ignore {{pattern}}`

- Only search the files whose names match the glob pattern(s) (e.g. `README.*`):

`rg {{pattern}} {{[-g|--glob]}} {{filename_glob_pattern}}`

- Recursively list filenames in the current directory that match a pattern:

`rg --files | rg {{pattern}}`

- Only list matched files (useful when piping to other commands):

`rg {{[-l|--files-with-matches]}} {{pattern}}`

- Show lines that do not match the pattern:

`rg {{[-v|--invert-match]}} {{pattern}}`

## kubectl

> Run commands against Kubernetes clusters.
> Some subcommands such as `run` have their own usage documentation.
> More information: <https://kubernetes.io/docs/reference/kubectl/>.

- List information about a resource with more details:

`kubectl get {{pods|service|deployment|ingress|...}} {{[-o|--output]}} wide`

- Update specified pod with the label `unhealthy` and the value `true`:

`kubectl label pods {{name}} unhealthy=true`

- List all resources with different types:

`kubectl get all`

- Display resource (CPU/Memory/Storage) usage of nodes or pods:

`kubectl top {{pods|nodes}}`

- Print the address of the master and cluster services:

`kubectl cluster-info`

- Display an explanation of a specific field:

`kubectl explain {{pods.spec.containers}}`

- Print the logs for a container in a pod or specified resource:

`kubectl logs {{pod_name}}`

- Run command in an existing pod:

`kubectl exec {{pod_name}} -- {{ls /}}`

