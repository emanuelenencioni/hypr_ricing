🛠️ Troubleshooting Guide: xdg-desktop-portal Dependency Error & Ghostty/Waybar Startup Lag
🔴 The Symptoms

    Waybar Error: [error] Error calling StartServiceByName for org.freedesktop.portal.Desktop: Timeout was reached

    Ghostty / GTK4 Apps Lag: Spawning the terminal takes 5 to 20 seconds, freezing entirely on launch before rendering.

    Systemd Error: Running systemctl --user status xdg-desktop-portal or checking logs via journalctl reports:
    Dependency failed for Portal service.
    xdg-desktop-portal.service: Job xdg-desktop-portal.service/start failed

🔍 The Root Cause

Modern upstream versions of xdg-desktop-portal restrict the service from launching unless a systemd target called graphical-session.target is active.

Full Desktop Environments (such as GNOME or KDE Plasma) signal this target automatically behind the scenes. Standalone tiling window managers/compositors (like Hyprland) do not trigger it out of the box. As a result:

    Systemd blocks xdg-desktop-portal from opening due to failed dependencies.

    Waybar times out attempting to contact the portal service over D-Bus.

    Ghostty (GTK4) completely freezes on launch because it synchronously waits for a portal response over D-Bus to check the active system color scheme (dark mode/light mode settings).

🚀 The Permanent Solution: Shadowing the Service File

Instead of fighting partial systemd overrides, the most bulletproof approach is to shadow the system-wide service file locally and strip away all session-locking constraints.
Step 1: Clone the System Service File

Copy the global portal rule definition file into your local user configuration layout space to intercept systemd's default behavior. Run this in your terminal:

    mkdir -p ~/.config/systemd/user/

    cp /usr/lib/systemd/user/xdg-desktop-portal.service ~/.config/systemd/user/

Step 2: Strip the Graphical Session Target Dependencies

Open your newly cloned local configuration using a text editor:

    nano ~/.config/systemd/user/xdg-desktop-portal.service

Locate the [Unit] block at the very top of the file. It will typically look like this:
Ini, TOML

[Unit]
Description=Portal service
PartOf=graphical-session.target
Requisite=graphical-session.target
After=graphical-session.target

Completely delete all three lines referencing graphical-session.target. Modify the block so it contains only the core description:
Ini, TOML

[Unit]
Description=Portal service

(Leave the [Service] block below it completely untouched).

Save the modifications (Ctrl+O, then Enter) and exit (Ctrl+X).
Step 3: Enforce Preferred Portal Configurations

Ensure your portal management framework explicitly prioritizes the Hyprland backend to prevent background conflicts with other environments (like KDE or GTK):

    mkdir -p ~/.config/xdg-desktop-portal

    nano ~/.config/xdg-desktop-portal/portals.conf

Paste this clean routing rule into the file:
Ini, TOML

[preferred]
default=hyprland;gtk

Save and exit.
Step 4: Flush Memory & Fire Up the Portals

Force systemd to dump its active operational parameters, reload your clean user-space override configuration, and launch the service manually:

    systemctl --user daemon-reload

    systemctl --user restart xdg-desktop-portal

Verify that the service lights up green without errors:

    systemctl --user status xdg-desktop-portal

🏎️ Bonus Performance Tweak: Ghostty Hyper-Drive

Even when portals are running flawlessly, spinning up GTK4 window assets adds a minor millisecond latency delay to modern terminals. You can use Ghostty's single-instance daemon server trick to keep cold starts instantaneous.

Open your window manager rules configuration:

    nano ~/.config/hypr/hyprland.conf

    Add a headless daemon to your auto-starting workflow chain inside the ### AUTOSTART ### section:

Ini, TOML

exec-once = ghostty --gtk-single-instance=true --quit-after-last-window-closed=false --initial-window=false

    Update your terminal hotkey deployment call mapping logic to pass requests straight to the active background server pool:

Ini, TOML

bind = $mainMod, Q, exec, ghostty --gtk-single-instance=true

Save your adjustments. Your terminal instances will now spawn instantaneously with zero pipeline delay!
