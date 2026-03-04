pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: themeSettings
    
    // Current theme state
    property string wallpaperPath: ""
    property string colorMode: "dark" // "dark" or "light"
    property int paletteIndex: 0 // 0-4
    property real transparency: 0.9
    property int blurStrength: 5
    property string barPosition: "top" // "top" or "bottom"
    property int panelWidth: 45
    property int widgetSpacing: 10
    property bool animationsEnabled: true
    
    // Config file location
    property string configPath: `${Quickshell.env("HOME")}/.config/quickshell/theme-settings.json`
    
    // Process for running matugen
    property Process matugenProcess: Process {
        running: false
        onExited: (code, status) => {
            if (code === 0) {
                console.log("Matugen applied successfully")
            } else {
                console.error("Matugen failed:", standardError)
            }
        }
    }
    
    // Process for running hyprctl
    property Process hyprctlProcess: Process {
        running: false
    }
    
    // Process for file operations
    property Process fileOpProcess: Process {
        running: false
        property var callback: null
        
        onExited: {
            if (callback) {
                callback(standardOutput)
                callback = null
            }
        }
    }
    
    // Load settings on startup
    Component.onCompleted: {
        loadSettings()
    }
    
    // Apply theme with current settings
    function applyTheme() {
        if (wallpaperPath === "") {
            console.log("No wallpaper set yet")
            return
        }
        
        console.log(`Applying theme: mode=${colorMode}, palette=${paletteIndex}`)
        
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
        
        // Generate colors (will run after swww finishes)
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
    
    // Save settings to JSON
    function saveSettings() {
        var settings = {
            wallpaperPath: wallpaperPath,
            colorMode: colorMode,
            paletteIndex: paletteIndex,
            transparency: transparency,
            blurStrength: blurStrength,
            barPosition: barPosition,
            panelWidth: panelWidth,
            widgetSpacing: widgetSpacing,
            animationsEnabled: animationsEnabled
        }
        
        var json = JSON.stringify(settings, null, 2)
        
        // Escape single quotes for bash
        json = json.replace(/'/g, "'\\''")
        
        // Write to file using bash
        fileOpProcess.callback = null
        fileOpProcess.command = ["bash", "-c", `echo '${json}' > "${configPath}"`]
        fileOpProcess.running = true
        
        console.log("Settings saved to", configPath)
    }
    
    // Load settings from JSON
    function loadSettings() {
        // Read file using cat
        fileOpProcess.command = ["cat", configPath]
        fileOpProcess.callback = function(output) {
            if (output.trim() === "") {
                console.log("Config file empty or not found, using defaults")
                saveSettings() // Create default config
                return
            }
            
            try {
                var settings = JSON.parse(output)
                
                wallpaperPath = settings.wallpaperPath || ""
                colorMode = settings.colorMode || "dark"
                paletteIndex = settings.paletteIndex || 0
                transparency = settings.transparency || 0.9
                blurStrength = settings.blurStrength || 5
                barPosition = settings.barPosition || "top"
                panelWidth = settings.panelWidth || 45
                widgetSpacing = settings.widgetSpacing || 10
                animationsEnabled = settings.animationsEnabled !== undefined ? settings.animationsEnabled : true
                
                console.log("Settings loaded from", configPath)
                
                // Apply loaded settings
                if (wallpaperPath !== "") {
                    setTransparency(transparency)
                    setBlurStrength(blurStrength)
                    setAnimationsEnabled(animationsEnabled)
                }
                
            } catch (e) {
                console.error("Failed to parse config:", e)
                saveSettings() // Create fresh config
            }
        }
        fileOpProcess.running = true
    }
}
