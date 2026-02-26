import Quickshell
import QtQuick
import Quickshell.Io
import "../../dropdownPanel/Data" as Dat

Item {
    id: clockContainer
    width: 150
    height: 30

    property bool showFullDate: false

        // Time display
        Item {
            id: timeItem
            anchors.centerIn: parent
            width: timeRow.width
            height: timeRow.height
            opacity: showFullDate ? 0 : 1

            Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }

        Row {
            id: timeRow
            spacing: 2
            anchors.centerIn: parent

            Text {
                id: hourText
                color: Dat.Colors.color.on_surface
                font.pixelSize: 18
                font.family: "monospace"
            }

            Text {
                text: ":"
                color: Dat.Colors.color.primary
                font.pixelSize: 18
                font.family: "monospace"
            }

            Text {
                id: minuteText
                color: Dat.Colors.color.on_surface
                font.pixelSize: 18
                font.family: "monospace"
            }

            Text {
                id: ampmText
                color: Dat.Colors.color.primary
                font.pixelSize: 18
                font.family: "monospace"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    // Full date display
    Item {
        id: fullDateItem
        anchors.centerIn: parent
        width: fullDateText.width
        height: fullDateText.height
        opacity: showFullDate ? 1 : 0

        Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Text {
        id: fullDateText
        anchors.centerIn: parent
        color: Dat.Colors.color.primary
        font.pixelSize: 14
        font.family: "monospace"
    }

}

MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: (mouse) => {
    if (mouse.button === Qt.LeftButton)
    {
        clockContainer.showFullDate = !clockContainer.showFullDate
        if (clockContainer.showFullDate)
        {
            fullDateProc.running = true
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
            hourText.text = parts[0]
            minuteText.text = parts[1]
            ampmText.text = parts[2]
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

Timer {
    interval: 60000
    running: true
    repeat: true
    onTriggered: dateProc.running = true
}
}
}
