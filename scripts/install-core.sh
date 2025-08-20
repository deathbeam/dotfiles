log "Installing AUR helper"
git clone "https://aur.archlinux.org/yay.git" "/tmp/yay"
cd "/tmp/yay"
makepkg -si --noconfirm
cd -

log "Enabling multilib repository"
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i "/^#\[multilib\]/,/^#Include/ s/^#//" /etc/pacman.conf
fi

log "Installing extra packages"
packages=(
    xdg-utils xdg-user-dirs
    net-tools iw sshpass stoken openvpn vpn-slice openconnect tinyproxy mitmproxy wget lynx socat traceroute
    dosfstools fuse2
    alsa-utils vulkan-tools libva-utils
    stow zsh tmux ripgrep mlocate starship tldr
    tree-sitter-git neovim-git python-pynvim ctags less bat fswatch jq jnv
    pass pass-otp
    rate-mirrors unzip bc
    p7zip man-db keyd fastfetch onefetch systemd-resolvconf pacman-contrib ncdu
    brightnessctl power-profiles-daemon syncthing
)
install_pkgs "${packages[@]}"

log "Installing development packages"
packages=(
    jdk8-openjdk openjdk8-doc openjdk8-src
    jdk-openjdk openjdk-doc openjdk-src
    python-pip python-dbus python-opengl python-virtualenv
    dotnet-sdk aspnet-runtime
    maven npm asdf-vm python-poetry
    github-cli
    docker docker-compose
    azure-cli kubectl k9s argocd azure-kubelogin temporal-cli
    ollama
)
install_pkgs "${packages[@]}"

log "Installing python packages"
packages=(
    https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip
)
install_python_pkgs "${packages[@]}"

log "Installing npm packages"
packages=(
    httpyac
)
instal_npm_pkgs "${packages[@]}"

log "Installing desktop packages"
packages=(
    fonts-meta-base
    terminus-font terminus-font-ttf ttf-terminus-nerd
    udiskie
    gammastep geoclue2
    dunst
    yambar-git
    alacritty
    gcr
    zathura zathura-pdf-mupdf
    qutebrowser python-adblock
    firefox firefox-tridactyl firefox-tridactyl-native
    gimp
    mpv subliminal yt-dlp
    vesktop-bin stremio
    gamescope steam steamtinkerlaunch lutris
    calibre
    youtube-music-bin
    gpu-screen-recorder-git
    jamesdsp
)
install_pkgs "${packages[@]}"

log "Installing asdf plugins"
asdf plugin add protonge

log "Configuring system"

# Add steamtinkerlaunch compat
steamtinkerlaunch compat add

# Enable bitmap fonts (we need them to correctly render Terminus)
if [ -f "/etc/fonts/conf.d/70-no-bitmaps.conf" ]; then
    sudo rm -f /etc/fonts/conf.d/70-no-bitmaps.conf
    fc-cache -f
fi

# Increase inotify watches
append_config "fs.inotify.max_user_watches=1000000" /etc/sysctl.d/40-inotify.conf
append_config "fs.inotify.max_queued_events=1000000" /etc/sysctl.d/40-inotify.conf

# Symlink configs
[ -f "/etc/keyd/default.conf" ] || sudo ln -sf ~/git/dotfiles/keyd/default.conf /etc/keyd/default.conf

# Enable services
services=(
    keyd
    docker
    power-profiles-daemon
)
enable_services "${services[@]}"

systemctl enable --user syncthing

# Alter pacman options
append_pacman_option "Color"
append_pacman_option "ILoveCandy"
append_pacman_option "ParallelDownloads = 10"

# Modify systemd-networkd-wait-online.service to use --any parameter instead of waiting for all interfaces
if grep -q "ExecStart=/usr/lib/systemd/systemd-networkd-wait-online$" /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service; then
    sudo sed -i 's|ExecStart=/usr/lib/systemd/systemd-networkd-wait-online|ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any|' /etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service
fi

# Modify groups
groups=(
    vboxsf
    docker
    nogroup
    video
    input
    keyd
)
enable_groups "${groups[@]}"

# Update XDG
xdg-user-dirs-update

# Set default browser
xdg-settings set default-web-browser qutebrowser.desktop

# Change default shell
chsh -s /bin/zsh "$USER"

# Disable power save
sudo iw dev wlan0 set power_save off
