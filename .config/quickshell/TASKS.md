#  Mumbl3-Shell Development Roadmap

---

##  Current Sprint: Settings Implementation

### Task 1: Fix Settings Tabs 

**Status:** UI mockups complete, backend implementation needed

The Settings panel has 8 beautifully designed tabs that currently serve as UI previews. All tabs need functional backends:

#### 1.1 AccountsTab.qml 
**Current State:** Static UI mockup  
**What's Broken:**
- Profile picture (Avatar) - "Change Avatar" button does nothing
- Username shows "loading" instead of actual user
- UID and SHELL fields are placeholder text
- Auto-login toggle is non-functional
- Default shell selector (Bash/Zsh/Fish/Sh) doesn't switch
- "Change Password" button is a dummy
- User Groups section is empty

**Implementation Plan:**
```qml
// Needs:
- Read from /etc/passwd for user info
- Avatar selector with file dialog
- Shell detection and switching logic
- PAM integration for password changes
- Group membership from /etc/group
- Auto-login configuration for display manager
```

---

#### 1.2 DataTab.qml 
**Current State:** Fixed placeholder values  
**What's Broken:**
- Storage Overview shows fake data (system disk, home directory, cache)
- "Clear Pacman Cache" button doesn't clear cache
- "Clear Thumbnails Cache" button doesn't clear cache
- "Clear System Logs" button doesn't clear logs
- Backup and Restore section is non-functional

**Implementation Plan:**
```qml
// Needs:
- df command parsing for disk usage
- du command for directory sizes
- pacman -Sc integration for cache cleanup
- find ~/.cache/thumbnails cleanup
- journalctl integration for log management
- rsync/tar for backup functionality
```

---

#### 1.3 SystemTab.qml 
**Current State:** Empty template  
**What's Missing:**
- 3 circular gauges for CPU, GPU, RAM usage
- Real-time monitoring with smooth animations
- Disk list with all mounted volumes
- System information panel (kernel, uptime, etc.)

**Implementation Plan:**
```qml
// Needs:
- /proc/stat parsing for CPU
- nvidia-smi or rocm-smi for GPU (if available)
- /proc/meminfo for RAM
- lsblk for disk enumeration
- /proc/uptime for system uptime
- uname for kernel info
```

---

#### 1.4 DevicesTab.qml 
**Current State:** Partially functional  
**What Works:**  Brightness slider  
**What's Broken:**
- Display resolution selector
- Refresh rate selector
- Scale factor adjustment
- Night Light toggle
- Audio device selection
- Input device configuration

**Implementation Plan:**
```qml
// Needs:
- Hyprland IPC for display settings
- hyprctl for resolution/refresh changes
- Xrandr fallback for X11 compatibility
- PulseAudio/Pipewire for audio routing
- libinput for input device management
```

---

#### 1.5 NetworksTab.qml 
**Current State:** UI only  
**What's Broken:**
- WiFi connection/disconnection
- WiFi network scanning
- Bluetooth device pairing
- Bluetooth enable/disable
- Advanced network options (VPN, proxy, etc.)

**Implementation Plan:**
```qml
// Needs:
- NetworkManager D-Bus integration
- nmcli wrapper for WiFi operations
- bluetoothctl wrapper for BT
- Connection state monitoring
- Signal strength indicators
```

---

<!-- #### 1.6 PersonalizationsTab.qml 
**Current State:** Mixed - some features exist elsewhere  
**What's Broken:**
- Live preview of theme changes
- Theme selector
- Accent color picker
- Dark mode toggle (conflicts with matugen?)                          ** DONE _______________________________ DONE **
- Transparency adjustment
- Blur strength control
- Bar position selector
- Panel width adjustment
- Widget spacing controls
- Animation toggle -->
<!-- 
**Implementation Plan:**
```qml
// Needs:
- Real-time theme preview
- Write to Colors.qml or override system
- Coordinate with matugen color system
- Hyprland blur/transparency commands
- Config file writing for persistence
- Animation toggle state management
``` -->

---

#### 1.7 PowerTab.qml 
**Current State:** Fixed at 75% charging  
**What's Broken:**
- Real battery level reading
- Actual charging status
- Power profile switching (performance/balanced/powersave)
- Advanced power options
- Sleep/hibernate controls
- Battery history graph

**Implementation Plan:**
```qml
// Needs:
- /sys/class/power_supply/BAT0/ parsing
- UPower D-Bus integration
- Power profile daemon integration
- systemctl suspend/hibernate commands
- Battery statistics tracking
```

---

