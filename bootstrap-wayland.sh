#!/usr/bin/bash -l
set -ex

yay --noconfirm -S --mflags --skipinteg \
    river way-displays alacritty waybar
