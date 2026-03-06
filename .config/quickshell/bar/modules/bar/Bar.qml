import Quickshell
import QtQuick
import "../widgets"
import "../../dropdownPanel/Data" as Dat

PanelWindow {
    anchors {
        top: Dat.ThemeSettings.barPosition === "top"
        bottom: Dat.ThemeSettings.barPosition === "bottom"
        left: true
        right: true
    }
    implicitHeight: Dat.ThemeSettings.panelWidth
    color: "transparent"

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: Dat.Colors.color.background
        opacity: Dat.ThemeSettings.transparency

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
            spacing: Dat.ThemeSettings.widgetSpacing

            Row {
                spacing: Dat.ThemeSettings.widgetSpacing * 2 // Keep some relative scaling
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