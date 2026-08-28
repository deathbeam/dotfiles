#!/usr/bin/bash -l
set -e
shopt -s nullglob globstar

arch-update
hyprpm update
pi update --all
npm update -g
pipx upgrade-all
pip3 list --user --outdated --format=freeze 2>/dev/null | cut -d= -f1 | xargs -r pip3 install --user --break-system-packages --upgrade || true
