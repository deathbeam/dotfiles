#!/bin/sh

# Launch krita with custom scale factor as it goes through X11
env QT_SCALE_FACTOR=$SCALE_FACTOR $1
