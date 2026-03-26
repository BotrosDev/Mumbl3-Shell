import Quickshell
import QtQuick
import Quickshell.Io
import "../../core" as Core

Item {
    id: volumeContainer
    readonly property int pillHeight: Math.max(18, Math.min(Core.ThemeSettings.barThickness - 14, 40))
    width: pillHeight
    height: pillHeight

    property int volume: 0
    property bool muted: false
    readonly property bool isVertical: Core.ThemeSettings.barPosition_L !== "" && Core.ThemeSettings.barPosition_R === ""

    function updateVolume() {
        volumeProc.running = true
        muteStatusProc.running = true
    }

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: width / 2
        color: volMouseArea.containsMouse ? Core.Colors.color.primary : "transparent"
        border.color: muted ? Core.Colors.color.error : Core.Colors.color.primary
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Text {
        id: volumeIcon
        anchors.centerIn: parent
        text: {
            if (muted) return "󰖁"
            if (volume >= 70) return "󰕾"
            if (volume >= 30) return "󰖀"
            if (volume > 0) return "󰕿"
            return "󰖁"
        }
        color: volMouseArea.containsMouse
            ? Core.Colors.color.on_primary
            : (muted ? Core.Colors.color.error : Core.Colors.color.primary)
        font.pixelSize: Math.max(10, volumeContainer.pillHeight - 12)
        font.family: "monospace"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    property var popup: null

    MouseArea {
        id: volMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (!popup) return
            popup.visible ? popup.visible = false : popup.openAt(volumeContainer)
        }
    }

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
                if (this.text.trim().length > 0) {
                    amixerProc.running = true
                }
            }
        }
    }

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

    Process {
        id: volumeUpProc
        command: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "+5%"]
        running: false

        onRunningChanged: {
            if (!running) volumeProc.running = true
        }
    }

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
