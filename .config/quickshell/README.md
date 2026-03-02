# Mumbl3-Shell
A Frieren-themed Quickshell config for Hyprland featuring dropdown panel, media controls, dynamic colors, and more. Pure QML on Arch Linux.
<div align="center">

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Status](https://img.shields.io/badge/status-WIP-orange.svg)
![Hyprland](https://img.shields.io/badge/Hyprland-Compatible-5865F2.svg)
![Arch](https://img.shields.io/badge/Arch-Linux-1793D1.svg)

*A Frieren-themed Quickshell configuration for Hyprland*

**Inspired by [fri(no)rain(no)bar](github.com/Rexcrazy804/Zaphkiel/tree/quickshell-3/users/Configs/quickshell/frierainbar)**

[Features](#-features) • [Installation](#-installation) • [Screenshots](#-screenshots) • [Tips & Tricks](#-tips--tricks) • [Roadmap](#-roadmap)

---

### Made by 

**[Botros](https://github.com/BotrosDev)** - The Greatest Developer That Ever Lived  
**[MumbleGameZ](https://github.com/MumbleGameZ)** - The Greatest Developer That Ever Lived  
**[EmiliaCatgirl](https://github.com/EmiliaCatgirl)** - The Greatest Catgirl That Ever Lived

*Stay updated! Join our [Discord Server](https://discord.gg/UDu85xgvQc) for the latest news and updates. Joining using this link will grant you the "OG Council" role!*

</div>

---

## Screenshots
![Alt text description](Pictures/Screenshot_2026-02-26_23-36-12.png)
![Alt text](Pictures/Screenshot_2026-02-26_23-36-53.png)
![Alt text](Pictures/Screenshot_2026-02-26_23-37-31.png)
![Alt text](Pictures/Screenshot_2026-02-26_23-38-42.png)
![Alt text](Pictures/WallpaperChanged.png)

---

## About

The bar sits hidden at the top of your screen. Click it and it drops down with:
- Media player (shows album art, controls playback)
- Notifications
- Calendar
- Wallpaper picker 
- Settings (Under Maintenance)
- App launcher (Under Maintenance) 

---

## IMPORTANT NOTE
```I've built a settings panel with 8 tabs, but right now they're just UI mockups showing what I want to implement. See [TASKS.md](TASKS.md) for the full list of what's working vs what's planned.```
> ⚠️ **ALPHA SOFTWARE - NOT FOR DAILY USE**  
> This is the first public release of Mumbl3-Shell. It's functional but buggy.
> Many features are UI mockups only. Expect crashes and incomplete functionality.

## Installing

### Prerequisites

- **[Quickshell](https://github.com/quickshell-community/quickshell)** - QML shell framework
- **[Hyprland](https://hyprland.org/)** - Wayland compositor
- **Arch Linux** - Primary target (may work on other distros)
- **[Matugen](https://github.com/InioX/matugen)** - Color generation from wallpaper
- **[Swww](https://github.com/LGFae/swww)** - Wallpaper daemon
- **[Rofi](https://github.com/davatorium/rofi)** - App launcher (temporary, will be replaced)

### Optional Dependencies

- **Pipewire/Wireplumber** - For audio control
- **Bluez** - For Bluetooth functionality
- **NetworkManager** - For network management

```bash
# Clone it
git clone https://github.com/BotrosDev/Mumbl3-Shell.git
cd Mumbl3-Shell

# Backup your current config if you have one
mv ~/.config/quickshell ~/.config/quickshell.backup

# Copy files
cp -r . ~/.config/quickshell/bar/

# Install deps (using yay)
yay -S quickshell-git hyprland matugen swww rofi pipewire wireplumber bluez networkmanager

# Generate colors from your wallpaper
matugen image /path/to/wallpaper.png

# Run it
quickshell -p ~/.config/quickshell/bar
# if the previos dont work 
quickshell
```

## About the assets

I don't include the Frieren character images because of copyright. You need to add your own to the `Assets/` folder. Check [SOURCES.md](SOURCES.md) for details on what files you need and where to get them legally.

Or just use different images entirely - the shell works with whatever you throw at it. The Frieren theme is just one option.

## Roadmap

**Working now:**
- Dropdown panel
- Media player
- Notifications
- Calendar/clock
- Wallpaper selector
- Battery, audio, WiFi, brightness widgets
- Workspace management
- Dynamic colors via matugen

**Coming eventually:**
- Functional settings (right now it's just UI)
- Pure QML app launcher (to ditch rofi)
- System tray
- Clipboard manager
- Screenshot/recording tools
- Lock screen

See [TASKS.md](TASKS.md) for more details.

## Some tips

- Right-click the workspace circles to see all 10 at once
- Click the clock to show the full calendar
- Click the audio icon for quick mute
- There's a hidden easter egg in the media player. Go to `dropdownPanel/DropdownPanelWindow.qml` line ~230, remove the comment block, then spam click the chibi Frieren spinning animation

## How the colors work

matugen generates a color palette from your wallpaper and saves it to `~/.local/share/quickshell/colors.json`. The shell reads this file through `Colors.qml` and uses those colors everywhere. Switch wallpapers and the whole UI recolors itself automatically.

## Main config files

- `dropdownPanel/Data/` - Everything in this folder. `Some files arent used` 
- `modules/bar/Bar.qml` - top bar configuration

---

## Project Structure

```
~/.config/quickshell/bar/
├── Assets/                    # Frieren-themed images and GIFs
│   ├── frieren-kuru-kuru.gif
│   ├── FrierenHeart.png
│   ├── sleepOnHimmel.png
│   └── ... (more Frieren goodness)
│
├── dropdownPanel/            # Main dropdown panel
│   ├── Data/                 # Core data providers
│   │   ├── Colors.qml       # Matugen color integration
│   │   ├── Audio.qml        # Audio management
│   │   ├── Clock.qml        # Time/date logic
│   │   ├── Globals.qml      # Global state
│   │   └── ...
│   │
│   ├── Generics/            # Reusable components
│   │   ├── MatIcon.qml
│   │   ├── AudioSlider.qml
│   │   ├── Notification.qml
│   │   └── ...
│   │
│   ├── modules/             # Feature modules
│   │   ├── MediaPlayer.qml
│   │   ├── Calendar.qml
│   │   ├── Notif.qml
│   │   ├── Settings.qml     # (UI mockup)
│   │   └── ...
│   │
│   ├── WallpaperSelector/   # Wallpaper management
│   └── DropdownPanelWindow.qml  # Main panel window
│
├── modules/                 # Bar modules
│   ├── bar/
│   │   ├── Bar.qml         # Top bar definition
│   │   ├── BarClock.qml
│   │   ├── Workspace.qml
│   │   └── ...
│   │
│   ├── widgets/            # System widgets
│   │   ├── Battery.qml
│   │   ├── Volume.qml
│   │   ├── WiFi.qml
│   │   └── ...
│   │
│   └── images/             # Theme icons
│       ├── theme-dark/
│       └── theme-light/
│
└── shell.qml               # Main entry point
```

## Contributing

This is a passion project, but contributions are welcome!

### Developer Notes

- Some code in the `Data/` folder is inherited from fri(no)rain(no)bar (used with permission)
- The dropdown panel concept is inspired by fri(no)rain(no)bar but extensively modified
- New modules are entirely custom-built
- All Frieren assets are properly [sourced](SOURCES.md)
- Rofi was not made by any of Mumbl3 developers. and the code comes from [Hyprnova](https://github.com/zDyant/HyprNova) and [Rofi Theme Collection](https://github.com/dctxmei/rofi-themes) 

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact & Support

- **Discord:** [Join our server](https://discord.gg/UDu85xgvQc) for updates and support
- **Issues:** [GitHub Issues](https://github.com/BotrosDev/Mumbl3-Shell/issues)
- **Discussions:** [GitHub Discussions](https://github.com/BotrosDev/Mumbl3-Shell/discussions)

---
<div align="center">
   

# *"The journey continues..."*
### please, consider giving us a ⭐!

</div>
