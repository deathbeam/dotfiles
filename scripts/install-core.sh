log "Enabling multilib repository"
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i "/^#\[multilib\]/,/^#Include/ s/^#//" /etc/pacman.conf
fi

log "Installing core packages"
packages=(
    xdg-utils xdg-user-dirs
    net-tools iw sshpass stoken openvpn vpn-slice openconnect tinyproxy mitmproxy wget lynx socat traceroute
    dosfstools fuse2
    stow zsh tmux ripgrep mlocate starship tldr
    tree-sitter-git neovim-git ctags less bat fswatch jq jnv
    pass pass-otp
    rate-mirrors unzip bc
    p7zip man-db keyd systemd-resolvconf pacman-contrib ncdu
    fastfetch onefetch glow
    power-profiles-daemon syncthing
)
install_pkgs "${packages[@]}"

log "Configuring system"

# Increase inotify watches
append_config "fs.inotify.max_user_watches=1000000" /etc/sysctl.d/40-inotify.conf
append_config "fs.inotify.max_queued_events=1000000" /etc/sysctl.d/40-inotify.conf

# Symlink configs
sudo ln -sf ${dot_dir}/keyd/default.conf /etc/keyd/default.conf

# Enable services
services=(
    keyd
    power-profiles-daemon
)
enable_services "${services[@]}"

services=(
    syncthing
)
enable_user_services "${services[@]}"

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
    nogroup
    video
    input
    keyd
)
enable_groups "${groups[@]}"

# Update XDG
xdg-user-dirs-update

# Disable power save
sudo iw dev wlan0 set power_save off

# Change default shell
chsh -s /bin/zsh "$USER"
