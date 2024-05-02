#!/bin/bash

# Get the window ID of the currently focused window
window_id=$(xdotool getwindowfocus)

# Wait for the window to actually lose focus
while [ "$(xdotool getwindowfocus)" == "$window_id" ]; do
    sleep 0.1
done

# Close the window
xdotool windowkill $window_id
