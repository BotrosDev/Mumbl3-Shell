import Quickshell
import QtQuick
import Quickshell.Io
import "../../core" as Dat

Item {
    id: clockContainer
    
    readonly property bool isHorizontal: Dat.ThemeSettings.barPosition_L !== "" && Dat.ThemeSettings.barPosition_R !== ""
    
    width: isHorizontal ? 150 : Dat.ThemeSettings.panelWidth
    height: isHorizontal ? 30 : 80

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
                Text { id: hourText; color: Dat.Colors.color.on_surface; font.pixelSize: 18; font.family: Dat.ThemeSettings.fontFamily }
                Text { text: ":"; color: Dat.Colors.color.primary; font.pixelSize: 18; font.family: Dat.ThemeSettings.fontFamily }
                Text { id: minuteText; color: Dat.Colors.color.on_surface; font.pixelSize: 18; font.family: Dat.ThemeSettings.fontFamily }
                Text { id: ampmText; color: Dat.Colors.color.primary; font.pixelSize: 12; font.family: Dat.ThemeSettings.fontFamily; anchors.verticalCenter: parent.verticalCenter }
            }

            Column {
                id: verticalTime
                visible: !isHorizontal
                spacing: 2
                anchors.centerIn: parent
                Text { text: hourText.text; color: Dat.Colors.color.on_surface; font.pixelSize: 16; font.bold: true; font.family: Dat.ThemeSettings.fontFamily; anchors.horizontalCenter: parent.horizontalCenter }
                Text { text: minuteText.text; color: Dat.Colors.color.primary; font.pixelSize: 16; font.family: Dat.ThemeSettings.fontFamily; anchors.horizontalCenter: parent.horizontalCenter }
            }
        }

        // Date View
        Text {
            id: fullDateText
            anchors.centerIn: parent
            opacity: showFullDate ? 1 : 0
            color: Dat.Colors.color.primary
            font.pixelSize: isHorizontal ? 14 : 10
            font.family: Dat.ThemeSettings.fontFamily
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
