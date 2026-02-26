import QtQuick
import QtQuick.Controls
import "../Data/" as Dat

Item {
    id: root
    
    signal clicked()
    
    width: 72
    height: 72
    
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
    
    Grid {
        anchors.centerIn: parent
        columns: 3
        rows: 3
        spacing: 3
        
        Repeater {
            model: 9
            Rectangle {
                width: 5
                height: 5
                radius: height / 2
                color: Dat.Colors.color.primary
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
