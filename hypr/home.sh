#!/usr/bin/env bash

if [[ `hyprctl monitors | grep Xiaomi | wc -l` -ge 2 ]]; then
	hyprctl keyword monitor "eDP-1, disable"
        hyprctl keyword monitor "eDP-2, 2560x1440@180, 0x0, 1"
else
	hyprctl keyword monitor "eDP-1, 1920x1440@60,0x0, 1.25"
fi
hyprctl reload
