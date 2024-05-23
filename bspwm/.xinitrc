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

# Set gpg agent tty
export GPG_TTY=$(tty)
gpg-connect-agent updatestartuptty /bye >/dev/null

# Hidden tray
if command -v hiddentray >/dev/null 2>&1; then
  hiddentray &
fi

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
  gammastep -m randr &
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

# Open terminal with tmux
if command -v $TERMINAL >/dev/null 2>&1; then
  $TERMINAL -e /bin/zsh -ic "tmux new-session -A -s default" &
fi

# Start key manager daemon
if command -v sxhkd >/dev/null 2>&1; then
  sxhkd &
fi

# Start vbox additions
if command -v VBoxClient-all >/dev/null 2>&1; then
  VBoxClient-all &
fi

# Start vmware stuff
if command -v vmware-user-suid-wrapper >/dev/null 2>&1; then
  vmware-user-suid-wrapper &
fi

# Start bar
if command -v yambar >/dev/null 2>&1; then
  yambar &
fi

# And finally, start our WM
exec bspwm
