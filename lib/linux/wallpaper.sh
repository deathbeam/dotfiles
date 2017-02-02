#!/bin/bash

cd $DOTHOME/usr/wallpapers
feh --bg-scale "$(ls | sort -R | head -1)"
