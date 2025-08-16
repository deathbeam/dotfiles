# System Cheatsheet

## Zsh Aliases & Functions
`a`: `fasd -a`  
`chmod`: `chmod --preserve-root -v`  
`chown`: `chown --preserve-root -v`  
`d`: `fasd -d`  
`df`: `df -h`  
`du`: `du -h`  
`f`: `fasd -f`  
`fsh-alias`: `fast-theme`  
`g`: `git`  
`g..`: `cd $(git-root || print .)`  
`gCO`: `gCo $(gCl)`  
`gCT`: `gCt $(gCl)`  
`gCa`: `git add $(gCl)`  
`gCe`: `git mergetool $(gCl)`  
`gCl`: `git --no-pager diff --name-only --diff-filter=U`  
`gCo`: `git checkout --ours --`  
`gCt`: `git checkout --theirs --`  
`gR`: `git remote`  
`gRS`: `git remote set-url`  
`gRa`: `git remote add`  
`gRl`: `git remote --verbose`  
`gRm`: `git remote rename`  
`gRp`: `git remote prune`  
`gRs`: `git remote show`  
`gRu`: `git remote update`  
`gRx`: `git remote rm`  
`gS`: `git submodule`  
`gSI`: `git submodule update --init --recursive`  
`gSa`: `git submodule add`  
`gSf`: `git submodule foreach`  
`gSi`: `git submodule init`  
`gSl`: `git submodule status`  
`gSm`: `git-submodule-move`  
`gSs`: `git submodule sync`  
`gSu`: `git submodule update --remote`  
`gSx`: `git-submodule-remove`  
`gW`: `git worktree`  
`gWX`: `git worktree remove --force`  
`gWa`: `git worktree add`  
`gWl`: `git worktree list`  
`gWm`: `git worktree move`  
`gWp`: `git worktree prune`  
`gWx`: `git worktree remove`  
`gb`: `git branch`  
`gbG`: `git-branch-remote-tracking gone | xargs -r git branch --delete --force`  
`gbL`: `git branch --list -vv --all`  
`gbM`: `git branch --move --force`  
`gbR`: `git branch --force`  
`gbS`: `git show-branch --all`  
`gbX`: `git-branch-delete-interactive --force`  
`gbc`: `git checkout -b`  
`gbd`: `git checkout --detach`  
`gbl`: `git branch --list -vv`  
`gbm`: `git branch --move`  
`gbn`: `git branch --no-contains`  
`gbs`: `git show-branch`  
`gbu`: `git branch --unset-upstream`  
`gbx`: `git-branch-delete-interactive`  
`gc`: `git commit --signoff --verbose`  
`gcA`: `git commit --signoff --verbose --patch`  
`gcF`: `git commit --verbose --amend`  
`gcO`: `git checkout --patch`  
`gcP`: `git cherry-pick --no-commit`  
`gcR`: `git reset HEAD^`  
`gcS`: `git commit --verbose -S`  
`gcU`: `git commit --squash`  
`gca`: `git commit --signoff --verbose --all`  
`gcf`: `git commit --amend --reuse-message HEAD`  
`gcm`: `git commit --signoff --message`  
`gco`: `git checkout`  
`gcp`: `git cherry-pick`  
`gcr`: `git revert`  
`gcs`: `git show --pretty=format:${_git_log_fuller_format}`  
`gcu`: `git commit --fixup`  
`gcv`: `git verify-commit`  
`gd`: `git ls-files`  
`gdI`: `git ls-files --ignored --exclude-per-directory=.gitignore --cached`  
`gdc`: `git ls-files --cached`  
`gdi`: `git status --porcelain --ignored=matching | sed -n s/^!! //p`  
`gdk`: `git ls-files --killed`  
`gdm`: `git ls-files --modified`  
`gdu`: `git ls-files --other --exclude-standard`  
`gdx`: `git ls-files --deleted`  
`get`: `wget --continue --progress=bar --timestamping`  
`gf`: `git fetch`  
`gfa`: `git fetch --all`  
`gfc`: `git clone`  
`gfm`: `git pull --no-rebase`  
`gfp`: `git fetch --all --prune`  
`gfr`: `git pull --rebase`  
`gfu`: `git pull --ff-only --all --prune`  
`gg`: `git grep`  
`ggL`: `git grep --files-without-match`  
`ggi`: `git grep --ignore-case`  
`ggl`: `git grep --files-with-matches`  
`ggv`: `git grep --invert-match`  
`ggw`: `git grep --word-regexp`  
`ghw`: `git help --web`  
`giA`: `git add --patch`  
`giD`: `git diff --no-ext-diff --cached --word-diff`  
`giR`: `git reset --patch`  
`giU`: `git add --verbose --all`  
`giX`: `git rm --cached -rf`  
`gia`: `git add --verbose`  
`gid`: `git diff --no-ext-diff --cached`  
`gir`: `git reset`  
`giu`: `git add --verbose --update`  
`gix`: `git rm --cached -r`  
`gl`: `git log --date-order --pretty=format:${_git_log_fuller_format}`  
`glG`: `git log --date-order --graph --pretty=format:${_git_log_oneline_medium_format}`  
`glO`: `git log --date-order --pretty=format:${_git_log_oneline_medium_format}`  
`glc`: `git shortlog --summary --numbered`  
`gld`: `git log --date-order --stat --patch --pretty=format:${_git_log_fuller_format}`  
`glf`: `git log --date-order --stat --patch --follow --pretty=format:${_git_log_fuller_format}`  
`glg`: `git log --date-order --graph --pretty=format:${_git_log_oneline_format}`  
`glo`: `git log --date-order --pretty=format:${_git_log_oneline_format}`  
`glr`: `git reflog`  
`gls`: `git log --date-order --stat --pretty=format:${_git_log_fuller_format}`  
`glv`: `git log --date-order --show-signature --pretty=format:${_git_log_fuller_format}`  
`gm`: `git merge`  
`gmC`: `git merge --no-commit`  
`gmF`: `git merge --no-ff`  
`gmS`: `git merge -S`  
`gma`: `git merge --abort`  
`gmc`: `git merge --continue`  
`gms`: `git merge --squash`  
`gmt`: `git mergetool`  
`gmv`: `git merge --verify-signatures`  
`gp`: `git push`  
`gpA`: `git push --all && git push --tags --no-verify`  
`gpF`: `git push --force`  
`gpa`: `git push --all`  
`gpc`: `git push --set-upstream origin $(git-branch-current 2>/dev/null)`  
`gpf`: `git push --force-with-lease`  
`gpp`: `git pull origin $(git-branch-current 2>/dev/null) && git push origin $(git-branch-current 2>/dev/null)`  
`gpt`: `git push --tags`  
`gr`: `git rebase`  
`grS`: `git rebase --exec git commit --amend --no-edit --no-verify -S`  
`gra`: `git rebase --abort`  
`grc`: `git rebase --continue`  
`grep`: `grep --color=auto`  
`gri`: `git rebase --interactive --autosquash`  
`grs`: `git rebase --skip`  
`gs`: `git stash`  
`gsS`: `git stash save --patch --no-keep-index`  
`gsX`: `git-stash-clear-interactive`  
`gsa`: `git stash apply`  
`gsd`: `git stash show --patch --stat`  
`gsi`: `git stash push --staged`  
`gsl`: `git stash list`  
`gsp`: `git stash pop`  
`gsr`: `git-stash-recover`  
`gss`: `git stash save --include-untracked`  
`gsu`: `git stash show --patch | git apply --reverse`  
`gsw`: `git stash save --include-untracked --keep-index`  
`gsx`: `git stash drop`  
`gt`: `git tag`  
`gtl`: `git tag --list --sort=-committerdate`  
`gts`: `git tag --sign`  
`gtv`: `git verify-tag`  
`gtx`: `git tag --delete`  
`gwC`: `git clean -d --force`  
`gwD`: `git diff --no-ext-diff --word-diff`  
`gwM`: `git mv -f`  
`gwR`: `git reset --hard`  
`gwS`: `git status`  
`gwX`: `git rm -rf`  
`gwc`: `git clean --dry-run`  
`gwd`: `git diff --no-ext-diff`  
`gwm`: `git mv`  
`gwr`: `git reset --soft`  
`gws`: `git status --short --branch`  
`gwx`: `git rm -r`  
`gy`: `git switch`  
`gyc`: `git switch --create`  
`gyd`: `git switch --detach`  
`k`: `kubectl`  
`kaf`: `kubectl apply -f`  
`kc`: `kubectl`  
`kcc`: `kubectl config get-contexts`  
`kcf`: `kubectl create -f`  
`kcl`: `kubectl logs`  
`kctx`: `kubectx`  
`kd`: `kubectl delete`  
`kdc`: `kubectl delete cronjobs`  
`kdcm`: `kubectl delete configmaps`  
`kdd`: `kubectl delete deployment`  
`kdds`: `kubectl delete daemonsets`  
`kdf`: `kubectl delete -f`  
`kdi`: `kubectl delete ingress`  
`kdj`: `kubectl delete job`  
`kdns`: `kubectl delete namespaces`  
`kdp`: `kubectl delete pod`  
`kdpv`: `kubectl delete persistentvolumes`  
`kdpvc`: `kubectl delete persistentvolumeclaims`  
`kds`: `kubectl delete services`  
`kdsc`: `kubectl describe cronjobs`  
`kdscm`: `kubectl describe configmaps`  
`kdsd`: `kubectl describe deployments`  
`kdsds`: `kubectl describe daemonsets`  
`kdsf`: `kubectl describe -f`  
`kdsi`: `kubectl describe ingress`  
`kdsj`: `kubectl describe jobs`  
`kdsn`: `kubectl describe nodes`  
`kdsns`: `kubectl describe namespaces`  
`kdsp`: `kubectl describe pods`  
`kdspv`: `kubectl describe persistentvolumes`  
`kdspvc`: `kubectl describe persistentvolumeclaims`  
`kdss`: `kubectl describe services`  
`kdssc`: `kubectl describe secrets`  
`ke`: `kubectl edit`  
`kec`: `kubectl edit cronjobs`  
`kecm`: `kubectl edit configmaps`  
`ked`: `kubectl edit deployments`  
`keds`: `kubectl edit daemonsets`  
`kef`: `kubectl edit -f`  
`kei`: `kubectl edit ingress`  
`keit`: `kubectl exec -it --`  
`kej`: `kubectl edit jobs`  
`ken`: `kubectl edit nodes`  
`kens`: `kubectl edit namespaces`  
`kep`: `kubectl edit pods`  
`kepv`: `kubectl edit persistentvolumes`  
`kepvc`: `kubectl edit persistentvolumeclaims`  
`kes`: `kubectl edit services`  
`kesc`: `kubectl edit secrets`  
`kg`: `kubectl get`  
`kga`: `kubectl get --all-namespaces`  
`kgac`: `get_cluster_resources cronjobs`  
`kgacm`: `get_cluster_resources configmaps`  
`kgads`: `get_cluster_resources daemonsets`  
`kgai`: `get_cluster_resources ingress`  
`kgaj`: `get_cluster_resources jobs`  
`kgap`: `get_cluster_resources pods`  
`kgapvc`: `get_cluster_resources persistentvolumeclaims`  
`kgas`: `get_cluster_resources services`  
`kgasc`: `get_cluster_resources secrets`  
`kgc`: `kubectl get cronjobs`  
`kgcm`: `kubectl get configmaps`  
`kgcmy`: `kubectl get configmaps -o yaml`  
`kgcr`: `kubectl get clusterroles`  
`kgcrb`: `kubectl get clusterrolebindings`  
`kgcrd`: `kubectl get customresourcedefinition`  
`kgcrv`: `kubectl get controllerrevisions`  
`kgcs`: `kubectl get componentstatus`  
`kgcsr`: `kubectl get certificatesigningrequests`  
`kgcw`: `watch kubectl get cronjobs`  
`kgcy`: `kubectl get cronjobs -o yaml`  
`kgd`: `kubectl get deployments`  
`kgds`: `kubectl get daemonsets`  
`kgdsw`: `watch kubectl get daemonsets`  
`kgdsy`: `kubectl get daemonsets -o yaml`  
`kgdw`: `watch kubectl get deployments`  
`kgdy`: `kubectl get deployments -o yaml`  
`kgep`: `kubectl get endpoints`  
`kgev`: `kubectl get events`  
`kgf`: `kubectl get -f`  
`kghpa`: `kubectl get horizontalpodautoscalers`  
`kgi`: `kubectl get ingress`  
`kgiy`: `kubectl get ingress -o yaml`  
`kgj`: `kubectl get jobs`  
`kgjw`: `watch kubectl get jobs`  
`kgjy`: `kubectl get jobs -o yaml`  
`kglr`: `kubectl get limitranges`  
`kgn`: `kubectl get nodes`  
`kgnp`: `kubectl get networkpolicies`  
`kgns`: `kubectl get namespaces`  
`kgnsy`: `kubectl get namespaces -o yaml`  
`kgny`: `kubectl get nodes -o yaml`  
`kgp`: `kubectl get pods`  
`kgpdb`: `kubectl get poddisruptionbudgets`  
`kgpp`: `kubectl get podpreset`  
`kgpv`: `kubectl get persistentvolumes`  
`kgpvc`: `kubectl get persistentvolumeclaims`  
`kgpvcy`: `kubectl get persistentvolumeclaims -o yaml`  
`kgpvy`: `kubectl get persistentvolumes -o yaml`  
`kgpw`: `watch kubectl get pods`  
`kgpy`: `kubectl get pods -o yaml`  
`kgr`: `kubectl get roles`  
`kgrb`: `kubectl get rolebindings`  
`kgrc`: `kubectl get replicationcontrollers`  
`kgrq`: `kubectl get resourcequotas`  
`kgs`: `kubectl get services`  
`kgsa`: `kubectl get serviceaccounts`  
`kgsc`: `kubectl get secrets`  
`kgscy`: `kubectl get secrets -o yaml`  
`kgss`: `kubectl get statefulsets`  
`kgsy`: `kubectl get services -o yaml`  
`kl`: `kubectl logs`  
`klf`: `kubectl logs -f`  
`kns`: `kubens`  
`kpsp`: `kubectl get podsecuritypolicies`  
`kpt`: `kubectl get podtemplates`  
`krs`: `kubectl get replicasets`  
`ktn`: `kubectl top nodes`  
`ktp`: `kubectl top pods`  
`kube`: `kubectl`  
`l`: `ll -A`  
`lc`: `lt -c`  
`lk`: `ll -Sr`  
`ll`: `ls -lh`  
`lm`: `l | less`  
`lr`: `ll -R`  
`ls`: `ls --group-directories-first --color=auto`  
`lt`: `ll -tr`  
`lx`: `ll -X`  
`nvimf`: `nvim -c FzfLua files`  
`nviml`: `nvim --listen /tmp/nvim.pipe`  
`pac`: `yay -Rns $(yay -Qtdq)`  
`pai`: `yay -Sy`  
`paii`: `yay -Sy --noconfirm`  
`pam`: `rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist`  
`pan`: `yay -Qqd | yay -Rsu --print -`  
`par`: `yay -Rnsu`  
`parr`: `yay -Rnsu --noconfirm`  
`pau`: `yay -Syu`  
`pauu`: `yay -Syu --noconfirm`  
`reset`: `command reset   && [ -f /home/deathbeam/.config/tinted-theming/base16_shell_theme ]   && . /home/deathbeam/.config/tinted-theming/base16_shell_theme`  
`run-help`: `man`  
`s`: `fasd -si`  
`sd`: `fasd -sid`  
`sf`: `fasd -sif`  
`v`: `f -e vim -b viminfo`  
`vim`: `nvim`  
`vimdiff`: `nvim -d`  
`vimf`: `nvimf`  
`viml`: `nviml`  
`which-command`: `whence`  
`z`: `fasd_cd -d`  
`zz`: `fasd_cd -d -i`  
`ast-highlight-main-type`: function  

