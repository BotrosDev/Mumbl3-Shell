import Quickshell
import QtQuick
import Quickshell.Io
import "../../dropdownPanel/Data" as Dat

Item {
    id: wifiContainer
    width: wifiRow.width
    height: wifiRow.height
    
    property string ssid: "Disconnected"
    property int strength: 0
    property bool connected: false
    
    Row {
        id: wifiRow
        spacing: 5
        Text {
            id: wifiIcon
            text: {
                if (!connected) return "󰤮"
                if (strength >= 75) return "󰤨"
                if (strength >= 50) return "󰤥"
                if (strength >= 25) return "󰤢"
                return "󰤟"
            }
            color: connected ? Dat.Colors.color.primary : Dat.Colors.color.on_primary
            font.pixelSize: 16
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Process {
    id: wifiManagerProc
    command: ["sh", "-c", "nm-connection-editor"]
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            wifiManagerProc.running = true
        }
    }
    
    // Get WiFi status
    Process {
        id: wifiProc
        command: ["sh", "-c", "nmcli -t -f active,ssid,signal dev wifi | grep '^yes'"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                if (output) {
                    var parts = output.split(":")
                    wifiContainer.connected = true
                    wifiContainer.ssid = parts[1] || "Connected"
                    wifiContainer.strength = parseInt(parts[2]) || 0
                } else {
                    wifiContainer.connected = false
                    wifiContainer.ssid = "Disconnected"
                    wifiContainer.strength = 0
                }
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                // If nmcli fails, try iwgetid as fallback
                if (this.text.trim().length > 0) {
                    wifiContainer.connected = false
                }
            }
        }
    }
    
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: wifiProc.running = true
    }
}