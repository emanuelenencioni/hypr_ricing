#!/case/bash
sleep 1
killall xdg-desktop-portal-hyprland
killall xdg-desktop-portal-gtk
killall xdg-desktop-portal
# Start the hyprland portal first
/usr/lib/xdg-desktop-portal-hyprland &
sleep 2
# Then start the main portal
/usr/lib/xdg-desktop-portal &
