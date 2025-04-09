#!/usr/bin/bash -l
set -ex

echo '==> Setting up g14 repository'
sudo tee -a /etc/pacman.conf <<EOF
[g14]
Server = https://arch.asus-linux.org
EOF

sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
sudo pacman-key --finger 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35

echo '==> Installing Asus packages'
yay -S --noconfirm --mflags --skipinteg asusctl rog-control-center

echo '==> Configuring Asus'
sudo systemctl enable asusd
