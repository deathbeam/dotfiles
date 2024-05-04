#!/usr/bin/bash -l
set -ex

# Install AUR helper
echo '==> Installing AUR helper'
cur_dir=$PWD
rm -rf /tmp/aur_install
mkdir -p /tmp/aur_install
cd /tmp/aur_install
sudo pacman --noconfirm --needed -S git sudo go
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si --noconfirm
cd $cur_dir

echo '==> Installing extra packages'
yay --noconfirm -S --mflags --skipinteg \
  mkinitcpio-firmware \
  net-tools \
  xdg-utils xdg-user-dirs \
  stow zsh tmux ripgrep mlocate htop \
  neovim-nightly-bin ctags less bat fswatch difftastic \
  pass pass-otp zbar \
  httpie sshpass stoken openvpn vpn-slice openconnect wget jq \
  tlp rate-mirrors unzip fuse2 bc brightnessctl \
  p7zip man-db alsa-utils

echo '==> Installing development packages'
yay --noconfirm -S --mflags --skipinteg \
  jdk8-openjdk openjdk8-doc openjdk8-src \
  jdk-openjdk openjdk-doc openjdk-src \
  maven npm github-cli azure-cli docker docker-compose lazygit asdf-vm

echo '==> Installing python packages'
yay --noconfirm -S --mflags --skipinteg \
  python-pip python-dbus python-opengl python-virtualenv

pip3 install --break-system-packages https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip

echo '==> Installing font packages'
yay --noconfirm -S --mflags --skipinteg \
  fonts-meta-base \
  terminus-font terminus-font-ttf ttf-terminus-nerd

echo '==> Installing X11 packages'
yay --noconfirm -S --mflags --skipinteg \
  xdotool xdo xtitle xorg-xdpyinfo xorg-xrandr xorg-xsetroot \
  xclip xsel autocutsel clipboard-bin

echo '==> Installing X11 applications'
yay --noconfirm -S --mflags --skipinteg \
  feh zathura zathura-pdf-mupdf imagemagick \
  qutebrowser python-adblock chromium-widevine \
  libnotify dunst \
  bspwm sxhkd i3lock yambar \
  geoclue2 gammastep \
  udiskie \
  dropbox \
  mpv yt-dlp vesktop boosteroid stremio steam calibre \
  postman alacritty evremap

mkdir -p ~/git
cd ~/git

echo '==> Installing dotfiles'
git clone https://github.com/deathbeam/dotfiles || true
cd dotfiles
make
cd ..

echo '==> Installing packages from source'

git clone git://git.suckless.org/st || true
cd st
git apply --ignore-space-change --ignore-whitespace ~/git/dotfiles/x11/st.diff
cp config.def.h config.h
sudo make clean install
cd ..

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
sudo ln -s ~/git/dotfiles/evremap/evremap.toml /etc/evremap.toml

# Enable services
sudo systemctl enable evremap.service
sudo systemctl enable tlp.service

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
