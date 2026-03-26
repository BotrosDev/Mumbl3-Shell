import Quickshell
import QtQuick
import Quickshell.Io
import "../../core" as Core

Item {
    id: clockContainer
    
    readonly property bool isHorizontal: Core.ThemeSettings.barPosition_L !== "" && Core.ThemeSettings.barPosition_R !== ""
    
    width: isHorizontal ? 150 : Core.ThemeSettings.barThickness
    height: isHorizontal ? Core.ThemeSettings.barThickness : 80

    property bool showFullDate: false

    Item {
        anchors.fill: parent
        
        // Time View
        Item {
            anchors.fill: parent
            opacity: showFullDate ? 0 : 1
            Behavior on opacity { NumberAnimation { duration: 200 } }

            // Use visibility to swap layouts
            Row {
                id: horizontalTime
                visible: isHorizontal
                spacing: 2
                anchors.centerIn: parent
                Text { id: hourText; color: Core.Colors.color.on_surface; font.pixelSize: Math.max(12, Core.ThemeSettings.barThickness * 0.4); font.family: Core.ThemeSettings.fontFamily }
                Text { text: ":"; color: Core.Colors.color.primary; font.pixelSize: Math.max(12, Core.ThemeSettings.barThickness * 0.4); font.family: Core.ThemeSettings.fontFamily }
                Text { id: minuteText; color: Core.Colors.color.on_surface; font.pixelSize: Math.max(12, Core.ThemeSettings.barThickness * 0.4); font.family: Core.ThemeSettings.fontFamily }
                Text { id: ampmText; color: Core.Colors.color.primary; font.pixelSize: Math.max(8, Core.ThemeSettings.barThickness * 0.25); font.family: Core.ThemeSettings.fontFamily; anchors.verticalCenter: parent.verticalCenter }
            }

            Column {
                id: verticalTime
                visible: !isHorizontal
                spacing: 2
                anchors.centerIn: parent
                Text { text: hourText.text; color: Core.Colors.color.on_surface; font.pixelSize: Math.max(10, Core.ThemeSettings.barThickness * 0.35); font.bold: true; font.family: Core.ThemeSettings.fontFamily; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: minuteText.text; color: Core.Colors.color.primary; font.pixelSize: Math.max(10, Core.ThemeSettings.barThickness * 0.35); font.family: Core.ThemeSettings.fontFamily; anchors.horizontalCenter: parent.horizontalCenter }
            }
        }

        // Date View
        Text {
            id: fullDateText
            anchors.centerIn: parent
            opacity: showFullDate ? 1 : 0
            color: Core.Colors.color.primary
            font.pixelSize: isHorizontal ? Math.max(10, Core.ThemeSettings.barThickness * 0.3) : Math.max(8, Core.ThemeSettings.barThickness * 0.2)
            font.family: Core.ThemeSettings.fontFamily
            horizontalAlignment: Text.AlignHCenter
            wrapMode: isHorizontal ? Text.NoWrap : Text.WordWrap
            width: parent.width - 4
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: (mouse) => {
            if (mouse.button === Qt.LeftButton) {
                clockContainer.showFullDate = !clockContainer.showFullDate
                if (clockContainer.showFullDate) fullDateProc.running = true
            }
        }
    }

    Process {
        id: dateProc
        command: ["date", "+%I %M %p"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var parts = this.text.trim().split(" ")
                if (parts.length >= 3) {
                    hourText.text = parts[0]
                    minuteText.text = parts[1]
                    ampmText.text = parts[2]
                }
            }
        }
    }

    Process { 
        id: fullDateProc
        command: ["date", "+%A, %B %d, %Y"]
        running: false
        stdout: StdioCollector { 
            onStreamFinished: fullDateText.text = this.text.trim() 
        } 
    }

    Timer { interval: 60000; running: true; repeat: true; onTriggered: dateProc.running = true }
}
