import Quickshell
import QtQuick
import Quickshell.Io
import "../Data" as Dat

Item {
    id: wallpaperButton
    width: buttonRow.width + 50
    height: wallpaperButton.width
    signal clicked()

    Row {
        id: buttonRow
        spacing: 6
        anchors.centerIn: parent
        Text {
            text: "󰸉"  // Wallpaper icon
            color: Dat.Colors.color.primary
            font.pixelSize: 27
            font.family: "monospace"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Rectangle {
        anchors.fill: parent
        color: mouseArea.containsMouse ? Dat.Colors.color.surface_variant : Dat.Colors.color.surface
        radius: 4
        border.color: mouseArea.containsMouse ? "transparent" : Dat.Colors.color.primary
        z: -1

        Behavior on color {
        ColorAnimation { duration: 150 }
    }
}

MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: {
        wallpaperButton.clicked()
    }
}
}