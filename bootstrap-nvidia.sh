#!/usr/bin/bash -l
set -ex

yay --noconfirm -S --mflags --skipinteg \
    nvidia-beta nvidia-utils-beta lib32-nvidia-utils-beta

sudo systemctl enable nvidia-powerd.service
