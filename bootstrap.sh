#!/usr/bin/bash -l
set -ex

# Install devel packages
echo '==> Installing base-devel'
sudo pacman --noconfirm -S base-devel

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
  freetype2 libxft libxrandr libxinerama libxext libglvnd net-tools \
  xdg-utils xdg-user-dirs \
  acpi redshift \
  alsa-utils alsa-plugins alsa-oss \
  pipewire pipewire-alsa pipewire-jack pipewire-pulse gst-plugin-pipewire libpulse wireplumber
  stow zsh tmux ripgrep mlocate htop \
  neovim-nightly-bin ctags bat fswatch \
  dropbox pass pass-otp zbar \
  httpie sshpass ntp stoken openvpn vpn-slice openconnect wget jq \
  tlp udisks2 rate-mirrors unzip

echo '==> Installing development packages'
yay --noconfirm -S --mflags --skipinteg \
  jdk8-openjdk openjdk8-doc openjdk8-src \
  jdk-openjdk openjdk-doc openjdk-src \
  maven npm github-cli azure-cli docker docker-compose git-delta lazygit lazydocker

echo '==> Installing python packages'
yay --noconfirm -S --mflags --skipinteg \
  python-pip python-dbus python-opengl python-virtualenv

pip3 install --break-system-packages https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip

echo '==> Installing X11 packages'
yay --noconfirm -S --mflags --skipinteg \
  xorg-server xorg-apps xorg-xinit \
  xorg-fonts-misc xsel xclip autocutsel clipnotify clipmenu-git \
  xf86-input-libinput xcape xtitle screenkey slop \
  redshift-qt \
  upower \
  udiskie

echo '==> Installing font packages'
yay --noconfirm -S --mflags --skipinteg \
  freetype2 cairo libxft \
  fonts-meta-base \
  terminus-font terminus-font-ttf ttf-terminus-nerd

echo '==> Installing X11 applications'
yay --noconfirm -S --mflags --skipinteg \
  feh zathura zathura-pdf-mupdf imagemagick \
  flashplugin qutebrowser python-adblock chromium-widevine \
  libnotify dunst \
  bspwm sxhkd polybar \
  mpv yt-dlp discord boosteroid calibre \
  postman intellij-idea-ue-eap

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

git clone git://git.suckless.org/slock || true
cd slock
cp config.def.h config.h
git apply --ignore-space-change --ignore-whitespace ~/git/dotfiles/x11/slock.diff
sudo make install
cd ..

echo '==> Configuring system'

# Enable bitmap fonts (we need them to correctly render Terminus)
sudo rm -rf /etc/fonts/conf.d/70-no-bitmaps.conf
fc-cache -f

# Increase inotify watches
echo -e 'fs.inotify.max_user_watches=1000000\nfs.inotify.max_queued_events=1000000' | sudo tee -a /etc/sysctl.d/40-inotify.conf

# Enable vbox access for current user
sudo groupadd -f vboxsf
sudo usermod -aG vboxsf "$USER"

# Enable docker for current user
sudo groupadd -f docker
sudo usermod -aG docker "$USER"

# Add nogroup group for current user
sudo groupadd nogroup
sudo usermod -a -G nogroup "$USER"

# Update XDG
xdg-user-dirs-update

# Set default browser
xdg-settings set default-web-browser qutebrowser.desktop

# Change default shell
echo "$USER" | chsh -s /bin/zsh
