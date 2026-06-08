# 🪐 hypr-mars

A minimalist, high-performance **Martian Command Center** desktop environment configuration built for Arch Linux using the Hyprland compositor. 

This setup features deep volcanic-charcoal shadows, rugged iron-rust accents, micro-thin borders, unified iconography, and active system telemetry feeds.

---
## System Requirements

To ensure everything renders and executes flawlessly, you must install the following core components, fonts, and utilities encountered during this ricing session:

### 1. Core Interface & Compositor
* `hyprland` (v0.53+ syntax format required)
* `waybar` (Highly customized status panel)

### 2. Custom Script Dependencies
* `go` (Golang compiler—required to build the native Martian weather module binary)
* `jq` (Command-line JSON processor—required for both Docker and Weather parsing modules)
* `docker` (Container management engine)
* `curl` (Data transfer utility to query network endpoints)

### 3. Aesthetics & System Tray
* `papirus-icon-theme` (Unified icon library)
* `nwg-look` (GTK configuration utility to enforce uniform icon application)
* `ttf-nerd-fonts-symbols` (or any complete Nerd Font, for UI symbols and glyphs)

## Installation & Deployment (New Machine)

To clone and instantly deploy this exact Martian desktop environment on a fresh Arch installation, execute the following instructions sequentially:

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/my-ricing.git ~/my-ricing
```

### 2. Create the Destination Directories
```bash
mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
```

### 3. Deploy the Configuration Files
```bash
cp ~/my-ricing/hypr/hyprland.conf ~/.config/hypr/
cp -r ~/my-ricing/waybar/* ~/.config/waybar/
```

### 4. Setup User Permissions & Compile the Modules
```bash
sudo usermod -aG docker $USER
cd ~/.config/waybar/scripts/weather-stats
go build -trimpath -o weather-stats main.go
chmod +x ~/.config/waybar/scripts/weather-stats/weather-stats
chmod +x ~/.config/waybar/scripts/docker-stats/docker-stats
```

### 5. Verify Absolute System Paths

Open the configuration:
```bash
nano ~/.config/waybar/config.jsonc
```

Locate the `custom/docker` and `custom/weather` modules and ensure the `exec` paths point to your actual home directory (e.g., `/home/YOUR_USERNAME/.config/waybar/...`).

> **⚠️ Important:** You must reboot your system completely after executing these installation steps so that the global Docker socket group privileges and window manager states take effect!

---

## Personalization & Tweaking Guide

### Changing Panel Borders & Sizing

Open the Waybar style sheet:
```bash
nano ~/.config/waybar/style.css
```

- **Thinner/Thicker Borders:** Modify the `border: 1px solid #7a4338;` line under the global pill groups selector.
- **Tighter Boxes:** Decrease the `padding: 2px 12px;` settings to compress vertical or horizontal spatial distributions.

### Modifying the Theme Colors

The entire color palette is defined via HEX colors in `style.css`. Replace these accent values:

| Color | Usage |
|-------|-------|
| `#1e2214` | Volcanic Base Background |
| `#7a4338` | Primary Martian Rust Border Outline |
| `#b07c6e` | Active Accent Highlight |

### Changing Panel UI Icons

- **Docker Module:** Edit `~/.config/waybar/scripts/docker-stats/main.go` — update the `text` format string, then recompile:
  ```bash
  cd ~/.config/waybar/scripts/docker-stats && go build -trimpath -o docker-stats main.go
  ```
- **Weather Module:** Edit `~/.config/waybar/scripts/weather-stats/main.go` — update the `text := fmt.Sprintf("🪐 ...")` line, then recompile:
  ```bash
  cd ~/.config/waybar/scripts/weather-stats && go build -trimpath -o weather-stats main.go
  ```
