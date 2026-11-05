# hyprsunset configuration — Rome

Date: 2026-10-15
Status: **implemented & verified**

## Context

- `hyprsunset` v0.4.0 installed at `/usr/bin/hyprsunset` (Arch Linux)
- Hyprland 0.56.2, hyprlang 0.6.8
- System timezone already `Europe/Rome` (CEST) — hyprsunset uses local time automatically, no TZ config needed
- Hyprland uses the new Lua config: `~/.config/hypr/hyprland.lua` → `lua/*.lua` modules
- Apps are launched via `hl.exec_cmd` in `lua/autostart.lua`
- systemd user service `hyprsunset.service` exists but is disabled (using `hl.exec_cmd` autostart instead, matching the existing hyprpaper/hypridle pattern)

## IMPORTANT: config syntax (hyprlang >= 0.6 / Hyprland 0.56+)

The installed build uses the **new hyprlang special-category syntax**, verified empirically:

- Correct: `profile[key] { ... }`  (e.g. `profile[day] { ... }`)
- **Wrong**: `profile: key { ... }` → `config option <profile: day:time> does not exist`, 0 profiles loaded
- `time` values must be **unquoted**: `time = 06:30` (quotes are taken literally → `Invalid time format`)
- `gamma` is a **ratio** in the config (`1.0` = 100%), not a percentage
- No `on-switch` key in v0.4.0 (that is only on `main`)

## How hyprsunset works

- Config: `~/.config/hypr/hyprsunset.conf`
- Each profile has: `time` (HH:MM local), `temperature` (K, 1000–20000), `gamma` (0–1), `identity` (0/1)
- Profiles are sorted by time; the active profile is the one whose `time` has most recently passed
- Before the first profile's time the last profile wraps around (overnight = night profile)
- Switches are instantaneous at the profile time; no smooth transitions
- Manual IPC overrides reset automatically at the next profile switch

## Changes made

### 1. `~/.config/hypr/hyprsunset.conf` (created)

```
max-gamma = 100

profile[day]     { time = 06:30  temperature = 6500  gamma = 1.0  identity = 0 }
profile[evening] { time = 17:30  temperature = 4500  gamma = 1.0  identity = 0 }
profile[night]   { time = 21:00  temperature = 3500  gamma = 1.0  identity = 0 }
```

(actual file is expanded with comments)

### 2. `lua/autostart.lua` (edited)

Added `hl.exec_cmd("hyprsunset")` after `hypridle`.

### 3. `lua/keybinds.lua` (edited)

```lua
hl.bind(mainMod .. " + F2",         hl.dsp.exec_cmd("hyprctl hyprsunset identity true"))
hl.bind(mainMod .. " + SHIFT + F2", hl.dsp.exec_cmd("hyprctl hyprsunset identity false"))
```

## Verification (done)

- `hyprsunset` starts, log shows `Loaded 3 profiles` and no config errors
- `hyprctl hyprsunset profile` → active profile (e.g. `day`, 6500K at 16:01)
- `hyprctl hyprsunset temperature` → current Kelvin
- `hyprctl hyprsunset identity true|false` → toggle works
- `hyprctl hyprsunset reset` → restores scheduled profile

## Troubleshooting

`hyprctl hyprsunset ...` → `Couldn't connect to .../.hyprsunset.sock (3)` = the socket
file exists but has no listener (orphaned/stale), usually after killing and
relaunching hyprsunset manually several times. Fix:

```bash
pkill -x hyprsunset
rm -f /run/user/1000/hypr/*/.hyprsunset.sock
hyprsunset &
hyprctl hyprsunset profile       # sanity check
```

Avoid launching multiple instances; hyprsunset has an instance lock + CTM-manager
guard, but rapid kill/relaunch cycles can still leave a stale socket. The systemd
user service (`hyprsunset.service`, currently disabled) is the most robust option if
manual launches keep colliding.

## Notes

- The running instance was started manually; on next Hyprland restart the autostart entry launches it.
- hyprsunset uses an instance lock + CTM-manager v2 "blocked" guard, so a duplicate launch exits safely.
