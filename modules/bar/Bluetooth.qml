import Quickshell
import QtQuick
import Quickshell.Io
import "../../dropdownPanel/Data" as Dat

Item {
    id: bluetoothContainer
    width: btIcon.width
    height: btIcon.height
    
    property bool enabled: false
    property bool connected: false
    property string deviceName: ""
    
    Text {
        id: btIcon
        text: {
            if (!enabled) return "󰂲" 
            if (connected) return "󰂱" 
            return "󰂯" 
        }
        color: {
            if (connected) return Dat.Colors.color.primary
            if (enabled) return Dat.Colors.color.error
            return Dat.Colors.color.error
        }
        font.pixelSize: 16
        font.family: "monospace"
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
             toggleProc.running = true
        }
    }

    Process {
    id: toggleProc
    command: ["blueman-manager"]
    }

    
    // Check if Bluetooth is enabled
    Process {
        id: btStatusProc
        command: ["sh", "-c", "bluetoothctl show | grep 'Powered: yes'"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                bluetoothContainer.enabled = this.text.trim().length > 0
                if (bluetoothContainer.enabled) {
                    btConnectedProc.running = true
                }
            }
        }
    }
    
    // Check if any device is connected
    Process {
        id: btConnectedProc
        command: ["sh", "-c", "bluetoothctl devices Connected | wc -l"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                var count = parseInt(this.text.trim())
                bluetoothContainer.connected = count > 0
            }
        }
    }
    
    // Update every 10 seconds
    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: btStatusProc.running = true
    }
}