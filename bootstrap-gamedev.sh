#!/usr/bin/bash -l
set -ex

echo '==> Installing Gamedev packages'
yay -S --noconfirm --mflags --skipinteg \
    aseprite \
    magicavoxel \
    godot-git \
    trenchbroom-bin qt5-svg
