import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "../../core" as Dat

Rectangle {
    id: root
    
    signal closeRequested()
    
    color: Dat.Colors.color.surface
    radius: 12
    border.color: Dat.Colors.color.primary
    border.width: 1
    
    // Helper function to get icon emoji based on app name or summary
    function getIconForApp(appName, summary) {
        var app = (appName || "").toLowerCase()
        var sum = (summary || "").toLowerCase()
        
        if (app.includes("discord")) return ""
        if (app.includes("spotify")) return ""
        if (app.includes("firefox") || app.includes("chrome")) return "󰖟"
        if (app.includes("mail") || app.includes("thunderbird")) return ""
        if (app.includes("calendar")) return ""
        if (app.includes("battery")) return ""
        if (app.includes("network") || app.includes("wifi")) return "󰖩"
        if (sum.includes("error") || sum.includes("failed")) return ""
        if (sum.includes("warning")) return "⚠️"
        if (sum.includes("success") || sum.includes("complete")) return ""
        if (sum.includes("message") || sum.includes("chat")) return "󰍩"
        return ""
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Text {
                text: "Notifications"
                font.pixelSize: 24
                font.bold: true
                color: Dat.Colors.color.on_surface
                Layout.fillWidth: true
            }
            
            Text {
                text: Dat.NotifServer.notifCount > 0 ? Dat.NotifServer.notifCount : ""
                font.pixelSize: 14
                font.bold: true
                color: Dat.Colors.color.primary
                visible: Dat.NotifServer.notifCount > 0
            }
            
            // Clear All button
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 30
                color: clearAllMouse.containsMouse ? Dat.Colors.color.surface_variant : Dat.Colors.color.surface
                radius: 6
                border.color: Dat.Colors.color.primary
                border.width: 1
                visible: Dat.NotifServer.notifCount > 0
                
                Text {
                    anchors.centerIn: parent
                    text: "Clear All"
                    font.pixelSize: 12
                    color: Dat.Colors.color.on_surface
                }
                
                MouseArea {
                    id: clearAllMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Dat.NotifServer.clearNotifs()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Dat.Colors.color.primary
        }
        
        // Notification List
        ListView {
            id: notificationList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            clip: true
            
            model: Dat.NotifServer.notifications
            
            // Empty state
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 200
                color: "transparent"
                visible: Dat.NotifServer.notifCount === 0
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 10
                    
                    Text {
                        text: "󰂛"
                        color : Dat.Colors.color.on_surface_variant
                        font.pixelSize: 48
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "No notifications"
                        font.pixelSize: 18
                        color: Dat.Colors.color.on_surface_variant
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            delegate: Rectangle {
                width: notificationList.width
                height: 80
                color: notifMouse.containsMouse ? Dat.Colors.color.surface_variant : Dat.Colors.color.surface
                radius: 8
                border.color: Dat.Colors.color.on_primary
                border.width: 1
                
                required property Notification modelData

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Text {
                        text: getIconForApp(modelData.appName, modelData.summary)
                        font.pixelSize: 28
                        Layout.alignment: Qt.AlignTop
                        color: Dat.Colors.color.primary
                    }
                    
                    // Content
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4
                        
                        Text {
                            text: modelData.summary || modelData.appName || "Notification"
                            font.pixelSize: 14
                            font.bold: true
                            color: Dat.Colors.color.on_surface
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: modelData.body || ""
                            font.pixelSize: 12
                            color: Dat.Colors.color.on_surface_variant
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                    }
                    
                    // Delete button
                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignTop
                        color: deleteMouse.containsMouse ? Dat.Colors.color.error_container : "transparent"
                        radius: 4
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 16
                            color: deleteMouse.containsMouse ? Dat.Colors.color.error : Dat.Colors.color.on_surface_variant
                        }
                        
                        MouseArea {
                            id: deleteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: modelData.dismiss()
                        }
                    }
                }
                
                MouseArea {
                    id: notifMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z: -1
                    onClicked: {
                        if (modelData.actions.length > 0) {
                            modelData.actions[0].invoke();
                        }
                    }
                }
            }
        }
    }
}