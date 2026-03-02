import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Data/" as Dat

Rectangle {
    id: root
    
    signal closeRequested()
    
    color: Dat.Colors.color.surface
    radius: 12
    border.color: Dat.Colors.color.primary
    border.width: 1
    
    // Real notification storage
    ListModel {
        id: notificationModel
    }
    
    // Monitor system notifications via polling
    Process {
        id: notifChecker
        command: ["bash", "-c", "swaync-client -l | jq -r '.notifications[] | \"\\(.app_name)|||\\(.summary)|||\\(.body)\"' 2>/dev/null || echo ''"]
        
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && stdout) {
                var lines = String(stdout).trim().split('\n')
                for (var i = 0; i < lines.length; i++) {
                    if (lines[i]) {
                        var parts = lines[i].split('|||')
                        if (parts.length >= 2) {
                            addNotification(parts[0] || "Notification", parts[1] || "", parts[2] || "")
                        }
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: notifChecker.running = true
    }
    
    function parseNotifications(output) {
        if (!output) return
        
        try {
            var notifications = JSON.parse(output)
            
            if (notifications && notifications.length > 0) {
                for (var i = 0; i < notifications.length && i < 20; i++) {
                    var notif = notifications[i]
                    if (!notif) continue
                    
                    var appName = notif.app_name || notif['app-name'] || ""
                    var summary = notif.summary || ""
                    var body = notif.body || ""
                    
                    // Check if notification already exists
                    var exists = false
                    for (var j = 0; j < notificationModel.count; j++) {
                        var existing = notificationModel.get(j)
                        if (existing.title === summary && existing.message === body) {
                            exists = true
                            break
                        }
                    }
                    
                    if (!exists && summary) {
                        addNotification(appName, summary, body)
                    }
                }
            }
        } catch (e) {
            console.log("Error parsing notifications:", e)
        }
    }
    
    // Helper function to get icon emoji based on app name or summary
    function getIconForApp(appName, summary) {
        var app = (appName || "").toLowerCase()
        var sum = (summary || "").toLowerCase()
        
        // App-specific icons
        if (app.includes("discord")) return ""
        if (app.includes("spotify")) return ""
        if (app.includes("firefox") || app.includes("chrome")) return "󰖟"
        if (app.includes("mail") || app.includes("thunderbird")) return ""
        if (app.includes("calendar")) return ""
        if (app.includes("battery")) return ""
        if (app.includes("network") || app.includes("wifi")) return "󰖩"
        
        // Summary-based icons
        if (sum.includes("error") || sum.includes("failed")) return ""
        if (sum.includes("warning")) return "⚠️"
        if (sum.includes("success") || sum.includes("complete")) return ""
        if (sum.includes("message") || sum.includes("chat")) return "󰍩"
        
        // Default
        return ""
    }
    
    // Function to add notification
    function addNotification(appName, summary, body) {
        var timeStr = "Just now"
        var iconEmoji = getIconForApp(appName || "", summary || "")
        
        notificationModel.insert(0, {
            title: summary || appName || "Notification",
            message: body || "",
            time: timeStr,
            icon: iconEmoji,
            timestamp: Date.now()
        })
        
        // Keep only last 50 notifications
        if (notificationModel.count > 50) {
            notificationModel.remove(notificationModel.count - 1)
        }
    }
    
    // Update timestamps periodically
    Timer {
        interval: 10000 
        running: true
        repeat: true
        onTriggered: {
            for (var i = 0; i < notificationModel.count; i++) {
                var item = notificationModel.get(i)
                if (!item) continue
                
                var timestamp = item.timestamp
                var now = Date.now()
                var diff = now - timestamp
                
                var timeStr = ""
                var minutes = Math.floor(diff / 60000)
                var hours = Math.floor(diff / 3600000)
                var days = Math.floor(diff / 86400000)
                
                if (minutes < 1) timeStr = "Just now"
                else if (minutes < 60) timeStr = minutes + " min ago"
                else if (hours < 24) timeStr = hours + " hour" + (hours > 1 ? "s" : "") + " ago"
                else timeStr = days + " day" + (days > 1 ? "s" : "") + " ago"
                
                notificationModel.setProperty(i, "time", timeStr)
            }
        }
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
                text: notificationModel.count > 0 ? notificationModel.count : ""
                font.pixelSize: 14
                font.bold: true
                color: Dat.Colors.color.primary
                visible: notificationModel.count > 0
            }
            
            // Clear All button
            Rectangle {
                Layout.preferredWidth: 80
                Layout.preferredHeight: 30
                color: clearAllMouse.containsMouse ? Dat.Colors.color.surface_variant : Dat.Colors.color.surface
                radius: 6
                border.color: Dat.Colors.color.primary
                border.width: 1
                visible: notificationModel.count > 0
                
                Behavior on color { ColorAnimation { duration: 150 } }
                
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
                    onClicked: notificationModel.clear()
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
            
            model: notificationModel
            
            // Empty state
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 200
                color: "transparent"
                visible: notificationModel.count === 0
                
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
                
                Behavior on color { ColorAnimation { duration: 150 } }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Text {
                        text: model.icon
                        font.pixelSize: 28
                        Layout.alignment: Qt.AlignTop
                    }
                    
                    // Content
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 4
                        
                        Text {
                            text: model.title
                            font.pixelSize: 14
                            font.bold: true
                            color: Dat.Colors.color.on_surface
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: model.message
                            font.pixelSize: 12
                            color: Dat.Colors.color.on_surface_variant
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            elide: Text.ElideRight
                        }
                        
                        Text {
                            text: model.time
                            font.pixelSize: 10
                            color: Dat.Colors.color.on_surface_variant
                        }
                    }
                    
                    // Delete button
                    Rectangle {
                        Layout.preferredWidth: 24
                        Layout.preferredHeight: 24
                        Layout.alignment: Qt.AlignTop
                        color: deleteMouse.containsMouse ? Dat.Colors.color.surface_variant : Dat.Colors.color.surface
                        radius: 4
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            font.pixelSize: 16
                            color: deleteMouse.containsMouse ? Dat.Colors.color.error : Dat.Colors.color.on_surface_variant
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                        
                        MouseArea {
                            id: deleteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notificationModel.remove(index)
                        }
                    }
                }
                
                MouseArea {
                    id: notifMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    z: -1
                }
            }
        }
    }
}