#### 1.8 PrivacyTab.qml 
**Current State:** Security theater  
**What's Broken:**
- Firewall enable/disable (good thing it doesn't work!)
- System update checker
- System update executor
- System logger viewer

**Implementation Plan:**
```qml
// Needs:
- ufw/firewalld wrapper
- checkupdates (pacman) integration
- System update notifications
- journalctl -f for live log viewing
- Log filtering and search
- Safety checks before executing system commands
```

---

## Task 2: App Launcher Rewrite ALMOST DONE

**Implementation Requirements:**
```qml
// Features needed:
- Desktop entry parsing (/usr/share/applications/) ## done
- Fuzzy search/filtering 
- Icon loading with fallbacks
- Recent/frequent app tracking ## done
- Categories and organization
- Keyboard navigation ## done ( but not swipping with mouse )
- Launch apps via exec ## done
- Grid or list view options
```
---

##  Task 3: System Tray 

**Priority:** Medium  
**Status:** Not started

**Requirements:**
- StatusNotifierItem (SNI) D-Bus protocol
- Application icons with correct sizes
- Left/right click actions
- Tooltip support
- Icon theme integration
- Overflow handling for many tray icons

---

## Task 4: Clipboard Manager 

**Priority:** Medium  
**Status:** Not started

**Must-Haves:**
- Pure QML implementation (no Rofi/Wofi)
- Clipboard history (text only initially)
- Search/filter entries
- Pin favorites
- Clear history option
- Keyboard shortcuts
- Image support (future)

**Technical Approach:**
```bash
# Use wl-clipboard
wl-paste --watch
# Store in SQLite or JSON
```

---

## Task 5: Screenshot Tool 

**Priority:** Medium  
**Status:** Not started

**Features:**
- Custom-built QML interface
- Capture modes:
  - Full screen
  - Active window
  - Selection area
  - Active monitor
- Delay timer
- Save location picker
- Clipboard copy option
- Annotation tools (future)

**Backend:** grim + slurp

---

## Task 6: Screen Recorder 

**Priority:** Low  
**Status:** Not started

**Features:**
- Custom QML recording interface
- Area selection
- Audio source selection
- Format options (mp4, webm, gif)
- Recording indicator
- Pause/resume
- System tray integration

**Backend:** wf-recorder or OBS

---

##  Task 7: Lock Screen 

**Priority:** High (security!)  
**Status:** Not started

**Must-Haves:**
- Pure Quickshell/QML implementation
- PAM authentication
- Clock display
- Battery status
- Failed attempt tracking
- Grace period after sleep
- Frieren-themed background!

**Technical:**
```bash
# Integration with:
- swaylock protocol
- PAM for auth
- Hyprland lock signal
```

---

## Task 8: Boot Menu 
**Priority:** Low  
**Status:** Concept phase

**Idea:** Custom boot selection interface

**Questions:**
- How would this integrate with GRUB/systemd-boot?
- Plymouth alternative?
- Just a visual theme?

**To Research:**
- Plymouth customization
- GRUB theming
- systemd-boot configuration

---

## 🌟 Future Ideas (Post-v1.0)

###  Framed Desktop Mode
**Vision:** Alternative panel design with rounded corners and screen frame

**Concept:**
```
┌─────────────────────────────────────────┐
│  ╔═══════════════════════════════════╗  │
│  ║                                   ║  │
│  ║     Actual desktop area here      ║  │
│  ║                                   ║  |
│  ╚═══════════════════════════════════╝  |
│        Panel fits within frame          |
└─────────────────────────────────────────┘
```

**Requirements:**
- New panel window that respects frame
- Rounded corner decorations
- Hyprland gaps coordination
- Option toggle in Personalization
- Disable standard dropdown panel when active

**When:**
- After main project is feature-complete
- When performance is optimized
- After user testing current design

---

##  Progress Tracking

### Phase 1: Core Panel 
- [x] Dropdown system
- [x] Media player
- [x] Notifications
- [x] Calendar
- [x] Wallpaper selector
- [x] System widgets
- [x] Workspace management

### Phase 2: Settings 
- [ ] AccountsTab (0%)
- [ ] DataTab (0%)
- [x] SystemTab (100%)
- [x] DevicesTab (100% - moved display to PersonalizationsTab)
- [ ] NetworksTab (0%)
- [ ] PersonalizationsTab (50%)
- [ ] PowerTab (0%)
- [ ] PrivacyTab (0%)

### Phase 3: Core Tools 
- [x] App Launcher (100% - Standalone with Slide Animation)
- [ ] System Tray (0%)
- [ ] Clipboard (0%)
- [ ] Screenshot (0%)
- [ ] Screen Recorder (0%)
- [ ] Lock Screen (0%)
- [ ] Boot Menu (0%)

### Phase 4: Polish 
- [ ] Framed mode
- [ ] Performance optimization
- [ ] Documentation
- [ ] Video tutorials

