import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../generics"
import "../../core" as Core

PopupWindow {
    id: volumePopup

    implicitWidth: 200
    implicitHeight: contentRoot.implicitHeight
    color: "transparent"

    // Bound to the Volume widget
    property var volumeContainer: null

    // ── Positioning ────────────────────────────────────────────────────────────
    function openAt(widget) {
        volumeContainer = widget
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
            spacing: 15

            CircularProgress {
                Layout.alignment: Qt.AlignHCenter
                width: 120
                height: 120
                value: volumeContainer ? volumeContainer.volume / 100.0 : 0.0
                text:  volumeContainer ? volumeContainer.volume + "%" : "0%"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: [
                        { label: "Mute",  cmd: null },
                        { label: "50%",   cmd: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "50%"] },
                        { label: "100%",  cmd: ["pactl", "set-sink-volume", "@DEFAULT_SINK@", "100%"] }
                    ]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 6
                        color: btnArea.containsMouse ? Core.Colors.color.primary : "transparent"
                        border.color: Core.Colors.color.primary
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            color: btnArea.containsMouse ? Core.Colors.color.on_primary : Core.Colors.color.primary
                            font.pixelSize: 11
                            font.family: "monospace"
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: btnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (modelData.label === "Mute") {
                                    muteProc.running = true
                                } else {
                                    setVolumeProc.command = modelData.cmd
                                    setVolumeProc.running = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: muteProc
        command: ["pactl", "set-sink-mute", "@DEFAULT_SINK@", "toggle"]
        running: false
        onRunningChanged: if (!running && volumeContainer) volumeContainer.updateVolume()
    }

    Process {
        id: setVolumeProc
        running: false
        onRunningChanged: if (!running && volumeContainer) volumeContainer.updateVolume()
    }
}
