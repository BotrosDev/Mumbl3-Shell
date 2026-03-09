import Quickshell
import QtQuick
import Quickshell.Hyprland
import "../../core" as Dat 

Rectangle {
    id: wsContainer
    
    readonly property bool isHorizontal: Dat.ThemeSettings.barPosition_L !== "" && Dat.ThemeSettings.barPosition_R !== ""
    
    // Size based on content and orientation
    width: isHorizontal ? (loader.item ? loader.item.width + 20 : 120) : 36
    height: isHorizontal ? 28 : (loader.item ? loader.item.height + 20 : 120)
    
    radius: 14
    color: Dat.Colors.color.primary
    
    property bool expanded: false
    property int totalWorkspaces: 10
    property int visibleWorkspaces: expanded ? totalWorkspaces : 5
    
    Behavior on width { NumberAnimation { duration: 250 } }
    Behavior on height { NumberAnimation { duration: 250 } }
    
    Loader {
        id: loader
        anchors.centerIn: parent
        sourceComponent: isHorizontal ? horizontalLayout : verticalLayout
    }

    Component {
        id: horizontalLayout
        Row {
            spacing: 10
            Repeater { model: wsContainer.visibleWorkspaces; delegate: workspaceDelegate }
            Loader { sourceComponent: expandButtonComponent }
        }
    }

    Component {
        id: verticalLayout
        Column {
            spacing: 10
            Repeater { model: wsContainer.visibleWorkspaces; delegate: workspaceDelegate }
            Loader { sourceComponent: expandButtonComponent }
        }
    }

    Component {
        id: workspaceDelegate
        Rectangle {
            id: wsItem
            property bool isFocused: Hyprland.focusedWorkspace ? (index + 1) === Hyprland.focusedWorkspace.id : false
            property bool hasWindows: {
                var workspaces = Hyprland.workspaces
                for (var i in workspaces) if (workspaces[i].id === (index + 1)) return workspaces[i].windows.length > 0
                return false
            }
            
            // Layout is fixed per dot, but their dimensions swap based on orientation
            width: isHorizontal ? (isFocused ? 32 : (hasWindows ? 18 : 14)) : 12
            height: isHorizontal ? 12 : (isFocused ? 32 : (hasWindows ? 18 : 14))
            
            radius: 10
            color: isFocused ? Dat.Colors.color.on_surface : (hasWindows ? Dat.Colors.color.surface_variant : Dat.Colors.color.on_surface)

            Behavior on width { NumberAnimation { duration: 250 } }
            Behavior on height { NumberAnimation { duration: 250 } }
            
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) Hyprland.dispatch("workspace " + (index + 1))
                    else wsContainer.expanded = !wsContainer.expanded
                }
            }
        }
    }

    Component {
        id: expandButtonComponent
        Rectangle {
            width: isHorizontal ? 14 : 12
            height: isHorizontal ? 12 : 14
            radius: 10
            color: Dat.Colors.color.inverse_primary
            Text { 
                anchors.centerIn: parent
                text: wsContainer.expanded ? "−" : "+"
                color: Dat.Colors.color.on_surface
                font.pixelSize: 10
                font.bold: true 
            }
            MouseArea { 
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: wsContainer.expanded = !wsContainer.expanded 
            }
        }
    }
}
