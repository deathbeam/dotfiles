log "Enabling multilib repository"
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i "/^#\[multilib\]/,/^#Include/ s/^#//" /etc/pacman.conf
fi

log "Installing core packages"
packages=(
    xdg-utils xdg-user-dirs xdg-terminal-exec # xdg tools
    dosfstools fuse2 gdu # filesystem tools
    stoken openvpn vpn-slice openconnect tinyproxy mitmproxy # VPN/proxy tools
    stow zsh starship tmux # shell tools
    ripgrep mlocate man-db tldr # man/search tools
    net-tools systemd-resolvconf iw sshpass wget socat traceroute aria2c # network tools/downloaders
    bc unzip p7zip # archive tools
    rate-mirrors pacman-contrib arch-update # arch tools
    pass pass-otp # password manager
    power-profiles-daemon # power management
    keyd # keyboard remapping daemon
    syncthing # file synchronization
    tree-sitter-git tree-sitter-cli-git neovim-git fswatch ctags less bat lynx # neovim/text stuff
    jq yq jnv # json/yaml processors
    btop # system monitor
    glow # markdown viewer
    fastfetch # system information
    witr-bin # why is this running
    cloudflare-warp-bin # cloudflare warp client
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
    warp-svc
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

# Enable warp
yes | warp-cli registration new
warp-cli connect

# Modify groups
groups=(
    # nogroup
    # video
    # input
    keyd
)
enable_groups "${groups[@]}"

# Update XDG
xdg-user-dirs-update

# Disable power save
sudo iw dev wlan0 set power_save off

# Change default shell
chsh -s /bin/zsh "$USER"
