pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

QtObject {
    id: themeSettings
    
    // Current theme state - all with safe defaults
    property string wallpaperPath: ""
    property string colorMode: "dark"
    property int paletteIndex: 0
    property real transparency: 0.9
    property int blurStrength: 5
    property string barPosition_T: ""
    property string barPosition_B: "bottom"
    property string barPosition_R: "right"
    property string barPosition_L: "left"
    property string fontFamily: "DejaVu Sans"
    property int panelWidth: 45
    property int panelThickness: 45
    property int widgetSpacing: 10
    property bool animationsEnabled: true
    
    // Config file location
    property string configPath: `${Quickshell.env("HOME")}/.config/quickshell/theme-settings.json`
    
    // Processes - not running by default!
    property Process matugenProcess: Process {
        running: false
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (matugenProcess.exitCode == 0) {
                    console.error("Matugen failed:", this.text)
                }
            }
        }
    }
    
    property Process hyprctlProcess: Process {
        running: false
    }
    
    property Process fileOpProcess: Process {
        running: false
        property var callback: null
        
        stdout: StdioCollector {
            onStreamFinished: {
                if (fileOpProcess.callback) {
                    fileOpProcess.callback(this.text)
                    fileOpProcess.callback = null
                }
            }
        }
    }
    
    // Timer to delay loading until after Colors.qml is ready
    property Timer initTimer: Timer {
        interval: 500
        running: true
        repeat: false
        
        onTriggered: {
            loadSettings()
        }
    }
    
    // Apply theme with current settings
    function applyTheme() {
        if (wallpaperPath === "") {
            console.log("ThemeSettings: No wallpaper set, Probably The Wallpaper wasn't detected, Try Selecting a Wallpaper again, skipping matugen...")
            return
        }
        
        matugenProcess.command = [
            "matugen", 
            "image", 
            wallpaperPath,
            "--mode", colorMode,
            "--source-color-index", paletteIndex.toString()
        ]
        matugenProcess.running = true
    }
    
    // Set wallpaper and generate colors
    function setWallpaper(path) {
        wallpaperPath = path
        
        // Set wallpaper with swww
        fileOpProcess.callback = null
        fileOpProcess.command = ["swww", "img", path, "--transition-type", "fade", "--transition-fps", "60"]
        fileOpProcess.running = true
        
        // Generate colors
        applyTheme()
        
        // Save settings
        saveSettings()
    }
    
    // Change color mode (light/dark)
    function setColorMode(mode) {
        colorMode = mode
        applyTheme()
        saveSettings()
    }
    
    // Change palette index
    function setPaletteIndex(index) {
        paletteIndex = index
        applyTheme()
        saveSettings()
    }
    
    // Apply transparency to Hyprland windows
    function setTransparency(value) {
        transparency = value
        
        // Apply both active and inactive opacity in one command
        hyprctlProcess.command = [
            "bash", "-c",
            `hyprctl keyword decoration:active_opacity ${value.toFixed(2)} && hyprctl keyword decoration:inactive_opacity ${(value * 0.9).toFixed(2)}`
        ]
        hyprctlProcess.running = true
        
        saveSettings()
    }
    
    // Apply blur strength
    function setBlurStrength(value) {
        blurStrength = value
        
        hyprctlProcess.command = [
            "hyprctl", "keyword", 
            "decoration:blur:size", Math.round(value).toString()
        ]
        hyprctlProcess.running = true
        
        saveSettings()
    }
    
    // Toggle animations
    function setAnimationsEnabled(enabled) {
        animationsEnabled = enabled
        
        hyprctlProcess.command = [
            "hyprctl", "keyword", 
            "animations:enabled", enabled ? "true" : "false"
        ]
        hyprctlProcess.running = true
        
        saveSettings()
    }

    // Bar position (top/bottom/left/right) – requires restart
    function setBarPosition_T(position_T) {
        barPosition_T = position_T
        saveSettings()
    }

    function setBarPosition_B(position_B) {
        barPosition_B = position_B
        saveSettings()
    }

    function setBarPosition_R(position_R) {
        barPosition_R = position_R
        saveSettings()
    }

    function setBarPosition_L(position_L) {
        barPosition_L = position_L
        saveSettings()
    }

    // UI font family (from Data/Fonts.qml options)
    function setFontFamily(family) {
        fontFamily = family
        saveSettings()
    }

    function setPanelWidth(width) {
        panelWidth = width
        saveSettings()
    }

    function setWidgetSpacing(spacing) {
        widgetSpacing = spacing
        saveSettings()
    }
    
    // Save settings to JSON
    function saveSettings() {
        var settings = {
            wallpaperPath: wallpaperPath,
            colorMode: colorMode,
            paletteIndex: paletteIndex,
            transparency: transparency,
            blurStrength: blurStrength,
            barPosition_T: barPosition_T,
            barPosition_B: barPosition_B,
            barPosition_R: barPosition_R,
            barPosition_L: barPosition_L,
            fontFamily: fontFamily,
            panelWidth: panelWidth,
            widgetSpacing: widgetSpacing,
            animationsEnabled: animationsEnabled
        }
        
        var json = JSON.stringify(settings, null, 2)
        
        // Escape single quotes for bash
        json = json.replace(/'/g, "'\\''")
        
        // Write to file using bash
        fileOpProcess.callback = null
        fileOpProcess.command = ["bash", "-c", `mkdir -p ~/.config/quickshell && echo '${json}' > "${configPath}"`]
        fileOpProcess.running = true
        
    }
    
    // Load settings from JSON 
    function loadSettings() {
        
        // Read file 
        fileOpProcess.command = ["cat", configPath]
        fileOpProcess.callback = function(output) {
            if (output.trim() === "") {
                console.log("ThemeSettings: No config file found, using defaults")
                return
            }
            
            try {
                var settings = JSON.parse(output)
                
                wallpaperPath = settings.wallpaperPath || ""
                colorMode = settings.colorMode || "dark"
                paletteIndex = settings.paletteIndex || 0
                transparency = settings.transparency || 0.9
                blurStrength = settings.blurStrength || 5
                barPosition_T = settings.barPosition_T || ""
                barPosition_B = settings.barPosition_B || ""
                barPosition_R = settings.barPosition_R || ""
                barPosition_L = settings.barPosition_L || ""
                fontFamily = settings.fontFamily || "DejaVu Sans"
                panelWidth = settings.panelWidth || 45
                widgetSpacing = settings.widgetSpacing || 10
                animationsEnabled = settings.animationsEnabled !== undefined ? settings.animationsEnabled : true
                
                // Apply loaded settings (but NOT matugen - colors are already loaded)
                if (transparency !== 0.9) setTransparency(transparency)
                if (blurStrength !== 5) setBlurStrength(blurStrength)
                if (animationsEnabled !== true) setAnimationsEnabled(animationsEnabled)
                
            } catch (e) {
                console.warn("ThemeSettings: Failed to parse config:", e)
            }
        }
        fileOpProcess.running = true
    }
}
