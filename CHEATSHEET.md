# Hyprland Keybindings
| Key | Action |
|-----|--------|
| `SUPER+Return` | __lua `5` |
| `SUPER+Tab` | __lua `7` |
| `SUPER+space` | __lua `9` |
| `SUPER+p` | __lua `11` |
| `SUPER+x` | __lua `13` |
| `SUPER+c` | __lua `15` |
| `SUPER+g` | __lua `17` |
| `SUPER+i` | __lua `19` |
| `SUPER+n` | __lua `21` |
| `SUPER+u` | __lua `23` |
| `SUPER+e` | __lua `25` |
| `SUPER+v` | __lua `27` |
| `SUPER+slash` | __lua `29` |
| `SUPER+b` | __lua `31` |
| `SUPER+d` | __lua `33` |
| `SUPER+y` | __lua `35` |
| `SUPER+o` | __lua `37` |
| `SUPER+SHIFT+o` | __lua `39` |
| `SUPER+a` | __lua `41` |
| `SUPER+z` | __lua `43` |
| `SUPER+Left` | __lua `45` |
| `SUPER+Right` | __lua `47` |
| `SUPER+SHIFT+z` | __lua `49` |
| `switch:Lid Switch` | __lua `51` |
| `Print` | __lua `53` |
| `SUPER+Print` | __lua `55` |
| `XF86AudioRaiseVolume` | __lua `57` |
| `XF86AudioLowerVolume` | __lua `59` |
| `XF86AudioMute` | __lua `61` |
| `XF86AudioMicMute` | __lua `63` |
| `XF86MonBrightnessUp` | __lua `65` |
| `XF86MonBrightnessDown` | __lua `67` |
| `XF86KbdBrightnessUp` | __lua `69` |
| `XF86KbdBrightnessDown` | __lua `71` |
| `XF86Launch1` | __lua `73` |
| `XF86Launch3` | __lua `75` |
| `XF86Launch4` | __lua `77` |
| `SUPER+SHIFT+escape` | __lua `79` |
| `SUPER+escape` | __lua `81` |
| `SUPER+W` | __lua `83` |
| `SUPER+S` | __lua `85` |
| `SUPER+M` | __lua `87` |
| `SUPER+F` | __lua `89` |
| `SUPER+T` | __lua `91` |
| `SUPER+H` | __lua `93` |
| `SUPER+L` | __lua `95` |
| `SUPER+K` | __lua `97` |
| `SUPER+J` | __lua `99` |
| `SUPER+SHIFT+H` | __lua `101` |
| `SUPER+SHIFT+L` | __lua `103` |
| `SUPER+SHIFT+K` | __lua `105` |
| `SUPER+SHIFT+J` | __lua `107` |
| `SUPER+R` | __lua `109` |
| `SUPER+1` | __lua `131` |
| `SUPER+2` | __lua `133` |
| `SUPER+3` | __lua `135` |
| `SUPER+4` | __lua `137` |
| `SUPER+5` | __lua `139` |
| `SUPER+6` | __lua `141` |
| `SUPER+7` | __lua `143` |
| `SUPER+8` | __lua `145` |
| `SUPER+9` | __lua `147` |
| `SUPER+grave` | __lua `149` |
| `SUPER+SHIFT+1` | __lua `151` |
| `SUPER+SHIFT+2` | __lua `153` |
| `SUPER+SHIFT+3` | __lua `155` |
| `SUPER+SHIFT+4` | __lua `157` |
| `SUPER+SHIFT+5` | __lua `159` |
| `SUPER+SHIFT+6` | __lua `161` |
| `SUPER+SHIFT+7` | __lua `163` |
| `SUPER+SHIFT+8` | __lua `165` |
| `SUPER+SHIFT+9` | __lua `167` |
| `SUPER+SHIFT+grave` | __lua `169` |
| `SUPER+mouse:272` | __lua `171` |
| `SUPER+mouse:273` | __lua `173` |

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
| n | `<Space>ac` | AI Commit |
| n | `<Space>adc` | AI Debug Catalog |
| n | `<Space>ade` | AI Debug Events |
| n | `<Space>adp` | AI Debug Prompt |
| n | `<Space>adt` | AI Debug Test |
| n | `<Space>am` | AI Models |
| n | `<Space>ax` | AI Reset |
| n | `<Space>as` | AI Stop |
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
| alias | `slop` | `sandbox nvim -c \lua require(slopcode).open({layout=replace})\`
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

- Only search the files matching the glob pattern(s) (e.g. `README.*`, use `!filename_pattern` to exclude instead):

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

