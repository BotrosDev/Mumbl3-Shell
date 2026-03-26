import Quickshell
import QtQuick
import "../widgets"
import "../../core" as Core

PanelWindow {
    id: barWindow
    
    // Shell-level popup references injected from shell.qml
    property var wifiPopupRef:    null
    property var btPopupRef:      null
    property var volPopupRef:     null
    property var batPopupRef:     null

    signal widgetsLoaded()

    // Horizontal = Anchored to both Left and Right (Top or Bottom positions)
    readonly property bool isHorizontal: Core.ThemeSettings.barPosition_L !== "" && Core.ThemeSettings.barPosition_R !== ""
    
    anchors {
        top: Core.ThemeSettings.barPosition_T === "top"
        bottom: Core.ThemeSettings.barPosition_B === "bottom"
        left: Core.ThemeSettings.barPosition_L === "left"
        right: Core.ThemeSettings.barPosition_R === "right"
    }
    
    // Set fixed dimension on the cross-axis, .. ty ma7moud for debugging <3
    implicitHeight: isHorizontal ? Core.ThemeSettings.barThickness : 0
    implicitWidth: isHorizontal ? 0 : Core.ThemeSettings.barThickness

    
    color: "transparent"

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: Core.Colors.color.background
        opacity: Core.ThemeSettings.transparency
        radius: 20

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
                onLoaded: barWindow.widgetsLoaded()
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
            spacing: Core.ThemeSettings.widgetSpacing
            WiFi      { anchors.verticalCenter: parent.verticalCenter; popup: barWindow.wifiPopupRef }
            Bluetooth { anchors.verticalCenter: parent.verticalCenter; popup: barWindow.btPopupRef   }
            Volume    { anchors.verticalCenter: parent.verticalCenter; popup: barWindow.volPopupRef  }
            Battery   { anchors.verticalCenter: parent.verticalCenter; popup: barWindow.batPopupRef  }
        }
    }

    Component {
        id: verticalWidgets
        Column {
            spacing: Core.ThemeSettings.widgetSpacing
            WiFi      { anchors.horizontalCenter: parent.horizontalCenter; popup: barWindow.wifiPopupRef }
            Bluetooth { anchors.horizontalCenter: parent.horizontalCenter; popup: barWindow.btPopupRef   }
            Volume    { anchors.horizontalCenter: parent.horizontalCenter; popup: barWindow.volPopupRef  }
            Battery   { anchors.horizontalCenter: parent.horizontalCenter; popup: barWindow.batPopupRef  }
        }
    }
}
