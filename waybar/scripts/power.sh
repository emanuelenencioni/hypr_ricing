#!/bin/bash

# Get the currently active power profile
CURRENT_PROFILE=$(powerprofilingctl get)

# Cycle to the next profile
case "$CURRENT_PROFILE" in
  power-save)
    powerprofilingctl set balanced
    ;;
  balanced)
    powerprofilingctl set performance
    ;;
  performance)
    powerprofilingctl set power-save
    ;;
  *)
    # Default case if the profile is in an unknown state
    powerprofilingctl set balanced
    ;;
esac
