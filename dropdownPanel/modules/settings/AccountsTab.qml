import QtQuick
import Quickshell.Io
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../../Data/" as Dat

Item {
    id: accountsTab
    
    Process {
        id: commandRunner
        running: false
        property var callback: null
        
        onExited: {
            if (callback) callback(standardOutput)
        }
    }
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.parent.width
            spacing: 15
            
            // === USER INFO CARD ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 25
                    
                    // Profile Picture
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 100
                        color: Dat.Colors.color.primary
                        radius: 50
                        
                        Text {
                            anchors.centerIn: parent
                            text: usernameText.text.substring(0, 2).toUpperCase()
                            color: Dat.Colors.color.on_primary
                            font.pixelSize: 36
                            font.bold: true
                        }
                        
                        Rectangle {
                            anchors {
                                right: parent.right
                                bottom: parent.bottom
                            }
                            width: 30
                            height: 30
                            color: Dat.Colors.color.surface
                            radius: 15
                            border.color: Dat.Colors.color.primary
                            border.width: 2
                            
                            Text {
                                anchors.centerIn: parent
                                text: "✎"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 14
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onEntered: parent.color = Dat.Colors.color.surface_variant
                                onExited: parent.color = Dat.Colors.color.surface
                            }
                        }
                    }
                    
                    // User Details
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10
                        
                        Text {
                            id: usernameText
                            text: "Loading..."
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 24
                            font.bold: true
                        }
                        
                        Text {
                            id: useridText
                            text: "UID: ..."
                            color: Dat.Colors.color.on_surface
                            opacity: 0.7
                            font.pixelSize: 12
                        }
                        
                        Text {
                            id: shellText
                            text: "Shell: ..."
                            color: Dat.Colors.color.on_surface
                            opacity: 0.7
                            font.pixelSize: 12
                        }
                        
                        Item { Layout.fillHeight: true }
                        
                        Rectangle {
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: 36
                            color: avatarBtnMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 6
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Change Avatar"
                                color: avatarBtnMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                id: avatarBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }
                
                Component.onCompleted: {
                    // Get username
                    commandRunner.command = ["whoami"]
                    commandRunner.callback = function(output) {
                        usernameText.text = output.trim()
                    }
                    commandRunner.running = true
                    
                    // Get user ID
                    commandRunner.command = ["id", "-u"]
                    commandRunner.callback = function(output) {
                        useridText.text = "UID: " + output.trim()
                    }
                    commandRunner.running = true
                    
                    // Get shell
                    commandRunner.command = ["bash", "-c", "echo $SHELL"]
                    commandRunner.callback = function(output) {
                        shellText.text = "Shell: " + output.trim()
                    }
                    commandRunner.running = true
                }
            }
            
            // === SESSION SETTINGS ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 240
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "Session"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Auto-login Toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 140
                            text: "Auto-login"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: autoLoginSwitch
                            checked: false
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: autoLoginSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: autoLoginSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: autoLoginSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                        }
                        
                        Text {
                            text: "Skip login screen"
                            color: Dat.Colors.color.on_surface
                            opacity: 0.6
                            font.pixelSize: 10
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Default Shell Selector
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 140
                            text: "Default Shell"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["/bin/bash", "/bin/zsh", "/bin/fish", "/bin/sh"]
                            background: Rectangle {
                                color: Dat.Colors.color.surface
                                radius: 6
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                            }
                            contentItem: Text {
                                text: parent.displayText
                                color: Dat.Colors.color.on_surface
                                leftPadding: 10
                                verticalAlignment: Text.AlignVCenter
                                font.family: "monospace"
                            }
                            
                            onActivated: {
                                commandRunner.command = ["chsh", "-s", currentText]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                    }
                    
                    // Change Password Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: passwordBtnMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Change Password"
                            color: passwordBtnMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        MouseArea {
                            id: passwordBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandRunner.command = ["x-terminal-emulator", "-e", "passwd"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                }
            }
            
            // === GROUPS INFO ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "User Groups"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        Flow {
                            id: groupsFlow
                            width: parent.width
                            spacing: 8
                            
                            Repeater {
                                id: groupsRepeater
                                model: []
                                
                                Rectangle {
                                    width: groupText.width + 20
                                    height: 28
                                    color: Dat.Colors.color.surface
                                    radius: 14
                                    border.color: Dat.Colors.color.primary
                                    border.width: 1
                                    
                                    Text {
                                        id: groupText
                                        anchors.centerIn: parent
                                        text: modelData
                                        color: Dat.Colors.color.on_surface
                                        font.pixelSize: 11
                                        font.family: "monospace"
                                    }
                                }
                            }
                        }
                    }
                }
                
                Component.onCompleted: {
                    commandRunner.command = ["id", "-Gn"]
                    commandRunner.callback = function(output) {
                        var groups = output.trim().split(' ')
                        groupsRepeater.model = groups
                    }
                    commandRunner.running = true
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}