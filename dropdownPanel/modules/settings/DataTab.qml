import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../Data/" as Dat

Item {
    id: dataTab
    
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
            
            // === STORAGE OVERVIEW ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 280
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "Storage Overview"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Main Disk Usage
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "System Disk"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 13
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                id: diskUsageText
                                text: "Loading..."
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                                font.family: "monospace"
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            color: Dat.Colors.color.surface
                            radius: 10
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Rectangle {
                                id: diskUsageFill
                                width: parent.width * 0.65
                                height: parent.height
                                color: {
                                    var percent = width / parent.width
                                    if (percent > 0.9) return "#F44336"
                                    if (percent > 0.7) return "#FF9800"
                                    return Dat.Colors.color.primary
                                }
                                radius: 10
                                
                                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                id: diskPercentText
                                text: "65%"
                                color: Dat.Colors.color.on_primary
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                    
                    // Home Directory Usage
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "Home Directory"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 13
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                id: homeUsageText
                                text: "Loading..."
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                                font.family: "monospace"
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            color: Dat.Colors.color.surface
                            radius: 10
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Rectangle {
                                id: homeUsageFill
                                width: parent.width * 0.45
                                height: parent.height
                                color: Dat.Colors.color.secondary
                                radius: 10
                                
                                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                id: homePercentText
                                text: "45%"
                                color: Dat.Colors.color.on_primary
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                    
                    // Cache Usage
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        RowLayout {
                            Layout.fillWidth: true
                            
                            Text {
                                text: "Cache"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 13
                                font.bold: true
                            }
                            
                            Item { Layout.fillWidth: true }
                            
                            Text {
                                id: cacheUsageText
                                text: "Loading..."
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                                font.family: "monospace"
                            }
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 20
                            color: Dat.Colors.color.surface
                            radius: 10
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Rectangle {
                                id: cacheUsageFill
                                width: parent.width * 0.20
                                height: parent.height
                                color: "#FF9800"
                                radius: 10
                                
                                Behavior on width { NumberAnimation { duration: 500; easing.type: Easing.OutCubic } }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Cache data"
                                color: Dat.Colors.color.on_surface
                                opacity: 0.7
                                font.pixelSize: 10
                            }
                        }
                    }
                }
                
                Component.onCompleted: {
                    // Get disk usage
                    commandRunner.command = ["df", "-h", "/"]
                    commandRunner.callback = function(output) {
                        var lines = output.trim().split('\n')
                        if (lines.length > 1) {
                            var parts = lines[1].split(/\s+/)
                            diskUsageText.text = parts[2] + " / " + parts[1]
                            var percent = parseInt(parts[4])
                            diskPercentText.text = percent + "%"
                            diskUsageFill.width = diskUsageFill.parent.width * (percent / 100)
                        }
                    }
                    commandRunner.running = true
                    
                    // Get home usage
                    commandRunner.command = ["du", "-sh", "/home/" + Quickshell.env("USER")]
                    commandRunner.callback = function(output) {
                        var size = output.trim().split('\t')[0]
                        homeUsageText.text = size
                        // Estimate percentage (this is simplified)
                        var sizeNum = parseFloat(size)
                        var unit = size.slice(-1)
                        var percent = 45 // Default estimate
                        if (unit === 'G') {
                            percent = Math.min(90, sizeNum * 5)
                        }
                        homePercentText.text = Math.round(percent) + "%"
                        homeUsageFill.width = homeUsageFill.parent.width * (percent / 100)
                    }
                    commandRunner.running = true
                    
                    // Get cache usage
                    commandRunner.command = ["du", "-sh", "/home/" + Quickshell.env("USER") + "/.cache"]
                    commandRunner.callback = function(output) {
                        var size = output.trim().split('\t')[0]
                        cacheUsageText.text = size
                        var sizeNum = parseFloat(size)
                        var unit = size.slice(-1)
                        var percent = 20 // Default estimate
                        if (unit === 'G') {
                            percent = Math.min(50, sizeNum * 2)
                        }
                        cacheUsageFill.width = cacheUsageFill.parent.width * (percent / 100)
                    }
                    commandRunner.running = true
                }
            }
            
            // === CLEANUP TOOLS ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 280
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "Cleanup Tools"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    Text {
                        text: "Free up disk space by removing unnecessary files"
                        color: Dat.Colors.color.on_surface
                        opacity: 0.7
                        font.pixelSize: 11
                    }
                    
                    // Clear Pacman Cache
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: pacmanCacheMouse.containsMouse ? "#D32F2F" : Dat.Colors.color.surface
                        radius: 8
                        border.color: "#F44336"
                        border.width: 2
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            Column {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Clear Pacman Cache"
                                    color: pacmanCacheMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "Remove old package files"
                                    color: pacmanCacheMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    opacity: 0.7
                                    font.pixelSize: 10
                                }
                            }
                            
                            Text {
                                text: "Clean"
                                color: pacmanCacheMouse.containsMouse ? Dat.Colors.color.on_primary : "#F44336"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                        
                        MouseArea {
                            id: pacmanCacheMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandRunner.command = ["sudo", "pacman", "-Sc", "--noconfirm"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                    }
                    
                    // Clear Thumbnail Cache
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: thumbCacheMouse.containsMouse ? "#D32F2F" : Dat.Colors.color.surface
                        radius: 8
                        border.color: "#F44336"
                        border.width: 2
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            Column {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Clear Thumbnail Cache"
                                    color: thumbCacheMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "Remove cached image thumbnails"
                                    color: thumbCacheMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    opacity: 0.7
                                    font.pixelSize: 10
                                }
                            }
                            
                            Text {
                                text: "Clean"
                                color: thumbCacheMouse.containsMouse ? Dat.Colors.color.on_primary : "#F44336"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                        
                        MouseArea {
                            id: thumbCacheMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandRunner.command = ["rm", "-rf", "/home/" + Quickshell.env("USER") + "/.cache/thumbnails/*"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                    }
                    
                    // Clear Logs
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 50
                        color: logsMouse.containsMouse ? "#D32F2F" : Dat.Colors.color.surface
                        radius: 8
                        border.color: "#F44336"
                        border.width: 2
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 15
                            spacing: 10
                            
                            Column {
                                Layout.fillWidth: true
                                spacing: 2
                                
                                Text {
                                    text: "Clear System Logs"
                                    color: logsMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Text {
                                    text: "Remove old journal entries"
                                    color: logsMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    opacity: 0.7
                                    font.pixelSize: 10
                                }
                            }
                            
                            Text {
                                text: "Clean"
                                color: logsMouse.containsMouse ? Dat.Colors.color.on_primary : "#F44336"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                        
                        MouseArea {
                            id: logsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandRunner.command = ["sudo", "journalctl", "--vacuum-time=7d"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                    }
                }
            }
            
            // === BACKUP SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 140
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "Backup & Restore"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        // Backup Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: backupMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 8
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Backup Config"
                                    color: backupMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Save settings"
                                    color: backupMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    opacity: 0.7
                                    font.pixelSize: 10
                                }
                            }
                            
                            MouseArea {
                                id: backupMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    commandRunner.command = ["tar", "-czf", "/home/" + Quickshell.env("USER") + "/quickshell-backup-" + Date.now() + ".tar.gz", "-C", "/home/" + Quickshell.env("USER"), ".config/quickshell"]
                                    commandRunner.callback = null
                                    commandRunner.running = true
                                }
                            }
                        }
                        
                        // Restore Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            color: restoreMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 8
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Column {
                                anchors.centerIn: parent
                                spacing: 2
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Restore Config"
                                    color: restoreMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    font.pixelSize: 12
                                    font.bold: true
                                }
                                
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    text: "Load settings"
                                    color: restoreMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    opacity: 0.7
                                    font.pixelSize: 10
                                }
                            }
                            
                            MouseArea {
                                id: restoreMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    commandRunner.command = ["zenity", "--file-selection", "--title=Select Backup"]
                                    commandRunner.callback = function(output) {
                                        if (output.trim()) {
                                            commandRunner.command = ["tar", "-xzf", output.trim(), "-C", "/home/" + Quickshell.env("USER")]
                                            commandRunner.callback = null
                                            commandRunner.running = true
                                        }
                                    }
                                    commandRunner.running = true
                                }
                            }
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}