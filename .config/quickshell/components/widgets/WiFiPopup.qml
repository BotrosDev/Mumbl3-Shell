import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../core" as Core

PopupWindow {
    id: wifiPopup

    implicitWidth: 220
    implicitHeight: contentRoot.implicitHeight
    color: "transparent"

    // Set by openAt — live reference to the WiFi widget
    property var wifiWidget: null

    // Convenience aliases so the rest of the file doesn't change
    readonly property string ssid:      wifiWidget ? wifiWidget.ssid      : ""
    readonly property int    strength:  wifiWidget ? wifiWidget.strength  : 0
    readonly property bool   connected: wifiWidget ? wifiWidget.connected : false

    // ── Positioning ────────────────────────────────────────────────────────────
    function openAt(widget) {
        wifiWidget = widget
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

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    text: {
                        if (!wifiPopup.connected) return "󰤮"
                        if (wifiPopup.strength >= 75) return "󰤨"
                        if (wifiPopup.strength >= 50) return "󰤥"
                        if (wifiPopup.strength >= 25) return "󰤢"
                        return "󰤟"
                    }
                    color: wifiPopup.connected ? Core.Colors.color.primary : Core.Colors.color.error
                    font.pixelSize: 22
                    font.family: "monospace"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.fillWidth: true
                        text: wifiPopup.connected ? wifiPopup.ssid : "Disconnected"
                        color: Core.Colors.color.on_surface
                        font.pixelSize: 13
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        visible: wifiPopup.connected
                        text: "Signal: " + wifiPopup.strength + "%"
                        color: Core.Colors.color.on_surface
                        font.pixelSize: 10
                        opacity: 0.6
                    }
                }
            }

            // Signal strength bar
            Rectangle {
                visible: wifiPopup.connected
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: Core.Colors.color.on_surface
                opacity: 0.15

                Rectangle {
                    width: parent.width * (wifiPopup.strength / 100)
                    height: parent.height
                    radius: 2
                    color: wifiPopup.strength >= 60
                        ? Core.Colors.color.primary
                        : (wifiPopup.strength >= 30 ? "#f0a500" : Core.Colors.color.error)
                    Behavior on width { NumberAnimation { duration: 300 } }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Core.Colors.color.on_surface
                opacity: 0.1
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    radius: 6
                    color: refreshArea.containsMouse ? Core.Colors.color.primary : "transparent"
                    border.color: Core.Colors.color.primary
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Refresh"
                        color: refreshArea.containsMouse ? Core.Colors.color.on_primary : Core.Colors.color.primary
                        font.pixelSize: 11
                        font.family: "monospace"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        id: refreshArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: wifiRefreshProc.running = true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 30
                    radius: 6
                    color: nmArea.containsMouse ? Core.Colors.color.primary : "transparent"
                    border.color: Core.Colors.color.primary
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Networks"
                        color: nmArea.containsMouse ? Core.Colors.color.on_primary : Core.Colors.color.primary
                        font.pixelSize: 11
                        font.family: "monospace"
                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        id: nmArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { nmProc.running = true; wifiPopup.visible = false }
                    }
                }
            }
        }
    }

    Process {
        id: wifiRefreshProc
        command: ["sh", "-c", "nmcli -t -f active,ssid,signal dev wifi | grep '^yes'"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var out = this.text.trim()
                if (out) {
                    var p = out.split(":")
                    wifiPopup.connected = true
                    wifiPopup.ssid = p[1] || "Connected"
                    wifiPopup.strength = parseInt(p[2]) || 0
                } else {
                    wifiPopup.connected = false
                    wifiPopup.ssid = "Disconnected"
                    wifiPopup.strength = 0
                }
            }
        }
    }

    Process { id: nmProc; command: ["nm-connection-editor"]; running: false }
}
