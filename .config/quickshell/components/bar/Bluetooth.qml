import Quickshell
import QtQuick
import Quickshell.Io
import "../../core" as Core

Item {
    id: bluetoothContainer
    readonly property int pillHeight: Math.max(18, Math.min(Core.ThemeSettings.barThickness - 14, 40))
    width: pillHeight
    height: pillHeight

    property bool enabled: false
    property bool connected: false
    property string deviceName: ""

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: width / 2
        color: btMouseArea.containsMouse ? Core.Colors.color.primary : "transparent"
        border.color: connected
            ? Core.Colors.color.primary
            : Core.Colors.color.error
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    Text {
        id: btIcon
        anchors.centerIn: parent
        text: {
            if (!enabled) return "󰂲"
            if (connected) return "󰂱"
            return "󰂯"
        }
        color: btMouseArea.containsMouse
            ? Core.Colors.color.on_primary
            : (connected ? Core.Colors.color.primary : Core.Colors.color.error)
        font.pixelSize: Math.max(10, bluetoothContainer.pillHeight - 12)
        font.family: "monospace"

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
    }

    property var popup: null

    MouseArea {
        id: btMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (!popup) return
            popup.visible ? popup.visible = false : popup.openAt(bluetoothContainer)
        }
    }

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

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: btStatusProc.running = true
    }
}