## Tmux Keybindings
`%`: split-window `-v -c #{pane_current_path}`  
`&`: kill-window  
`'"'`: split-window `-h -c #{pane_current_path}`  
`C-space`: send-prefix  
`C`: new-session `-c #{pane_current_path}`  
`Escape` (copy-mode-vi): send-keys -X cancel  
`M-Enter`: if-shell `[ $(($(tmux display -p 8*#{pane_width}-20*#{pane_height}))) -lt 0 ] splitw -v -c #{pane_current_path} splitw -h -c #{pane_current_path}`  
`X`: kill-session  
`c`: new-window `-c #{pane_current_path}`  
`s`: run-shell `-b $HOME/.tmux/switch-session.sh`  
`v` (copy-mode-vi): send-keys -X begin-selection  
`v`: capture-pane `-S - \; save-buffer /tmp/tmux_buffer.txt \; split-window nvim + normal G\$?. /tmp/tmux_buffer.txt && rm /tmp/tmux_buffer.txt`  
`x`: kill-pane  
`y` (copy-mode-vi): send-keys -X copy-selection-and-cancel  

## Hyprland Keybindings
`Print`: exec `sleep 1 && grim -t ppm - | satty -f - -o "$HOME/Pictures/Screenshots/%Y-%m-%d_%H:%M:%S.png"`  
`Return`: submap `reset`  
`SUPER+1`: workspace `1`  
`SUPER+2`: workspace `2`  
`SUPER+3`: workspace `3`  
`SUPER+4`: workspace `4`  
`SUPER+5`: workspace `5`  
`SUPER+6`: workspace `6`  
`SUPER+7`: workspace `7`  
`SUPER+8`: workspace `8`  
`SUPER+9`: workspace `9`  
`SUPER+F`: fullscreen `0`  
`SUPER+H`: movefocus `l`  
`SUPER+J`: movefocus `d`  
`SUPER+K`: movefocus `u`  
`SUPER+L`: movefocus `r`  
`SUPER+M`: fullscreen `1`  
`SUPER+Print`: exec `screenrecorder`  
`SUPER+R`: submap `resize`  
`SUPER+Return`: exec `terminal`  
`SUPER+S`: togglefloating  
`SUPER+Tab`: exec `switchmenu -p "switch"`  
`SUPER+W`: killactive  
`SUPER+c`: exec `clipmenu -p "clip"`  
`SUPER+e`: exec `swaylock -f -i $WALLPAPER`  
`SUPER+escape`: exec `hyprctl reload`  
`SUPER+g`: exec `pkill -USR1 gammastep`  
`SUPER+grave`: togglespecialworkspace  
`SUPER+n`: exec `notificationsmenu -p "notifications"`  
`SUPER+space`: exec `runmenu -p "run"`  
`SUPER+v`: exec `steammenu -p "steam"`  
`SUPER+x`: exec `procmenu -p "proc"`  
`SUPER+z`: exec `passmenu -p "pass"`  
`SUPER_SHIFT+1`: movetoworkspace `1`  
`SUPER_SHIFT+2`: movetoworkspace `2`  
`SUPER_SHIFT+3`: movetoworkspace `3`  
`SUPER_SHIFT+4`: movetoworkspace `4`  
`SUPER_SHIFT+5`: movetoworkspace `5`  
`SUPER_SHIFT+6`: movetoworkspace `6`  
`SUPER_SHIFT+7`: movetoworkspace `7`  
`SUPER_SHIFT+8`: movetoworkspace `8`  
`SUPER_SHIFT+9`: movetoworkspace `9`  
`SUPER_SHIFT+H`: movewindow `l`  
`SUPER_SHIFT+J`: movewindow `d`  
`SUPER_SHIFT+K`: movewindow `u`  
`SUPER_SHIFT+L`: movewindow `r`  
`SUPER_SHIFT+escape`: exit  
`SUPER_SHIFT+grave`: movetoworkspace `special`  
`XF86AudioLowerVolume`: exec `amixer -q set Master 5%-`  
`XF86AudioMicMute`: exec `amixer -q set Capture toggle`  
`XF86AudioMute`: exec `amixer -q set Master toggle`  
`XF86AudioRaiseVolume`: exec `amixer -q set Master 5%+ on`  
`XF86KbdBrightnessDown`: exec `asusctl -p`  
`XF86KbdBrightnessUp`: exec `asusctl -n`  
`XF86Launch1`: exec `rog-control-center`  
`XF86Launch3`: exec `asusctl led-mode -n`  
`XF86Launch4`: exec `asusctl profile -p`  
`XF86MonBrightnessDown`: exec `brightnessctl s 5%-`  
`XF86MonBrightnessUp`: exec `brightnessctl s +5%`  
`escape`: submap `reset`  

