import Quickshell
import QtQuick
import Quickshell.Io
import "../../dropdownPanel/Data" as Dat

Item {
    id: batteryContainer
    width: batteryRow.width + 20 
    height: batteryRow.height
    
    property var batteries: []  
    property bool hasBattery: false
    property int totalLevel: 0
    property string status: "Unknown"
    
    Row {
        id: batteryRow
        spacing: 5
        anchors.right: parent.right
        anchors.rightMargin: 10  
        anchors.verticalCenter: parent.verticalCenter
        
        
        Text {
            visible: !batteryContainer.hasBattery
            text: "󰚥"  // AC power icon
            color: Dat.Colors.color.on_surface
            font.pixelSize: 16
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            visible: !batteryContainer.hasBattery
            text: "AC"
            color: Dat.Colors.color.on_surface
            font.pixelSize: 12
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Battery display (when battery exists)
        Image {
            id: batteryImage
            visible: batteryContainer.hasBattery
            width: 15
            height: 15
            anchors.verticalCenter: parent.verticalCenter
            
            source: {
                var level = batteryContainer.totalLevel
                var stat = batteryContainer.status
                
                // 100%
                if (level >= 100 && stat === "Charging") {
                    return "../images/theme-light/battery-100-charged.svg"
                } else if (level >= 100) {
                    return "../images/theme-light/battery-100.svg"
                }
                // 90%
                else if (level >= 90 && stat === "Charging") {
                    return "../images/theme-light/battery-090-charging.svg"
                } else if (level >= 90) {
                    return "../images/theme-light/battery-090.svg"
                }
                // 80%
                else if (level >= 80 && stat === "Charging") {
                    return "../images/theme-light/battery-080-charging.svg"
                } else if (level >= 80) {
                    return "../images/theme-light/battery-080.svg"
                }
                // 70%
                else if (level >= 70 && stat === "Charging") {
                    return "../images/theme-light/battery-070-charging.svg"
                } else if (level >= 70) {
                    return "../images/theme-light/battery-070.svg"
                }
                // 60%
                else if (level >= 60 && stat === "Charging") {
                    return "../images/theme-light/battery-060-charging.svg"
                } else if (level >= 60) {
                    return "../images/theme-light/battery-060.svg"
                }
                // 50%
                else if (level >= 50 && stat === "Charging") {
                    return "../images/theme-light/battery-050-charging.svg"
                } else if (level >= 50) {
                    return "../images/theme-light/battery-050.svg"
                }
                // 40%
                else if (level >= 40 && stat === "Charging") {
                    return "../images/theme-light/battery-040-charging.svg"
                } else if (level >= 40) {
                    return "../images/theme-light/battery-040.svg"
                }
                // 30%
                else if (level >= 30 && stat === "Charging") {
                    return "../images/theme-light/battery-030-charging.svg"
                } else if (level >= 30) {
                    return "../images/theme-light/battery-030.svg"
                }
                // 20%
                else if (level >= 20 && stat === "Charging") {
                    return "../images/theme-light/battery-020-charging.svg"
                } else if (level >= 20) {
                    return "../images/theme-light/battery-020.svg"
                    
                }
                // 10%
                else if (level >= 10 && stat === "Charging") {
                    return "../images/theme-light/battery-010-charging.svg"
                } else if (level >= 10) {
                    return "../images/theme-light/battery-010.svg"
                }
                // 0%
                else if (stat === "Charging") {
                    return "../images/theme-light/battery-000-charging.svg"
                } else {
                    return "../images/theme-light/battery-000.svg"
                }
            }
        }
        
        Text {
            id: batteryText
            visible: batteryContainer.hasBattery
            text: batteryContainer.totalLevel + "%"
            color: {
                if (batteryContainer.totalLevel <= 20) return "#f7768e"  
                if (batteryContainer.totalLevel <= 40) return "#e0af68"  
                return Dat.Colors.color.on_surface
            }
            font.pixelSize: 14
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        // Multiple batteries indicator
        // did not Test this yet, but should work as long as batteryContainer.batteries is properly populated with battery paths
        Text {
            visible: batteryContainer.hasBattery && batteryContainer.batteries.length > 1
            text: "×" + batteryContainer.batteries.length
            color: "#565f89"
            font.pixelSize: 10
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    // Detect available batteries
    // didnt test this yet, but should populate batteryContainer.batteries with paths like ["BAT0", "BAT1"] if multiple batteries are present, or [] if no batteries are found
    Process {
        id: detectBatteriesProc
        command: ["sh", "-c", "ls /sys/class/power_supply/ | grep '^BAT'"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                if (output.length > 0) {
                    batteryContainer.batteries = output.split('\n')
                    batteryContainer.hasBattery = true
                } else {
                    batteryContainer.batteries = []
                    batteryContainer.hasBattery = false
                }
            }
        }
    }
    
    
    // single battery update (fallback)
    Process {
        id: batteryProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: batteryContainer.hasBattery && batteryContainer.batteries.length === 1
        
        stdout: StdioCollector {
            onStreamFinished: {
                batteryContainer.totalLevel = parseInt(String(this.data).trim())
            }
        }
    }
    
    Process {
        id: statusProc
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: batteryContainer.hasBattery && batteryContainer.batteries.length === 1
        
        stdout: StdioCollector {
            onStreamFinished: {
                batteryContainer.status = String(this.data).trim()
            }
        }
    }
    
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: {
            if (batteryContainer.batteries.length === 1) {
                batteryProc.running = true
                statusProc.running = true
            } else if (batteryContainer.batteries.length > 1) {
                updateBatteryInfo()
            }
        }
    }
    
    // Initial detection on startup
    Component.onCompleted: {
        detectBatteriesProc.running = true
    }
}