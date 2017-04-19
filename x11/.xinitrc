#!/bin/zsh

# Load all other xinitrc files
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Load profile
source ~/.profile

# Start guest additions if available
if command -v VBoxClient-all >/dev/null 2>&1; then
  VBoxClient-all
fi

# Change mouse cursor from X11 X to normal one
xsetroot -cursor_name left_ptr

# Load custom keyboard mappings
xmodmap ~/.xmodmap

# Set nice wallpaper
if command -v feh >/dev/null 2>&1; then
  feh --bg-scale ~/.wallpaper
fi

# Start autocutsel
if command -v autocutsel >/dev/null 2>&1; then
  autocutsel -fork &
  autocutsel -selection PRIMARY -fork &
fi

# Start clipboard manager daemon
if [ -f ~/.config/dmenu/clipmenu/clipmenud ]; then
  ~/.config/dmenu/clipmenu/clipmenud &
fi

# Start DavMail
if command -v davmail >/dev/null 2>&1; then
  davmail ~/.davmail.properties &
fi

# Start offlineimap
if command -v offlineimap >/dev/null 2>&1; then
  offlineimap &
fi

# Start music manager daemon
if command -v mopidy >/dev/null 2>&1; then
  mopidy &
fi

# Start dropbox
if command -v dropbox >/dev/null 2>&1; then
  dropbox start &
fi

# Now, open terminal window
if command -v st >/dev/null 2>&1; then
  st &
fi

# Start key manager daemon
if command -v sxhkd >/dev/null 2>&1; then
  sxhkd &
fi

# And finally, start our WM
exec bspwm
