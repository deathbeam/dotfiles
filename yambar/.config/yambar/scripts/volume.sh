#!/bin/sh

amixer get Master | awk -F'[]%[]' '/Left:/ {if ($5 == "off") { print 0 } else { print $2 }}'
