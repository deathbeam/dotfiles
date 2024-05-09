#!/usr/bin/bash -l
set -ex

echo '==> Installing X11 packages'
yay -S --noconfirm --mflags --skipinteg \
  xdo xdotool xtitle xorg-xdpyinfo xorg-xrandr xorg-xsetroot \
  xclip xsel autocutsel clipboard-bin \
  bspwm sxhkd i3lock imagemagick feh

cd ~/git
git clone git://git.suckless.org/st || true
cd st
git apply --ignore-space-change --ignore-whitespace ~/git/dotfiles/x11/st.diff
cp config.def.h config.h
sudo make clean install
