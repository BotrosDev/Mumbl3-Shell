import Quickshell
import QtQuick
import Quickshell.Io
import "../../core" as Core

Item {
    id: wifiContainer
    // Scales with bar thickness; stays comfortably inside the bar
    readonly property int pillHeight: Math.max(18, Math.min(Core.ThemeSettings.barThickness - 14, 40))
    width: pillHeight
    height: pillHeight

    property string ssid: "Disconnected"
    property int strength: 0
    property bool connected: false

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: width / 2
        color: wifiMouseArea.containsMouse ? Core.Colors.color.primary : "transparent"
        border.color: connected ? Core.Colors.color.primary : Core.Colors.color.error
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Text {
        id: wifiIcon
        anchors.centerIn: parent
        text: {
            if (!connected) return "󰤮"
            if (strength >= 75) return "󰤨"
            if (strength >= 50) return "󰤥"
            if (strength >= 25) return "󰤢"
            return "󰤟"
        }
        color: wifiMouseArea.containsMouse
            ? Core.Colors.color.on_primary
            : (connected ? Core.Colors.color.primary : Core.Colors.color.error)
        font.pixelSize: Math.max(10, wifiContainer.pillHeight - 12)
        font.family: "monospace"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    // Provided by Bar.qml from the shell-level instance
    property var popup: null

    MouseArea {
        id: wifiMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (!popup) return
            popup.visible ? popup.visible = false : popup.openAt(wifiContainer)
        }
    }

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
