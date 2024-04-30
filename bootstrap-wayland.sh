#!/usr/bin/bash -l
set -ex

yay --noconfirm -S --mflags --skipinteg \
    river wlr-randr zelbar alacritty
