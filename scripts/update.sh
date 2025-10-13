#!/usr/bin/bash -l
set -e
shopt -s nullglob globstar

arch-update
hyprpm update