## Neovim <leader> Keybindings
**nv** `<Space>ad`: AI Documentation  
**nv** `<Space>ae`: AI Explain  
**nv** `<Space>af`: AI Fix  
**nv** `<Space>ac`: AI Generate Commit  
**n** `<Space>am`: AI Models  
**v** `<Space>aa`: AI Open  
**nv** `<Space>ao`: AI Optimize  
**nv** `<Space>ap`: AI Prompts  
**nv** `<Space>aq`: AI Question  
**n** `<Space>ax`: AI Reset  
**nv** `<Space>ar`: AI Review  
**n** `<Space>as`: AI Stop  
**nv** `<Space>at`: AI Tests  
**n** `<Space>aa`: AI Toggle  
**n** `<Space>mD`: Bookmarks Delete All  
**n** `<Space>md`: Bookmarks Delete Buffer  
**n** `<Space>mq`: Bookmarks Quickfix  
**n** `<Space>mm`: Bookmarks Select  
**n** `<Space>dp`: Breakpoints  
**n** `<Space>db`: Debug Breakpoint  
**n** `<Space>dB`: Debug Conditional Breakpoint  
**n** `<Space>dc`: Debug Console  
**n** `<Space>dd`: Debug Continue [R]  
**n** `<Space>dx`: Debug Exit  
**nv** `<Space>de`: Debug Expression  
**n** `<Space>df`: Debug Frames  
**n** `<Space>dL`: Debug Log Point  
**n** `<Space>d<Space>`: Debug REPL  
**n** `<Space>dr`: Debug Restart  
**n** `<Space>ds`: Debug Scopes  
**n** `<Space>dk`: Debug Step Back (up) [R]  
**n** `<Space>dl`: Debug Step Into (right) [R]  
**n** `<Space>dh`: Debug Step Out (left) [R]  
**n** `<Space>dj`: Debug Step Over (down) [R]  
**n** `<Space>dt`: Debug Threads  
**n** `<Space>fa`: Find Actions  
**n** `<Space>fD`: Find All Diagnostics  
**n** `<Space>fC`: Find All Git Commits  
**n** `<Space>fS`: Find All Symbols  
**nv** `<Space>fc`: Find Buffer Git Commits  
**v** `<Space>fc`: Find Buffer Git Commits No mapping found  
**n** `<Space>fb`: Find Buffers  
**n** `<Space>fd`: Find Diagnostics  
**n** `<Space>ff`: Find Files  
**n** `<Space>fF`: Find Git Files  
**n** `<Space>fG`: Find Git Grep  
**n** `<Space>fg`: Find Grep  
**n** `<Space>f?`: Find Help  
**n** `<Space>fh`: Find History  
**n** `<Space>fj`: Find Jumps  
**n** `<Space>fk`: Find Keymaps  
**n** `<Space>fm`: Find Marks  
**n** `<Space>fq`: Find Quickfix  
**n** `<Space><Space>`: Find Resume  
**n** `<Space>fs`: Find Symbols  
**n** `<Space>fu`: Find Undo History  
**n** `<Space>he`: HTTP Environment  
**n** `<Space>hh`: HTTP Run  
**n** `<Space>hH`: HTTP Run All  
**n** `<Space>ho`: HTTP Toggle  
**n** `<Space>wd`: Wiki Diary List  
**n** `<Space>ww`: Wiki List  
**n** `<Space>wn`: Wiki New  
**n** `<Space>wt`: Wiki Today  
**n** `<Space>z`: Zoom  

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

