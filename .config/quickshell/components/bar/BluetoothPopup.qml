import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../core" as Core

PopupWindow {
    id: btPopup

    implicitWidth: 220
    implicitHeight: contentRoot.implicitHeight
    color: "transparent"

    property var btWidget: null

    readonly property bool   btEnabled:  btWidget ? btWidget.enabled   : false
    readonly property bool   btConnected: btWidget ? btWidget.connected : false
    readonly property string deviceName: btWidget ? btWidget.deviceName : ""

    // ── Positioning ────────────────────────────────────────────────────────────
    function openAt(widget) {
        btWidget = widget
        anchor.item = widget

        var isHorizontal = Core.ThemeSettings.barPosition_L !== "" && Core.ThemeSettings.barPosition_R !== ""
        var isTop  = Core.ThemeSettings.barPosition_T === "top"
        var isLeft = Core.ThemeSettings.barPosition_L === "left" && Core.ThemeSettings.barPosition_R === ""

        if (isHorizontal && isTop) {
            anchor.edges   = Edges.Bottom
            anchor.gravity = Edges.Bottom
        } else if (isHorizontal && !isTop) {
            anchor.edges   = Edges.Top
            anchor.gravity = Edges.Top
        } else if (isLeft) {
            anchor.edges   = Edges.Right
            anchor.gravity = Edges.Right
        } else {
            anchor.edges   = Edges.Left
            anchor.gravity = Edges.Left
        }

        visible = true
    }

    // ── Visual ─────────────────────────────────────────────────────────────────
    Rectangle {
        id: contentRoot
        anchors.fill: parent
        color: Core.Colors.color.surface
        radius: 12
        border.color: Core.Colors.color.primary
        border.width: 1
        implicitHeight: col.implicitHeight + 32

        ColumnLayout {
            id: col
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 16 }
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: {
                        if (!btPopup.btEnabled) return "󰂲"
                        if (btPopup.btConnected) return "󰂱"
                        return "󰂯"
                    }
                    color: btPopup.btConnected ? Core.Colors.color.primary : Core.Colors.color.error
                    font.pixelSize: 22
                    font.family: "monospace"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: {
                            if (!btPopup.btEnabled) return "Bluetooth Off"
                            if (btPopup.btConnected) return btPopup.deviceName || "Device Connected"
                            return "Not Connected"
                        }
                        color: Core.Colors.color.on_surface
                        font.pixelSize: 13
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: btPopup.btEnabled ? "Powered on" : "Powered off"
                        color: Core.Colors.color.on_surface
                        font.pixelSize: 10
                        opacity: 0.6
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Core.Colors.color.on_surface
                opacity: 0.1
            }

            // Power toggle row
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Power"
                    color: Core.Colors.color.on_surface
                    font.pixelSize: 11
                    opacity: 0.7
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 48
                    height: 24
                    radius: 12
                    color: btPopup.btEnabled ? Core.Colors.color.primary : "transparent"
                    border.color: Core.Colors.color.primary
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Rectangle {
                        width: 16; height: 16; radius: 8
                        anchors.verticalCenter: parent.verticalCenter
                        x: btPopup.btEnabled ? parent.width - width - 4 : 4
                        color: btPopup.btEnabled ? Core.Colors.color.on_primary : Core.Colors.color.primary
                        Behavior on x     { NumberAnimation  { duration: 150 } }
                        Behavior on color { ColorAnimation   { duration: 150 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: btToggleProc.running = true
                    }
                }
            }

            // Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    radius: 6
                    color: devicesArea.containsMouse ? Core.Colors.color.primary : "transparent"
                    border.color: Core.Colors.color.primary
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Devices"
                        color: devicesArea.containsMouse ? Core.Colors.color.on_primary : Core.Colors.color.primary
                        font.pixelSize: 11
                        font.family: "monospace"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        id: devicesArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { bluemanProc.running = true; btPopup.visible = false }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    radius: 6
                    visible: btPopup.btConnected
                    color: disconnectArea.containsMouse ? Core.Colors.color.error : "transparent"
                    border.color: Core.Colors.color.error
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Disconnect"
                        color: disconnectArea.containsMouse ? Core.Colors.color.on_primary : Core.Colors.color.error
                        font.pixelSize: 11
                        font.family: "monospace"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        id: disconnectArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: btDisconnectProc.running = true
                    }
                }
            }
        }
    }

    Process {
        id: btToggleProc
        command: ["sh", "-c", "bluetoothctl show | grep -q 'Powered: yes' && bluetoothctl power off || bluetoothctl power on"]
        running: false
        onRunningChanged: if (!running) btRefreshProc.running = true
    }

    Process {
        id: btDisconnectProc
        command: ["sh", "-c", "bluetoothctl devices Connected | awk '{print $2}' | xargs -I{} bluetoothctl disconnect {}"]
        running: false
        onRunningChanged: if (!running) btRefreshProc.running = true
    }

    Process {
        id: btRefreshProc
        command: ["sh", "-c", "bluetoothctl show | grep 'Powered: yes'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                btPopup.btEnabled = this.text.trim().length > 0
                if (btPopup.btEnabled) btDeviceProc.running = true
            }
        }
    }

    Process {
        id: btDeviceProc
        command: ["sh", "-c", "bluetoothctl devices Connected | head -1 | cut -d' ' -f3-"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var name = this.text.trim()
                btPopup.btConnected = name.length > 0
                btPopup.deviceName  = name
            }
        }
    }

    Process { id: bluemanProc; command: ["blueman-manager"]; running: false }
}
