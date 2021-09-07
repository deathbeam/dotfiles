#!/usr/bin/bash -l
set -e

echo '==> Setting up swap file'
if [ ! -f /swapfile ]; then
  sudo fallocate -l 2G /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
  echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab
fi

# Install devel packages
echo '==> Installing base-devel'
sudo pacman --noconfirm -S base-devel

# Install AUR helper
echo '==> Installing AUR helper'
rm -rf /tmp/aur_install
mkdir -p /tmp/aur_install
cd /tmp/aur_install
sudo pacman --noconfirm --needed -S git sudo go
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Install some extra packages via yay
echo '==> Installing extra packages'
yay --noconfirm -S --mflags --skipinteg \
  freetype2 libxft libxrandr libxinerama libxext libglvnd net-tools \
  xdg-utils xdg-user-dirs \
  acpi redshift \
  alsa-utils alsa-plugins alsa-oss alsa-tools alsa-lib \
  lib32-alsa-plugins \
  pulseaudio pulseaudio-alsa \
  stow w3m zsh tmux ripgrep mlocate htop ranger \
  dropbox pass pass-otp zbar \
  vim universal-ctags-git editorconfig-core-c \
  libspotify mpc ncmpcpp \
  bitlbee bitlbee-discord-git bitlbee-facebook \
  perl-html-parser perl-text-charwidth irssi \
  httpie sshpass ntp stoken openvpn wget jq \
  tlp newsboat cpus udisks2

# Enable vbox access for current user
sudo usermod -a -G vboxsf $(whoami)
newgrp vboxsf

# Enable docker for current user
sudo usermod -aG docker "$USER"
newgrp docker

# Update XDG
xdg-user-dirs-update

# Install some stuff for development
echo '==> Installing development packages'
yay --noconfirm -S --mflags --skipinteg \
  jdk8-openjdk openjdk8-doc openjdk8-src \
  jdk-openjdk openjdk-doc openjdk-src \
  maven npm hub git-review docker

echo '==> Installing python packages'
yay --noconfirm -S --mflags --skipinteg \
  python-pip python2-pip \
  gst-plugins-good gst-plugins-ugly gst-python2 gstreamer \
  python-dbus

pip2 install --user mopidy mopidy-spotify mopidy-scrobbler
pip3 install https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip

echo '==> Installing configuration files'
git clone https://github.com/deathbeam/dotfiles ~/.dotfiles || true
cd ~/.dotfiles
make
cd ~

echo '==> Installing extra X11 packages'
yay --noconfirm -S --mflags --skipinteg \
  xorg-server xorg-apps xorg-xinit \
  xorg-fonts-misc xsel xclip autocutsel \
  xf86-input-libinput \
  libva-inter-driver \
  redshift-qt \
  upower

# Improve font rendering and install extra fonts
echo '==> Configuring improved font rendering'
yay --noconfirm -S --mflags --skipinteg \
  freetype2 cairo libxft \
  fonts-meta-base fonts-meta-extended-lt \
  terminus-font-ttf terminus-font ttf-font-awesome

# Enable bitmap fonts (we need them to correctly render Terminus)
sudo rm -rf /etc/fonts/conf.d/70-no-bitmaps.conf
fc-cache -f

# Install applications
echo '==> Installing X11 applications'
pip install --user pyopengl
yay --noconfirm -S --mflags --skipinteg \
  feh zathura zathura-pdf-mupdf imagemagick \
  mpv flashplugin qt5-webengine qutebrowser \
  chromium-widevine \
  libnotify dunst \
  bspwm sxhkd polybar-git touchegg \
  discord \
  intellij-idea-ultimate-edition

# Set default browser
xdg-settings set default-web-browser qutebrowser.desktop

# Install extra packages from source
echo '==> Installing packages from source'
mkdir -p ~/git
cd ~/git

git clone git://git.suckless.org/st || true
cd st
git apply --ignore-space-change --ignore-whitespace ~/.dotfiles/x11/st.diff
sudo make clean install
cd ..

git clone git://git.suckless.org/dmenu || true
cd dmenu
git apply --ignore-space-change --ignore-whitespace ~/.dotfiles/x11/dmenu.diff
sudo make clean install
cd ..

git clone git://git.suckless.org/slock || true
cd slock
git apply --ignore-space-change --ignore-whitespace ~/.dotfiles/x11/slock.diff
sudo make install
cd ..

git clone https://github.com/cdown/clipmenu.git || true
cd clipmenu
sudo make clean install
cd ..

echo '==> Addding nogroup group'
sudo groupadd nogroup
sudo usermod -a -G nogroup "$USER"

echo '==> Changing default shell'
echo "$USER" | chsh -s /bin/zsh
