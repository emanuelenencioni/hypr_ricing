#!/bin/bash

MONITORS_INFO=$(hyprctl monitors)

MONITOR1_PRESENT=$(echo "$MONITORS_INFO" | grep -E "DP-2" | grep "Mi Monitor")

MONITOR2_PRESENT=$(echo "$MONITORS_INFO" | grep -E "HDMI-A-1" | grep "VE228")

if [ -n "$MONITOR1_PRESENT" ] && [ -n "$MONITOR2_PRESENT" ]; then
    echo "Both monitors are connected. Setting them up."

    hyprctl keyword monitor "DP-2,2560x1440@180,0x0,1"

    hyprctl keyword monitor "HDMI-A-1,1920x1080@60,2560x0,1,transform,1"
    hyprctl keyword monitor "eDP-1,disable"
    echo "Monitors configured."
else
    echo "One or both monitors are not connected. No changes made."
fi
