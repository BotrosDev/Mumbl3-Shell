import Quickshell
import QtQuick
import "../widgets"
import "../../core" as Dat

PanelWindow {
    id: barWindow
    
    // Horizontal = Anchored to both Left and Right (Top or Bottom positions)
    readonly property bool isHorizontal: Dat.ThemeSettings.barPosition_L !== "" && Dat.ThemeSettings.barPosition_R !== ""
    
    anchors {
        top: Dat.ThemeSettings.barPosition_T === "top"
        bottom: Dat.ThemeSettings.barPosition_B === "bottom"
        left: Dat.ThemeSettings.barPosition_L === "left"
        right: Dat.ThemeSettings.barPosition_R === "right"
    }
    
    // Set fixed dimension on the cross-axis, 0 on the stretching axis to avoid default 100px
    implicitHeight: isHorizontal ? Dat.ThemeSettings.panelWidth : 0
    implicitWidth: isHorizontal ? 0 : Dat.ThemeSettings.panelWidth
    
    color: "transparent"

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: Dat.Colors.color.background
        opacity: Dat.ThemeSettings.transparency

        Workspace { id: workspace }
        BarClock { id: clock }

        Item {
            id: widgetsContainer
            width: isHorizontal ? widgetsLayout.width : parent.width
            height: isHorizontal ? parent.height : widgetsLayout.height

            Loader {
                id: widgetsLayout
                anchors.centerIn: parent
                sourceComponent: isHorizontal ? horizontalWidgets : verticalWidgets
            }
        }

        states: [
            State {
                name: "horizontal"
                when: isHorizontal
                AnchorChanges {
                    target: workspace
                    anchors.left: barBackground.left
                    anchors.verticalCenter: barBackground.verticalCenter
                }
                PropertyChanges {
                    target: workspace
                    anchors.leftMargin: 10
                }
                AnchorChanges {
                    target: clock
                    anchors.horizontalCenter: barBackground.horizontalCenter
                    anchors.verticalCenter: barBackground.verticalCenter
                }
                AnchorChanges {
                    target: widgetsContainer
                    anchors.right: barBackground.right
                    anchors.verticalCenter: barBackground.verticalCenter
                }
                PropertyChanges {
                    target: widgetsContainer
                    anchors.rightMargin: 10
                }
            },
            State {
                name: "vertical"
                when: !isHorizontal
                AnchorChanges {
                    target: workspace
                    anchors.top: barBackground.top
                    anchors.horizontalCenter: barBackground.horizontalCenter
                }
                PropertyChanges {
                    target: workspace
                    anchors.topMargin: 10
                }
                AnchorChanges {
                    target: clock
                    anchors.horizontalCenter: barBackground.horizontalCenter
                    anchors.verticalCenter: barBackground.verticalCenter
                }
                AnchorChanges {
                    target: widgetsContainer
                    anchors.bottom: barBackground.bottom
                    anchors.horizontalCenter: barBackground.horizontalCenter
                }
                PropertyChanges {
                    target: widgetsContainer
                    anchors.bottomMargin: 10
                }
            }
        ]
    }

    Component {
        id: horizontalWidgets
        Row {
            spacing: Dat.ThemeSettings.widgetSpacing
            WiFi { anchors.verticalCenter: parent.verticalCenter }
            Bluetooth { anchors.verticalCenter: parent.verticalCenter }
            Volume { anchors.verticalCenter: parent.verticalCenter }
            Battery { anchors.verticalCenter: parent.verticalCenter }
        }
    }

    Component {
        id: verticalWidgets
        Column {
            spacing: Dat.ThemeSettings.widgetSpacing
            WiFi { anchors.horizontalCenter: parent.horizontalCenter }
            Bluetooth { anchors.horizontalCenter: parent.horizontalCenter }
            Volume { anchors.horizontalCenter: parent.horizontalCenter }
            Battery { anchors.horizontalCenter: parent.horizontalCenter }
        }
    }
}
