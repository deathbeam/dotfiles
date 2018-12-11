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

# Install AUR helper
echo '==> Installing AUR helper'
rm -rf /tmp/aur_install
mkdir -p /tmp/aur_install
cd /tmp/aur_install
sudo pacman --noconfirm --needed -S git sudo go
curl -o PKGBUILD 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay'
makepkg PKGBUILD --skippgpcheck --install --noconfirm --needed

# Install some extra packages via yay
echo '==> Installing extra packages'
yay --noconfirm -S \
  freetype2 libxft libxrandr libxinerama libxext libglvnd net-tools \
  xdg-utils xdg-user-dirs \
  acpi redshift-gtk \
  alsa-utils alsa-plugins alsa-oss alsa-tools alsa-lib \
  pulseaudio pulseaudio-alsa \
  stow w3m zsh tmux ripgrep mlocate htop \
  dropbox pass ranger \
  vim universal-ctags-git editorconfig-core-c \
  libspotify mpc ncmpcpp \
  bitlbee bitlbee-discord-git bitlbee-facebook \
  perl-html-parser perl-text-charwidth irssi \
  httpie sshpass \
  docker

# Enable docker for current user
sudo usermod -aG docker "$USER"
newgrp docker

# Update XDG
xdg-user-dirs-update

# Install some stuff for development
echo '==> Installing development packages'
yay --noconfirm -S jdk8-openjdk maven npm hub git-review

echo '==> Installing python packages'
yay --noconfirm -S \
  python-pip python2-pip \
  gst-plugins-good gst-plugins-ugly gst-python2 gstreamer

pip2 install --user mopidy mopidy-spotify mopidy-scrobbler

echo '==> Installing configuration files'
git clone https://github.com/deathbeam/dotfiles ~/.dotfiles || true
cd ~/.dotfiles
make
cd ~

echo '==> Installing extra X11 packages'
yay --noconfirm -S \
  xorg-server xorg-apps xorg-xinit \
  xorg-fonts-misc xsel xclip autocutsel \
  xf86-input-libinput

# Improve font rendering and install extra fonts
echo '==> Configuring improved font rendering'
yay --noconfirm -S \
  freetype2 cairo libxft \
  fonts-meta-base fonts-meta-extended-lt \
  terminus-font-ttf terminus-font ttf-font-awesome

# Enable bitmap fonts (we need them to correctly render Terminus)
sudo rm -rf /etc/fonts/conf.d/70-no-bitmaps.conf
fc-cache -f

# Install applications
echo '==> Installing X11 applications'
pip install --user pyopengl
yay --noconfirm -S \
  feh zathura zathura-pdf-mupdf imagemagick \
  mpv flashplugin qt5-webengine qt5-webengine-widevine qutebrowser \
  libnotify dunst \
  bspwm sxhkd polybar-git \
  discord \
  intellij-idea-ultimate-edition

# Set default browser
xdg-settings set default-web-browser qutebrowser.desktop

# Install extra packages from source
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
sudo make clean install
cd ..

echo '==> Addding nogroup group'
sudo groupadd nogroup
sudo usermod -a -G nogroup "$USER"

echo '==> Changing default shell'
echo "$USER" | chsh -s /bin/zsh
