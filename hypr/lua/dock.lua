-- Lua-native dock handling: the laptop panel follows the presence
-- of the home desk monitor (matched via lua/panels.lua — serial
-- first, description fallback; never connector name, since the dock
-- remaps panels across DP-2/DP-3/HDMI-A-1 depending on the USB-C
-- port) and the lid state.
--
-- State model (enforce() is the single writer):
--   no home monitor        -> eDP-1 on  at 0x0
--   home monitor, lid open -> eDP-1 on  left of the desk panel
--                             (offset = desk panel's real width, or
--                              its nominal width if it has no mode)
--   home monitor, lid shut -> eDP-1 off
-- Event handlers react immediately; a watchdog timer re-converges
-- any drift (missed events, reload side effects, plug races) within
-- seconds, so the state always self-heals.

local PANELS         = require("lua/panels")
local HOME_PANEL     -- the home-desk entry from the registry
local LAPTOP_OUTPUT  = "eDP-1"

for _, p in ipairs(PANELS) do
    if p.name == "home-desk" then
        HOME_PANEL = p
    end
end

local laptop_enabled = true  -- mirrors the last applied panel state
local laptop_left    = false -- panel placed left of the desk monitor
local lid_closed     = false -- lid closed while at the desk

local function home_monitor()
    if HOME_PANEL == nil then
        return nil
    end
    for _, m in ipairs(hl.get_monitors()) do
        if HOME_PANEL.serial and m.serial and m.serial ~= "" and m.serial == HOME_PANEL.serial then
            return m
        end
    end
    for _, m in ipairs(hl.get_monitors()) do
        if m.description and m.description:find(HOME_PANEL.match, 1, true) then
            return m
        end
    end
    return nil
end

local function set_laptop(enabled, left)
    laptop_enabled = enabled
    laptop_left    = left
    local spec = { output = LAPTOP_OUTPUT, disabled = not enabled }
    if enabled then
        if left then
            local desk = home_monitor()
            local w = (desk and desk.width and desk.width > 0 and desk.width)
                or (HOME_PANEL and HOME_PANEL.width)
                or 2560
            spec.position = ("-%dx0"):format(w)
        else
            spec.position = "0x0"
        end
    end
    hl.monitor(spec)
end

local function enforce()
    local home       = home_monitor() ~= nil
    local want_on    = (not home) or (not lid_closed)
    local want_left  = home and (not lid_closed)

    if want_on ~= laptop_enabled or (want_on and want_left ~= laptop_left) then
        set_laptop(want_on, want_left)
    end
end

hl.on("monitor.added", function(m)
    if m == nil or HOME_PANEL == nil then
        return
    end
    if (HOME_PANEL.serial and m.serial == HOME_PANEL.serial)
        or (m.description and m.description:find(HOME_PANEL.match, 1, true)) then
        enforce()
    end
end)

hl.on("monitor.removed", function(m)
    if m == nil or HOME_PANEL == nil then
        return
    end
    if (HOME_PANEL.serial and m.serial == HOME_PANEL.serial)
        or (m.description and m.description:find(HOME_PANEL.match, 1, true)) then
        lid_closed = false -- panel follows monitor presence again
        enforce()
    end
end)

-- Delayed sync after startup/reload: output probing (especially
-- slow-EDID external panels) may not be finished when the event
-- fires. Later events and the watchdog correct any early mistake.
local function delayed_sync()
    hl.timer(enforce, { timeout = 1500, type = "oneshot" })
end

hl.on("hyprland.start", delayed_sync)
hl.on("config.reloaded", delayed_sync)

-- Watchdog: fix any state drift within seconds
hl.timer(enforce, { timeout = 5000, type = "repeat" })

-- Lid switch handling (replaces the old dock_detect acpid/udev scripts).
-- Suspend-on-lid-close while docked is already suppressed by logind's
-- HandleLidSwitchDocked=ignore; the inhibit below is belt-and-suspenders.
local INHIBIT_GUARD = "systemd-inhibit --what=sleep --why='Docked at home - lid closed' sleep infinity"

hl.bind("switch:on:Lid Switch", function()
    if home_monitor() ~= nil then
        lid_closed = true
        enforce()
        -- start inhibit only if not already running (shell-side guard)
        hl.exec_cmd("pgrep -f 'Docked at home' >/dev/null || " .. INHIBIT_GUARD .. " &")
    end
end, { locked = true })

hl.bind("switch:off:Lid Switch", function()
    if home_monitor() ~= nil then
        lid_closed = false
        enforce()
        hl.exec_cmd("pkill -f 'Docked at home' >/dev/null")
    end
end, { locked = true })
