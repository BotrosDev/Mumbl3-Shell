import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../Data" as Dat

Rectangle {
    id: appWindow

    color: Dat.Colors.color.surface_variant
    radius: 12
    border.color: Dat.Colors.color.primary
    border.width: 2

    Rectangle {
        anchors.centerIn: parent
        height: appWindow.height -20
        width: appWindow.width -20
        radius: 12

        color: Dat.Colors.color.surface

        ColumnLayout {
            id: columnLayout0
            anchors {
                margins: 20
                horizontalCenter: parent.horizontalCenter
                top: parent.top
            }
            spacing: 12

            Rectangle {
                Layout.preferredWidth: appWindow.width -40
                Layout.preferredHeight: 30
                radius: 3
                border.width: 2

                color: Dat.Colors.color.surface_variant
                opacity: 0.88

                Text {
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: 10
                    }
                    color: Dat.Colors.color.on_surface
                    text: "Search smth . . ."
                    opacity: 0.80
                }
            }

            Rectangle {
                Layout.preferredWidth: appWindow.width -40
                Layout.preferredHeight: 6
                radius: 3
                border.width: 2

                color: Dat.Colors.color.surface_variant
                opacity: 0.88
            }

            Text {
                text: " we are so cooked "
                color: "white"
            }

            Text {
                text: " please note that i will NOT build this app launcher soon "
                color: "white"
            }
        }
    }
}