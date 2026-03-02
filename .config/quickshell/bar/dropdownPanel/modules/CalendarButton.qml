import QtQuick
import QtQuick.Controls
import "../Data/" as Dat

Item {
    id: root
    
    signal clicked()
    
    width: 73
    height: 73
    
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

    
    Text {
        anchors.centerIn: parent
        text: "" // Calendar emoji
        font.pixelSize: 27
        color: Dat.Colors.color.primary
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
