import Quickshell
import QtQuick
import Quickshell.Io
import "../../dropdownPanel/Data" as Dat

Item {
    id: volumeContainer
    width: volumeRow.width
    height: volumeRow.height
    
    property int volume: 0
    property bool muted: false
    
    Row {
        id: volumeRow
        spacing: 5
        
        Text {
            id: volumeIcon
            text: {
                if (muted) return "󰖁"
                if (volume >= 70) return "󰕾"
                if (volume >= 30) return "󰖀"
                if (volume > 0) return "󰕿"
                return "󰖁"
            }
            color: muted ? Dat.Colors.color.on_primary : Dat.Colors.color.primary
            font.pixelSize: 16
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            id: volumeText
            text: volume + "%"
            color: Dat.Colors.color.on_surface
            font.pixelSize: 12
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            muteProc.running = true
        }
        
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                volumeUpProc.running = true
            } else {
                volumeDownProc.running = true
            }
        }
    }
    
    // Get current volume using pactl (PulseAudio/PipeWire)
    Process {
        id: volumeProc
        command: ["sh", "-c", "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                var vol = parseInt(this.text.trim())
                volumeContainer.volume = isNaN(vol) ? 0 : vol
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                // Fallback to amixer if pactl fails
                if (this.text.trim().length > 0) {
                    amixerProc.running = true
                }
            }
        }
    }
    
    // Fallback to amixer
    Process {
        id: amixerProc
        command: ["sh", "-c", "amixer get Master | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                var vol = parseInt(this.text.trim())
                volumeContainer.volume = isNaN(vol) ? 0 : vol
            }
        }
    }
    
    // Check mute status
    Process {
        id: muteStatusProc
        command: ["sh", "-c", "pactl get-sink-mute @DEFAULT_SINK@ | grep -q 'yes' && echo 1 || echo 0"]
        running: true
        
        stdout: StdioCollector {
            onStreamFinished: {
                volumeContainer.muted = parseInt(this.text.trim()) === 1
            }
        }
    }
    
    // Toggle mute
    Process {
        id: muteProc
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
        running: false
        
        onRunningChanged: {
            if (!running) {
                muteStatusProc.running = true
                volumeProc.running = true
            }
        }
    }
    
    // Increase volume
    Process {
        id: volumeUpProc
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%"]
        running: false
        
        onRunningChanged: {
            if (!running) volumeProc.running = true
        }
    }
    
    // Decrease volume
    Process {
        id: volumeDownProc
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "-5%"]
        running: false
        
        onRunningChanged: {
            if (!running) volumeProc.running = true
        }
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            volumeProc.running = true
            muteStatusProc.running = true
        }
    }
}