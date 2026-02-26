import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../Data/" as Dat

Item {
    id: privacyTab
    
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
            
            // === FIREWALL SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "Firewall"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Status indicator
                        Rectangle {
                            width: 80
                            height: 28
                            radius: 14
                            color: firewallSwitch.checked ? "#4CAF50" : "#F44336"
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: firewallSwitch.checked ? "Active" : "Inactive"
                                color: "white"
                                font.pixelSize: 11
                                font.bold: true
                            }
                        }
                    }
                    
                    Text {
                        text: "Control network access and protect your system from unauthorized connections"
                        color: Dat.Colors.color.on_surface
                        opacity: 0.7
                        font.pixelSize: 11
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 100
                            text: "Enable Firewall"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: firewallSwitch
                            checked: false
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: firewallSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: firewallSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: firewallSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                            
                            onCheckedChanged: {
                                commandRunner.command = ["sudo", "ufw", firewallSwitch.checked ? "enable" : "disable"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 32
                            color: firewallRulesMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 6
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Configure"
                                color: firewallRulesMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                id: firewallRulesMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    commandRunner.command = ["x-terminal-emulator", "-e", "sudo", "ufw", "status", "verbose"]
                                    commandRunner.callback = null
                                    commandRunner.running = true
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
                
                Component.onCompleted: {
                    // Check firewall status
                    commandRunner.command = ["sudo", "ufw", "status"]
                    commandRunner.callback = function(output) {
                        firewallSwitch.checked = output.includes("Status: active")
                    }
                    commandRunner.running = true
                }
            }
            
            // === UPDATES SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    Text {
                        text: "System Updates"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Column {
                            spacing: 5
                            
                            Text {
                                text: "Last Update Check"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            Text {
                                id: lastUpdateText
                                text: "Checking..."
                                color: Dat.Colors.color.on_surface
                                opacity: 0.7
                                font.pixelSize: 11
                                font.family: "monospace"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: updatesAvailable ? "#FF9800" : "#4CAF50"
                            
                            property bool updatesAvailable: false
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Column {
                            spacing: 5
                            
                            Text {
                                text: "Available Updates"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            Text {
                                id: updatesCountText
                                text: "0 packages"
                                color: Dat.Colors.color.on_surface
                                opacity: 0.7
                                font.pixelSize: 11
                                font.family: "monospace"
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        // Check Updates Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: checkUpdatesMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 6
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Check for Updates"
                                color: checkUpdatesMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                id: checkUpdatesMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    lastUpdateText.text = "Checking..."
                                    commandRunner.command = ["checkupdates"]
                                    commandRunner.callback = function(output) {
                                        var lines = output.trim().split('\n')
                                        var count = lines.length
                                        updatesCountText.text = count + " package" + (count !== 1 ? "s" : "")
                                        parent.parent.parent.parent.updatesAvailable = count > 0
                                        lastUpdateText.text = new Date().toLocaleString()
                                    }
                                    commandRunner.running = true
                                }
                            }
                        }
                        
                        // Update System Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: updateSystemMouse.containsMouse ? "#4CAF50" : Dat.Colors.color.surface
                            radius: 6
                            border.color: "#4CAF50"
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Update System"
                                color: updateSystemMouse.containsMouse ? "white" : Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            MouseArea {
                                id: updateSystemMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    commandRunner.command = ["x-terminal-emulator", "-e", "sudo", "pacman", "-Syu"]
                                    commandRunner.callback = null
                                    commandRunner.running = true
                                }
                            }
                        }
                    }
                }
            }
            
            // === LOGS SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 320
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "System Logs"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    Text {
                        text: "Recent system errors and warnings"
                        color: Dat.Colors.color.on_surface
                        opacity: 0.7
                        font.pixelSize: 11
                    }
                    
                    // Logs Display
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        
                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 10
                            clip: true
                            
                            TextEdit {
                                id: logsTextArea
                                width: parent.width
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 10
                                font.family: "monospace"
                                readOnly: true
                                wrapMode: Text.Wrap
                                selectByMouse: true
                                text: "Loading logs..."
                            }
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        // Refresh Logs Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            color: refreshLogsMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 6
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Refresh Logs"
                                color: refreshLogsMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                id: refreshLogsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    logsTextArea.text = "Loading logs..."
                                    commandRunner.command = ["journalctl", "-p", "3", "-b", "--no-pager", "-n", "50"]
                                    commandRunner.callback = function(output) {
                                        if (output.trim()) {
                                            logsTextArea.text = output.trim()
                                        } else {
                                            logsTextArea.text = "No recent errors found."
                                        }
                                    }
                                    commandRunner.running = true
                                }
                            }
                        }
                        
                        // Clear Logs Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            color: clearLogsMouse.containsMouse ? "#D32F2F" : Dat.Colors.color.surface
                            radius: 6
                            border.color: "#F44336"
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Clear Logs"
                                color: clearLogsMouse.containsMouse ? "white" : Dat.Colors.color.on_surface
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                id: clearLogsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    commandRunner.command = ["sudo", "journalctl", "--vacuum-time=1d"]
                                    commandRunner.callback = function(output) {
                                        logsTextArea.text = "Logs cleared. " + output.trim()
                                    }
                                    commandRunner.running = true
                                }
                            }
                        }
                        
                        // Full Logs Button
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 36
                            color: fullLogsMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 6
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "View All"
                                color: fullLogsMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                font.pixelSize: 11
                            }
                            
                            MouseArea {
                                id: fullLogsMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    commandRunner.command = ["x-terminal-emulator", "-e", "journalctl", "-xe"]
                                    commandRunner.callback = null
                                    commandRunner.running = true
                                }
                            }
                        }
                    }
                }
                
                Component.onCompleted: {
                    // Load initial logs
                    commandRunner.command = ["journalctl", "-p", "3", "-b", "--no-pager", "-n", "50"]
                    commandRunner.callback = function(output) {
                        if (output.trim()) {
                            logsTextArea.text = output.trim()
                        } else {
                            logsTextArea.text = "No recent errors found."
                        }
                    }
                    commandRunner.running = true
                }
            }
            
            // === TELEMETRY SECTION (OPTIONAL) ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "Privacy & Telemetry"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Column {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            Text {
                                text: "Anonymous Usage Statistics"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            Text {
                                text: "Help improve Quickshell by sharing anonymous usage data"
                                color: Dat.Colors.color.on_surface
                                opacity: 0.7
                                font.pixelSize: 10
                                wrapMode: Text.WordWrap
                                width: parent.width
                            }
                        }
                        
                        Switch {
                            id: telemetrySwitch
                            checked: false
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: telemetrySwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: telemetrySwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: telemetrySwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
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