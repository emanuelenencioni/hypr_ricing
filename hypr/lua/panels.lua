-- Shared registry of known physical panels.
--
-- Panels are identified by SERIAL first and description substring
-- second — never by connector name: the dock remaps the same panel
-- onto different connectors (DP-2, DP-3, HDMI-A-1, ...) depending on
-- which USB-C port it is plugged into, so hardware identity is the
-- only stable handle.
--
-- `modes` is an ordered fallback chain: when a panel is detected but
-- the kernel refuses the primary mode (e.g. link or DRM state issues),
-- the watchdog in lua/monitors.lua walks down this chain instead of
-- retrying the same mode forever.
--
-- `width` is the nominal pixel width, used by dock.lua for layout
-- math when the panel is present but stuck without a mode (width 0).

return {
    {
        name     = "home-desk", -- Xiaomi Mi Monitor 27", home desk primary
        serial   = "5744900053006",
        match    = "Xiaomi",
        modes    = { "2560x1440@180", "2560x1440@144", "2560x1440@120", "preferred" },
        position = "0x0",
        scale    = 1,
        width    = 2560,
    },
    {
        name     = "side", -- ASUS VE228
        serial   = "D8LMQS113234",
        match    = "VE228",
        modes    = { "1920x1080@60", "preferred" },
        position = "2560x0",
        scale    = 1,
        width    = 1920,
        -- transform = 1 (rotated) intentionally disabled
    },
    {
        name     = "office-hdmi", -- Samsung S24F350
        serial   = nil, -- serial unknown, description only
        match    = "S24F350",
        modes    = { "preferred" },
        position = "auto",
        scale    = 1,
        width    = 1920,
    },
}
