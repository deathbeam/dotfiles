# System Cheatsheet

## Zsh Aliases & Functions
()(): function  
gc: git commit --signoff --verbose  
gcA: git commit --signoff --verbose --patch  
gca: git commit --signoff --verbose --all  
gcm: git commit --signoff --message  
nvimf: nvim -c "FzfLua files  
nviml: nvim --listen /tmp/nvim.pipe  
pac: yay -Rns $(yay -Qtdq)  
pai: yay -Sy  
paii: yay -Sy --noconfirm  
pam: rate-mirrors arch | sudo tee /etc/pacman.d/mirrorlist  
pan: yay -Qqd | yay -Rsu --print -  
par: yay -Rnsu  
parr: yay -Rnsu --noconfirm  
pau: yay -Syu  
pauu: yay -Syu --noconfirm  
recent_files()(): function  
setproxy(): function  
unsetproxy(): function  
vcopy(): function  
vim: nvim  
vimdiff: nvim -d  
vimf: nvimf  
viml: nviml  
vpaste(): function  

## Tmux Keybindings
%: split window  
&: kill-window  
'"': split window  
C-space: send-prefix  
C: new-session -c "#{pane_current_path}"  
X: kill-session  
c: new window  
s: run shell command  
v: capture-pane -S - \; save-buffer /tmp/tm...  
x: kill-pane  

## Hyprland Keybindings
⊞+1: go to workspace 1  
⊞+2: go to workspace 2  
⊞+3: go to workspace 3  
⊞+4: go to workspace 4  
⊞+5: go to workspace 5  
⊞+6: go to workspace 6  
⊞+7: go to workspace 7  
⊞+8: go to workspace 8  
⊞+9: go to workspace 9  
⊞+F: fullscreen 0  
⊞+H: movefocus l  
⊞+J: movefocus d  
⊞+K: movefocus u  
⊞+L: movefocus r  
⊞+M: fullscreen 1  
⊞+Print: run screenrecorder  
⊞+R: submap resize  
⊞+Return: run terminal  
⊞+S: togglefloating  
⊞+Tab: run switchmenu -p "switch"  
⊞+W: killactive  
⊞+c: run clipmenu -p "clip"  
⊞+e: run swaylock -f -i $WALLPAPER  
⊞+escape: run hyprctl reload  
⊞+g: run pkill -USR1 gammastep  
⊞+grave: togglespecialworkspace  
⊞+n: run notificationsmenu -p "notifications"  
⊞+space: run runmenu -p "run"  
⊞+v: run steammenu -p "steam"  
⊞+x: run procmenu -p "proc"  
⊞+z: run passmenu -p "pass"  
⊞+⇧+1: move to workspace 1  
⊞+⇧+2: move to workspace 2  
⊞+⇧+3: move to workspace 3  
⊞+⇧+4: move to workspace 4  
⊞+⇧+5: move to workspace 5  
⊞+⇧+6: move to workspace 6  
⊞+⇧+7: move to workspace 7  
⊞+⇧+8: move to workspace 8  
⊞+⇧+9: move to workspace 9  
⊞+⇧+H: movewindow l  
⊞+⇧+J: movewindow d  
⊞+⇧+K: movewindow u  
⊞+⇧+L: movewindow r  
⊞+⇧+escape: exit   
⊞+⇧+grave: move to workspace special  

## Neovim <leader> Keybindings
nv <Space>ad: AI Documentation  
nv <Space>ae: AI Explain  
nv <Space>af: AI Fix  
nv <Space>ac: AI Generate Commit  
n <Space>am: AI Models  
v <Space>aa: AI Open  
nv <Space>ao: AI Optimize  
nv <Space>ap: AI Prompts  
nv <Space>aq: AI Question  
n <Space>ax: AI Reset  
nv <Space>ar: AI Review  
n <Space>as: AI Stop  
nv <Space>at: AI Tests  
n <Space>aa: AI Toggle  
n <Space>mD: Bookmarks Delete All  
n <Space>md: Bookmarks Delete Buffer  
n <Space>mq: Bookmarks Quickfix  
n <Space>mm: Bookmarks Select  
n <Space>dp: Breakpoints  
n <Space>db: Debug Breakpoint  
n <Space>dB: Debug Conditional Breakpoint  
n <Space>dc: Debug Console  
n <Space>dd: Debug Continue [R]  
n <Space>dx: Debug Exit  
nv <Space>de: Debug Expression  
n <Space>df: Debug Frames  
n <Space>dL: Debug Log Point  
n <Space>d<Space>: Debug REPL  
n <Space>dr: Debug Restart  
n <Space>ds: Debug Scopes  
n <Space>dk: Debug Step Back (up) [R]  
n <Space>dl: Debug Step Into (right) [R]  
n <Space>dh: Debug Step Out (left) [R]  
n <Space>dj: Debug Step Over (down) [R]  
n <Space>dt: Debug Threads  
n <Space>fa: Find Actions  
n <Space>fD: Find All Diagnostics  
n <Space>fC: Find All Git Commits  
n <Space>fS: Find All Symbols  
nv <Space>fc: Find Buffer Git Commits  
v <Space>fc: Find Buffer Git Commits No mapping found  
n <Space>fb: Find Buffers  
n <Space>fd: Find Diagnostics  
n <Space>ff: Find Files  
n <Space>fF: Find Git Files  
n <Space>fG: Find Git Grep  
n <Space>fg: Find Grep  
n <Space>f?: Find Help  
n <Space>fh: Find History  
n <Space>fj: Find Jumps  
n <Space>fk: Find Keymaps  
n <Space>fm: Find Marks  
n <Space>fq: Find Quickfix  
n <Space><Space>: Find Resume  
n <Space>fs: Find Symbols  
n <Space>fu: Find Undo History  
n <Space>he: HTTP Environment  
n <Space>hh: HTTP Run  
n <Space>hH: HTTP Run All  
n <Space>ho: HTTP Toggle  
n <Space>wd: Wiki Diary List  
n <Space>ww: Wiki List  
n <Space>wn: Wiki New  
n <Space>wt: Wiki Today  
n <Space>z: Zoom  

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

