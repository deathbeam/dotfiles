#!/usr/bin/bash -l
set -ex
shopt -s nullglob globstar

# Install AUR helper
echo '==> Installing AUR helper'
cur_dir=$PWD
rm -rf /tmp/aur_install
mkdir -p /tmp/aur_install
cd /tmp/aur_install
sudo pacman --noconfirm --needed -S git go
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
  p7zip man-db alsa-utils keyd fastfetch

echo '==> Installing development packages'
yay --noconfirm -S --mflags --skipinteg \
  jdk8-openjdk openjdk8-doc openjdk8-src \
  jdk-openjdk openjdk-doc openjdk-src \
  maven npm asdf-vm docker docker-compose github-cli azure-cli lazygit

echo '==> Installing python packages'
yay --noconfirm -S --mflags --skipinteg \
  python-pip python-dbus python-opengl python-virtualenv

pip3 install --break-system-packages https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip

echo '==> Installing desktop packages'
yay --noconfirm -S --mflags --skipinteg \
  fonts-meta-base \
  terminus-font terminus-font-ttf ttf-terminus-nerd \
  udiskie \
  gammastep geoclue2 \
  dunst \
  yambar \
  alacritty \
  zathura zathura-pdf-mupdf \
  qutebrowser python-adblock chromium-widevine \
  mpv yt-dlp \
  dropbox vesktop boosteroid stremio steam calibre postman

echo '==> Installing dotfiles'
mkdir -p ~/git
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
sudo systemctl enable keyd
sudo systemctl enable tlp

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
chsh -s /bin/zsh "$USER"

# Ask user if they want to setup optional services if we are in interactive session
if [ ! -t 0 ]; then
    exit 0
fi

echo '==> Setting up optional services'
scriptpath=$(dirname "$(readlink -f "$0")")
for file in "$scriptpath"/bootstrap-*.sh
do
    name=$(basename "$file" .sh)
    name=${name#bootstrap-}
    read -p "Do you want to setup $name? (y/n) " answer
    if [[ $answer = [yY] ]]; then
        bash "$file"
    fi
done
