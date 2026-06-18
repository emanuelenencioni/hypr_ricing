#!/bin/bash

# Get the first battery found
BATTERY_DIR="/sys/class/power_supply/BAT0"
if [ ! -d "$BATTERY_DIR" ]; then
    BATTERY_DIR="/sys/class/power_supply/$(ls /sys/class/power_supply/ | grep '^BAT' | head -n 1)"
fi

if [ ! -d "$BATTERY_DIR" ]; then
    echo "No battery found"
    exit 1
fi

CAPACITY=$(cat "$BATTERY_DIR/capacity")
STATUS=$(cat "$BATTERY_DIR/status")

ICON=""

if [ "$STATUS" = "Charging" ]; then
    ICON=""
elif [ "$STATUS" = "Full" ]; then
    ICON="󰁹"
else
    if [ "$CAPACITY" -ge 90 ]; then
        ICON="󰂂"
    elif [ "$CAPACITY" -ge 80 ]; then
        ICON="󰂁"
    elif [ "$CAPACITY" -ge 70 ]; then
        ICON="󰂀"
    elif [ "$CAPACITY" -ge 60 ]; then
        ICON="󰁿"
    elif [ "$CAPACITY" -ge 50 ]; then
        ICON="󰁾"
    elif [ "$CAPACITY" -ge 40 ]; then
        ICON="󰁽"
    elif [ "$CAPACITY" -ge 30 ]; then
        ICON="󰁼"
    elif [ "$CAPACITY" -ge 20 ]; then
        ICON="󰁻"
    elif [ "$CAPACITY" -ge 10 ]; then
        ICON="󰁺"
    else
        ICON="󰂎"
    fi
fi

echo "$ICON $CAPACITY%"
