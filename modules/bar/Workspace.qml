import Quickshell
import QtQuick
import Quickshell.Hyprland
import "../../dropdownPanel/Data" as Dat 

Rectangle {
    id: wsContainer
    width: wsRow.width + 20
    height: wsRow.height + 7
    radius: 14
    color: Dat.Colors.color.primary
    
    property bool expanded: false
    property int totalWorkspaces: 10
    property int visibleWorkspaces: expanded ? totalWorkspaces : 5
    
    readonly property int animDuration: 250
    readonly property int animDurationFast: 150
    readonly property var animEasing: Easing.OutCubic
    
    Behavior on width {
        NumberAnimation {
            duration: animDuration
            easing.type: animEasing
        }
    }
    
    Row {
        id: wsRow
        anchors.centerIn: parent
        spacing: 10
        
        Repeater {
            model: wsContainer.visibleWorkspaces
            delegate: Rectangle {
                id: wsItem
                
                property bool isFocused: {
                    var focused = Hyprland.focusedWorkspace
                    return focused ? (index + 1) === focused.id : false
                }
                
                property bool hasWindows: {
                    // Check if workspace has windows
                    var workspaces = Hyprland.workspaces
                    for (var i in workspaces) {
                        if (workspaces[i].id === (index + 1)) {
                            return workspaces[i].windows.length > 0
                        }
                    }
                    return false
                }
                
                width: isFocused ? 32 : (hasWindows ? 18 : 14)
                height: 12
                radius: 10
                color: {
                    if (isFocused) return Dat.Colors.color.on_surface
                    if (hasWindows) return Dat.Colors.color.surface_varient
                    return Dat.Colors.color.on_surface
                }
   
                Behavior on width {
                    NumberAnimation {
                        duration: wsContainer.animDuration
                        easing.type: wsContainer.animEasing
                    }
                }
                
                Behavior on color {
                    ColorAnimation {
                        duration: wsContainer.animDuration
                        easing.type: wsContainer.animEasing
                    }
                }
                
                Behavior on border.width {
                    NumberAnimation {
                        duration: wsContainer.animDuration
                        easing.type: wsContainer.animEasing
                    }
                }
                
                // Workspace number indicator
                // Text {
                //     id: wsText
                //     visible: isFocused || (hasWindows && wsContainer.expanded)
                //     anchors.centerIn: parent
                //     text: index + 1
                //     color: isFocused ? "#ffffff" : "#c0caf5"
                //     font.pixelSize: isFocused ? 9 : 8
                //     font.bold: isFocused
                //     font.family: "monospace"
                    
                //     Behavior on color {
                //         ColorAnimation {
                //             duration: wsContainer.animDuration
                //             easing.type: wsContainer.animEasing
                //         }
                //     }
                    
                //     Behavior on font.pixelSize {
                //         NumberAnimation {
                //             duration: wsContainer.animDuration
                //             easing.type: wsContainer.animEasing
                //         }
                //     }
                // }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    
                    onEntered: {
                        if (!isFocused) {
                            wsItem.scale = 1.15
                        }
                    }
                    
                    onExited: {
                        wsItem.scale = 1.0
                    }
                    
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.LeftButton) {
                            Hyprland.dispatch("workspace " + (index + 1))
                        } else if (mouse.button === Qt.RightButton) {
                            // Right click to expand/collapse
                            wsContainer.expanded = !wsContainer.expanded
                        }
                    }
                }
                
                Behavior on scale {
                    NumberAnimation {
                        duration: wsContainer.animDurationFast
                        easing.type: wsContainer.animEasing
                    }
                }
            }
        }
        
        // Expand/Collapse button
        Rectangle {
            id: expandButton
            width: 14
            height: 12
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
                id: expandMouseArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                
                onClicked: {
                    wsContainer.expanded = !wsContainer.expanded
                }
            }
            
            Behavior on color {
                ColorAnimation {
                    duration: wsContainer.animDuration
                    easing.type: wsContainer.animEasing
                }
            }
        }
    }
}