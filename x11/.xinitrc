#!/bin/zsh

# Load all other xinitrc files
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Set DPI and merge Xresources
xrandr --auto
xrandr --dpi ${DPI}
xrdb -D"DPI=$DPI" -merge ~/.Xresources

# Change mouse cursor from X11 X to normal one
xsetroot -cursor_name left_ptr

# Remap caps lock to control and escape
setxkbmap -option 'caps:ctrl_modifier' && xcape -e 'Caps_Lock=Escape' &

# Set gpg agent tty
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# Set nice wallpaper
if command -v feh >/dev/null 2>&1; then
  feh --bg-scale ~/.wallpaper
fi

# Start autocutsel
if command -v autocutsel >/dev/null 2>&1; then
  autocutsel -s CLIPBOARD -fork &
fi

# Start location daemon
if [ -f /usr/lib/geoclue-2.0/demos/agent ]; then
  /usr/lib/geoclue-2.0/demos/agent &
fi

# Start gammastep
if command -v gammastep >/dev/null 2>&1; then
  gammastep &
fi

# Start notification daemon
if command -v dunst >/dev/null 2>&1; then
  dunst &
fi

# Start udiskie
if command -v udiskie >/dev/null 2>&1; then
  udiskie &
fi

# Start dropbox
if command -v dropbox >/dev/null 2>&1; then
  dropbox start &
fi

# Start steam
if command -v steam >/dev/null 2>&1; then
  steam -silent &
fi

# Start discord
if command -v discord >/dev/null 2>&1; then
  discord --start-minimized &
fi

# Open terminal with tmux
if command -v alacritty >/dev/null 2>&1; then
  alacritty -e /bin/zsh -ic "tmux new-session -A -s default" &
fi

# Start key manager daemon
if command -v sxhkd >/dev/null 2>&1; then
  sxhkd &
fi

# Start bar
~/.config/bar/bar.sh &

# And finally, start our WM
exec bspwm
