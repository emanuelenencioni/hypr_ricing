hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Tells QT apps (like Dolphin) to use KDE/Qt settings
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "kde")
-- Tells GTK apps to prefer dark mode
hl.env("GTK_THEME", "Breeze-Dark")
hl.env("XDG_MENU_PREFIX", "arch-")

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
