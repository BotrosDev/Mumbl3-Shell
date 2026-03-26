import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../generics"
import "../../core" as Core

PopupWindow {
    id: batteryPopup

    implicitWidth: 200
    implicitHeight: contentRoot.implicitHeight
    color: "transparent"

    property var batteryContainer: null

    // ── Positioning ────────────────────────────────────────────────────────────
    function openAt(widget) {
        batteryContainer = widget
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
                value: batteryContainer ? batteryContainer.totalLevel / 100.0 : 0.0
                text:  batteryContainer ? batteryContainer.totalLevel + "%" : "0%"
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Repeater {
                    model: ["Saver", "Balanced", "Performance"]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: 6
                        color: profArea.containsMouse ? Core.Colors.color.primary : "transparent"
                        border.color: Core.Colors.color.primary
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: profArea.containsMouse ? Core.Colors.color.on_primary : Core.Colors.color.primary
                            font.pixelSize: 11
                            font.family: "monospace"
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }

                        MouseArea {
                            id: profArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                setProfileProc.command = [
                                    "powerprofilesctl", "set",
                                    modelData.toLowerCase()
                                        .replace("saver", "power-saver")
                                ]
                                setProfileProc.running = true
                            }
                        }
                    }
                }
            }
        }
    }

    Process {
        id: setProfileProc
        running: false
    }
}
