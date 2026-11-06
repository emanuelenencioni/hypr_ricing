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
-- Event handlers react immediately, and every settle event
-- re-converges any drift (missed events, reload side effects, plug
-- races), so the state self-heals without polling.

local PANELS         = require("lua/panels")
local HOME_PANEL     -- the home-desk entry from the registry
local LAPTOP_OUTPUT  = "eDP-1"

for _, p in ipairs(PANELS) do
    if p.name == "home-desk" then
        HOME_PANEL = p
    end
end

-- Lid state must be seeded from hardware, not assumed open: the lid
-- switch event does not replay on a config reload, so a module-local
-- default of false would make every reload re-enable the laptop panel
-- while the lid is still physically shut.
local LID_STATE_PATHS = {
    "/proc/acpi/button/lid/LID/state",
    "/proc/acpi/button/lid/LID0/state",
    "/proc/acpi/button/lid/LID1/state",
}

local function lid_is_closed()
    for _, path in ipairs(LID_STATE_PATHS) do
        local f = io.open(path, "r")
        if f then
            local state = f:read("*a") or ""
            f:close()
            return state:find("closed", 1, true) ~= nil
        end
    end
    return false -- no ACPI lid node: treat as a desktop, lid never shuts
end

local laptop_enabled = true            -- mirrors the last applied panel state
local laptop_left    = false           -- panel placed left of the desk monitor
local lid_closed     = lid_is_closed() -- lid closed while at the desk

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

-- Convergence triggers. Deliberately no hl.timer: in Hyprland 0.57.0
-- a Lua timer leaves a dangling CEventLoopTimer behind, and
-- CConfigManager::cleanTimers() then segfaults in
-- CEventLoopManager::removeTimer() whenever the config manager is torn
-- down -- config reload, logout, or `Hyprland --verify-config`.
--
-- set_laptop() already falls back to the panel's nominal width when a
-- slow-EDID output has no mode yet, so the old 1500 ms delayed sync is
-- not needed; later settle events correct any early mistake.
hl.on("hyprland.start",         enforce)
hl.on("config.reloaded",        enforce)
hl.on("config.props_refreshed", enforce)
hl.on("monitor.layout_changed", enforce)

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
