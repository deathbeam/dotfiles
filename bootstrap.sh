#!/usr/bin/bash -l
set -ex
shopt -s nullglob globstar

# Prepare git dir
mkdir -p ~/git
cd ~/git

# Install AUR helper
echo '==> Installing AUR helper'
sudo pacman --noconfirm --needed -S git git-lfs
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm

echo '==> Installing sound packages'
yay -S --noconfirm --mflags --skipinteg \
    pipewire \
    pipewire-alsa \
    pipewire-jack \
    pipewire-pulse \
    gst-plugin-pipewire \
    libpulse \
    wireplumber

echo '==> Installing extra packages'
yay -S --noconfirm --mflags --skipinteg \
    mkinitcpio-firmware \
    net-tools dosfstools \
    xdg-utils xdg-user-dirs \
    iw \
    stow zsh tmux ripgrep mlocate btop \
    tree-sitter-git neovim-git ctags less bat fswatch difftastic \
    pass pass-otp \
    httpie sshpass stoken openvpn vpn-slice openconnect tinyproxy wget jq \
    tlp rate-mirrors unzip fuse2 bc brightnessctl \
    p7zip man-db alsa-utils keyd fastfetch onefetch socat systemd-resolvconf pacman-contrib ncdu

echo '==> Installing development packages'
yay -S --noconfirm --mflags --skipinteg \
    jdk8-openjdk openjdk8-doc openjdk8-src \
    jdk-openjdk openjdk-doc openjdk-src \
    python-pip python-dbus python-opengl python-virtualenv \
    dotnet-sdk aspnet-runtime \
    maven npm asdf-vm \
    github-cli lazygit \
    docker docker-compose \
    azure-cli kubectl k9s \
    postman \
    lmstudio \
    mitmproxy \
    inferno \
    argocd

pip3 install --break-system-packages https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip
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
    dropbox dropbox-cli vesktop stremio steam calibre \
    stalonetray xdotool \
    gpu-screen-recorder-git

echo '==> Installing dotfiles'
cd ~/git
git clone https://github.com/deathbeam/dotfiles || true
cd dotfiles
make

echo '==> Configuring system'

# Enable bitmap fonts (we need them to correctly render Terminus)
sudo rm -rf /etc/fonts/conf.d/70-no-bitmaps.conf
fc-cache -f

# Increase inotify watches
sudo tee -a /etc/sysctl.d/40-inotify.conf <<EOF
fs.inotify.max_user_watches=1000000
fs.inotify.max_queued_events=1000000
EOF

# Symlink configs
sudo ln -s ~/git/dotfiles/keyd/default.conf /etc/keyd/default.conf

# Enable services
sudo systemctl enable \
    keyd \
    tlp

# Alter pacman options
sudo sed -i '/\[options\]/a Color' /etc/pacman.conf
sudo sed -i '/\[options\]/a ILoveCandy' /etc/pacman.conf
sudo sed -i '/\[options\]/a ParallelDownloads = 10' /etc/pacman.conf

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
sudo chsh -s /bin/zsh "$USER"

# Disable power save
sudo iw dev wlan0 set power_save off
