import Quickshell
import QtQuick
import "../widgets"
import "../../dropdownPanel/Data" as Dat

PanelWindow {
    anchors {
        bottom: true
        left: true
        right: true
    }
    implicitHeight: 35
    color: "transparent"

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: Dat.Colors.color.background

        Workspace {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
        }

        BarClock {
            anchors.centerIn: parent
            anchors.verticalCenter: parent.verticalCenter
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 20

            Row {
                spacing: 32
                anchors.verticalCenter: parent.verticalCenter

                WiFi {
                    anchors.verticalCenter: parent.verticalCenter
                }

                Bluetooth {
                    anchors.verticalCenter: parent.verticalCenter
                }

                Volume {
                    anchors.verticalCenter: parent.verticalCenter
                }

                Battery {
                    id: battery
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}