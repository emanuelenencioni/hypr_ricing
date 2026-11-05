-- Entry point. Hyprland loads this instead of hyprland.conf.
-- Each require() runs in its own scope, so an error in one
-- module does not abort the others.
-- https://wiki.hypr.land/Configuring/Start/

require("lua/monitors")
require("lua/dock")
require("lua/env")
require("lua/autostart")
require("lua/appearance")
require("lua/input")
require("lua/keybinds")
require("lua/windowrules")
