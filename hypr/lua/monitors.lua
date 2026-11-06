-- External monitor rules. Panels are matched by serial/description
-- (see lua/panels.lua), never by connector name: the dock remaps the
-- same panel onto different connectors (DP-2, DP-3, HDMI-A-1, ...)
-- depending on the USB-C port in use. desc:-prefixed rules silently
-- never apply at runtime (Hyprland 0.56, issue #15961), so we scan
-- hl.get_monitors() ourselves and apply rules using the plain
-- connector name, which does apply.
--
-- Rules are re-applied on settle events when a known panel is found
-- stuck at 0x0 (kernel rejecting every modeset). Each retry steps
-- down the panel's mode fallback chain instead of repeating the same
-- mode. Event-driven on purpose: see heal_stuck_panels() below.

local PANELS = require("lua/panels")

local function find_panel(panel)
    local monitors = hl.get_monitors()
    if panel.serial then
        for _, m in ipairs(monitors) do
            if m.serial and m.serial ~= "" and m.serial == panel.serial then
                return m
            end
        end
    end
    for _, m in ipairs(monitors) do
        if m.description and m.description:find(panel.match, 1, true) then
            return m
        end
    end
    return nil
end

local function rule_for(panel, output, mode)
    return {
        output   = output,
        mode     = mode,
        position = panel.position,
        scale    = panel.scale,
    }
end

local function apply_panel(panel, mode)
    local m = find_panel(panel)
    if m == nil then
        return false
    end
    hl.monitor(rule_for(panel, m.name, mode))
    return true
end

-- Laptop panel baseline: scale is pinned to 1; lua/dock.lua owns its
-- enabled/disabled state and position dynamically.
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "0x0",
    scale    = 1,
})

-- Initial application (config load / reload)
for _, panel in ipairs(PANELS) do
    apply_panel(panel, panel.modes[1])
end

-- Hotplug: when a new output appears (dock plug, cable swap, wake),
-- re-apply the matching rule by connector name.
hl.on("monitor.added", function(m)
    if m == nil or m.description == nil then
        return
    end
    for _, panel in ipairs(PANELS) do
        local known = (panel.serial and m.serial == panel.serial)
            or m.description:find(panel.match, 1, true)
        if known then
            hl.monitor(rule_for(panel, m.name, panel.modes[1]))
            return
        end
    end
end)

-- Heal panels stuck at 0x0 (present but no mode applied).
--
-- Driven by settle events rather than a polling hl.timer: in Hyprland
-- 0.57.0 a Lua timer leaves a dangling CEventLoopTimer behind, and
-- CConfigManager::cleanTimers() then segfaults in
-- CEventLoopManager::removeTimer() whenever the config manager is torn
-- down -- config reload, logout, or `Hyprland --verify-config`.
--
-- Each settle event steps one further down the panel's mode fallback
-- chain, so a rejected primary mode still does not loop forever, and
-- the chain resets as soon as the panel reports a real mode.
local attempts = {} -- panel.name -> retry count while unhealthy

local function heal_stuck_panels()
    for _, panel in ipairs(PANELS) do
        local m = find_panel(panel)
        if m ~= nil and (m.width == nil or m.height == nil or m.width == 0 or m.height == 0) then
            local n = (attempts[panel.name] or 0) + 1
            attempts[panel.name] = n
            local idx = math.min(n, #panel.modes)
            hl.monitor(rule_for(panel, m.name, panel.modes[idx]))
        else
            attempts[panel.name] = nil -- healthy again: reset the chain
        end
    end
end

hl.on("monitor.layout_changed", heal_stuck_panels)
hl.on("config.props_refreshed", heal_stuck_panels)
