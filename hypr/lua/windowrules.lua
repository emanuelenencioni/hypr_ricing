hl.window_rule({
    name  = "ask-your-texture-float",
    match = { title = "^(AskYourTexture)$" },
    float = true,
})

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name             = "no-focus-empty-xwayland",
    match            = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_initial_focus = true,
})

-- Force network and bluetooth popups to float instead of tile
hl.window_rule({
    name   = "float-nm-connection-editor",
    match  = { class = "^(nm-connection-editor)$" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "float-blueman-manager",
    match  = { class = "^(blueman-manager)$" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "float-nm-applet",
    match  = { class = "^(nm-applet)$" },
    float  = true,
})
