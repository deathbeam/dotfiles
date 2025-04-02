#!/usr/bin/bash -l
set -ex
shopt -s nullglob globstar

# Prepare git dir
mkdir -p ~/git
cd ~/git

# Install AUR helper
echo '==> Installing AUR helper'
if ! command -v yay &> /dev/null; then
    sudo pacman --noconfirm --needed -S git git-lfs
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
fi

# Enable multilib repository
if ! grep -q '^\[multilib\]' /etc/pacman.conf; then
    sudo sed -i "/^#\[multilib\]/,/^#Include/ s/^#//" /etc/pacman.conf
    sudo pacman -Sy
fi

# mkinitcpio-firmware \ is broken
echo '==> Installing extra packages'
yay -S --noconfirm --mflags --skipinteg \
    net-tools dosfstools \
    xdg-utils xdg-user-dirs \
    alsa-utils \
    iw \
    stow zsh tmux ripgrep mlocate btop \
    tree-sitter-git neovim-git ctags less bat fswatch \
    pass pass-otp \
    sshpass stoken openvpn vpn-slice openconnect tinyproxy mitmproxy wget jq jnv-bin \
    tlp rate-mirrors unzip fuse2 bc brightnessctl \
    p7zip man-db keyd fastfetch onefetch socat systemd-resolvconf pacman-contrib ncdu

echo '==> Installing development packages'
yay -S --noconfirm --mflags --skipinteg \
    jdk8-openjdk openjdk8-doc openjdk8-src \
    jdk-openjdk openjdk-doc openjdk-src \
    python-pip python-dbus python-opengl python-virtualenv \
    dotnet-sdk aspnet-runtime \
    maven npm asdf-vm \
    github-cli lazygit \
    docker docker-compose \
    azure-cli kubectl k9s argocd \
    ollama \
    mitmproxy

echo '==> Installing python packages'
pip3 install --user --break-system-packages https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip

echo '==> Installing npm packages'
mkdir -p ~/.npm-global
npm config set prefix "$HOME/.npm-global"
npm install -g httpyac

echo '==> Installing desktop packages'
yay -S --noconfirm --mflags --skipinteg \
    fonts-meta-base \
    terminus-font terminus-font-ttf ttf-terminus-nerd \
    udiskie \
    gammastep geoclue2 \
    dunst \
    yambar-git \
    alacritty \
    zathura zathura-pdf-mupdf \
    qutebrowser python-adblock \
    mpv yt-dlp \
    dropbox dropbox-cli vesktop-bin stremio steam calibre \
    stalonetray xdotool \
    gpu-screen-recorder-git

echo '==> Installing dotfiles'
git clone https://github.com/deathbeam/dotfiles || true
cd dotfiles
make

echo '==> Configuring system'

# Enable bitmap fonts (we need them to correctly render Terminus)
if [ -f "/etc/fonts/conf.d/70-no-bitmaps.conf" ]; then
    sudo rm -f /etc/fonts/conf.d/70-no-bitmaps.conf
    fc-cache -f
fi

# Increase inotify watches
if ! grep -q "fs.inotify.max_user_watches" /etc/sysctl.d/40-inotify.conf 2>/dev/null; then
    sudo tee -a /etc/sysctl.d/40-inotify.conf <<EOF
fs.inotify.max_user_watches=1000000
fs.inotify.max_queued_events=1000000
EOF
fi

# Symlink configs
[ -f "/etc/keyd/default.conf" ] || sudo ln -sf ~/git/dotfiles/keyd/default.conf /etc/keyd/default.conf

# Enable services
sudo systemctl enable \
    keyd \
    tlp \
    docker

# Alter pacman options
grep -q "^Color" /etc/pacman.conf || sudo sed -i '/\[options\]/a Color' /etc/pacman.conf
grep -q "^ILoveCandy" /etc/pacman.conf || sudo sed -i '/\[options\]/a ILoveCandy' /etc/pacman.conf
grep -q "^ParallelDownloads = 10" /etc/pacman.conf || sudo sed -i '/\[options\]/a ParallelDownloads = 10' /etc/pacman.conf

# Modify groups
sudo groupadd -f vboxsf
sudo usermod -aG vboxsf "$USER"
sudo groupadd -f docker
sudo usermod -aG docker "$USER"
sudo groupadd -f nogroup
sudo usermod -aG nogroup "$USER"
sudo groupadd -f video
sudo usermod -aG video "$USER"
sudo groupadd -f input
sudo usermod -aG input "$USER"

# Update XDG
xdg-user-dirs-update

# Set default browser
xdg-settings set default-web-browser qutebrowser.desktop

# Change default shell
chsh -s /bin/zsh "$USER"

# Disable power save
sudo iw dev wlan0 set power_save off
