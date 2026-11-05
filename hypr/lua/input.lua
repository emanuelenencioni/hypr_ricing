hl.config({
    input = {
        kb_layout  = "it",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification
    },
})

-- Per-device configs
hl.device({
    name           = "synps/2-synaptics-touchpad",
    sensitivity    = 0.5,
    natural_scroll = true,
})

hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.device({
    name          = "logitech-m705",
    scroll_factor = 0.5,
})
