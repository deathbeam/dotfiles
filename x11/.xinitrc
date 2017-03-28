#!/bin/zsh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

# Load all other xinitrc files
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Start guest additions if available
if command -v VBoxClient-all >/dev/null 2>&1; then
  VBoxClient-all
fi

# Load profile
source ~/.profile

# Change mouse cursor from X11 X to normal one
xsetroot -cursor_name left_ptr

# Load custom keyboard mappings
xmodmap ~/.xmodmap

# Start music manager daemon
mopidy &

# Start dropbox
dropbox start &

# Set nice wallpaper
feh --bg-scale ~/.wallpaper

# Start clipboard manager daemon
~/.config/dmenu/clipmenu/clipmenud &

# Start key manager daemon
sxhkd &

# Now, open terminal window
st &

# And finally, start our WM
exec bspwm
