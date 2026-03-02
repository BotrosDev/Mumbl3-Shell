import QtQuick
import Quickshell
import "../dropdownPanel"
import "Data" as Dat

PanelWindow {
    id: dropdownPanel
    signal buttonClicked()

    anchors {
        top: true
        right: true
    }
    implicitHeight: 50
    implicitWidth: 50
    

    color : "transparent"  

    MouseArea {
        id: outerMouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Rectangle {
        id: dropdownButton

  
        width: 50
        height: 50
        anchors.horizontalCenter: parent.horizontalCenter
        color: mouseArea.containsMouse ? Dat.Colors.color.surface : Dat.Colors.color.surface_container
        radius: height / 2

        // State based on hover
        state: (outerMouseArea.containsMouse || mouseArea.containsMouse) ? "VISIBLE" : "HIDDEN"

        states: [
            State {
                name: "VISIBLE"
                PropertyChanges {
                    dropdownButton.y: 0
                }
            },
            State {
                name: "HIDDEN"
                PropertyChanges {
                    dropdownButton.y: -50
                }
            }
        ]

        transitions: [
            Transition {
                from: "HIDDEN"
                to: "VISIBLE"
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                    property: "y"
                }
            },
            Transition {
                from: "VISIBLE"
                to: "HIDDEN"
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutCubic
                    property: "y"
                }
            }
        ]

        Text {
            anchors.centerIn: parent
            text: isOpen ? "▲" : "▼"
            color: mouseArea.containsMouse ? Dat.Colors.color.on_background : Dat.Colors.color.background
            font.pixelSize: 23
            font.family: "monospace"
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            acceptedButtons: Qt.LeftButton
            onClicked: (mouse) => {
                if (mouse.button === Qt.LeftButton) {
                    buttonClicked()
                }

            }  
        }
    }
}