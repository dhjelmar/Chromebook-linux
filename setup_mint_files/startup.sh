#!/usr/bin/env bash

# these commands are run at startup by putting making it executable
# and identifying it in start / start applications

# fix overscan when use HDMI to TV
xrandr --output HDMI-1 --set underscan on
xrandr --output HDMI-1 --set "underscan hborder" 40 --set "underscan vborder" 25
