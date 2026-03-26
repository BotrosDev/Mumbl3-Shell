import Quickshell
import QtQuick
import Quickshell.Io
import "../../core" as Core

Item {
    id: batteryContainer
    visible: hasBattery

    property var batteries: []
    property bool hasBattery: false
    property int totalLevel: 0
    property string status: "Unknown"
    readonly property bool isCharging: status === "Charging"
    readonly property bool isCritical: totalLevel <= 15 && !isCharging
    readonly property bool isHorizontal: Core.ThemeSettings.barPosition_L !== "" && Core.ThemeSettings.barPosition_R !== ""
    readonly property bool isVertical: !isHorizontal

    // ── size: circle in vertical mode, pill in horizontal mode ───────────────
    // Drive container size directly — no reference to child geometry, no binding loop.
    readonly property int pillHeight: Math.max(18, Math.min(Core.ThemeSettings.barThickness - 14, 40))
    readonly property int pillWidth: isVertical
        ? pillHeight
        : (batteryInnerRow.implicitWidth + 18)

    width:  hasBattery ? pillWidth  : 0
    height: hasBattery ? pillHeight : 0

    function updateBatteryInfo() {
        if (batteries.length >= 1) {
            batteryProc.running = true
            statusProc.running = true
        }
    }

    // ── pill background ──────────────────────────────────────────────────────
    Rectangle {
        id: batteryPill
        anchors.fill: parent
        // circle in vertical mode, stadium pill in horizontal
        radius: isVertical ? width / 2 : height / 2

        color: {
            if (isCritical) return Core.Colors.color.error
            if (batMouseArea.containsMouse) return Core.Colors.color.primary
            return "transparent"
        }
        border.color: isCritical ? Core.Colors.color.error : Core.Colors.color.primary
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 120 }
        }

        // ── content row ───────────────────────────────────────────────────────
        Row {
            id: batteryInnerRow
            anchors.centerIn: parent
            spacing: 4

            Image {
                id: batteryImage
                visible: batteryContainer.hasBattery
                width: Math.round(batteryContainer.pillHeight * 0.5)
                height: Math.round(batteryContainer.pillHeight * 0.5)
                anchors.verticalCenter: parent.verticalCenter

                source: {
                    var level = batteryContainer.totalLevel
                    var stat  = batteryContainer.status
                    var base  = "../../theme/images/theme-light/"

                    if (level >= 100) return base + (stat === "Charging" ? "battery-100-charged.svg" : "battery-100.svg")
                    if (level >= 90)  return base + (stat === "Charging" ? "battery-090-charging.svg" : "battery-090.svg")
                    if (level >= 80)  return base + (stat === "Charging" ? "battery-080-charging.svg" : "battery-080.svg")
                    if (level >= 70)  return base + (stat === "Charging" ? "battery-070-charging.svg" : "battery-070.svg")
                    if (level >= 60)  return base + (stat === "Charging" ? "battery-060-charging.svg" : "battery-060.svg")
                    if (level >= 50)  return base + (stat === "Charging" ? "battery-050-charging.svg" : "battery-050.svg")
                    if (level >= 40)  return base + (stat === "Charging" ? "battery-040-charging.svg" : "battery-040.svg")
                    if (level >= 30)  return base + (stat === "Charging" ? "battery-030-charging.svg" : "battery-030.svg")
                    if (level >= 20)  return base + (stat === "Charging" ? "battery-020-charging.svg" : "battery-020.svg")
                    if (level >= 10)  return base + (stat === "Charging" ? "battery-010-charging.svg" : "battery-010.svg")
                    return base + (stat === "Charging" ? "battery-000-charging.svg" : "battery-000.svg")
                }
            }

            // % label — hidden in vertical mode, bar is too narrow for it
            Text {
                id: batteryPercent
                visible: !isVertical
                anchors.verticalCenter: parent.verticalCenter
                text: batteryContainer.totalLevel + "%"
                color: {
                    if (isCritical || batMouseArea.containsMouse) return Core.Colors.color.on_primary
                    return Core.Colors.color.primary
                }
                font.pixelSize: Math.max(8, batteryContainer.pillHeight - 17)
                font.family: "monospace"

                Behavior on color {
                    ColorAnimation { duration: 120 }
                }
            }

            // Multi-battery indicator — also hidden in vertical mode
            Text {
                visible: !isVertical && batteryContainer.batteries.length > 1
                anchors.verticalCenter: parent.verticalCenter
                text: "×" + batteryContainer.batteries.length
                color: Core.Colors.color.on_primary
                font.pixelSize: Math.max(7, batteryContainer.pillHeight - 21)
                font.family: "monospace"
            }
        }
    }

    property var popup: null

    MouseArea {
        id: batMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (!popup) return
            popup.visible ? popup.visible = false : popup.openAt(batteryContainer)
        }
    }

    // ── processes ────────────────────────────────────────────────────────────

    Process {
        id: detectBatteriesProc
        command: ["sh", "-c", "ls /sys/class/power_supply/ | grep '^BAT'"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                if (output.length > 0) {
                    batteryContainer.batteries = output.split('\n')
                    batteryContainer.hasBattery = true
                    updateBatteryInfo()
                } else {
                    batteryContainer.batteries = []
                    batteryContainer.hasBattery = false
                }
            }
        }
    }

    Process {
        id: batteryProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                batteryContainer.totalLevel = parseInt(String(this.data).trim())
            }
        }
    }

    Process {
        id: statusProc
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                batteryContainer.status = String(this.data).trim()
            }
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: updateBatteryInfo()
    }

    Component.onCompleted: {
        detectBatteriesProc.running = true
    }
}