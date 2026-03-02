import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../Data/" as Dat

Item {
    id: networksTab
    
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
            
            // === WIFI CARD ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: wifiExpanded ? 350 : 180
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                property bool wifiExpanded: false
                
                Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "WiFi"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Status badge
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: wifiSwitch.checked ? "#4CAF50" : "#F44336"
                        }
                    }
                    
                    // Connected Network
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Network"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Text {
                            id: connectedNetworkText
                            text: "Not Connected"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Signal Strength
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        visible: wifiSwitch.checked
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Signal Strength"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 8
                            color: Dat.Colors.color.surface
                            radius: 4
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Rectangle {
                                width: parent.width * 0.75
                                height: parent.height
                                color: Dat.Colors.color.primary
                                radius: 4
                            }
                        }
                        
                        Text {
                            text: "75%"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 11
                        }
                    }
                    
                    // WiFi Toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Enable WiFi"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: wifiSwitch
                            checked: true
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: wifiSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: wifiSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: wifiSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                            
                            onCheckedChanged: {
                                commandRunner.command = ["nmcli", "radio", "wifi", wifiSwitch.checked ? "on" : "off"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // IP Address
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        visible: wifiSwitch.checked
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "IP Address"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Text {
                            id: ipAddressText
                            text: "192.168.1.100"
                            color: Dat.Colors.color.on_surface
                            opacity: 0.7
                            font.pixelSize: 11
                            font.family: "monospace"
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Available Networks Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: networksBtnMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        visible: wifiSwitch.checked
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: parent.parent.parent.wifiExpanded ? "Hide Available Networks" : "Show Available Networks"
                            color: networksBtnMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                            font.pixelSize: 11
                        }
                        
                        MouseArea {
                            id: networksBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                parent.parent.parent.wifiExpanded = !parent.parent.parent.wifiExpanded
                            }
                        }
                    }
                    
                    // Available Networks List
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        visible: parent.parent.wifiExpanded && wifiSwitch.checked
                        clip: true
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 5
                            
                            Repeater {
                                model: ["HomeNetwork", "Office-5G", "Guest-WiFi", "Neighbor-Net"]
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: networkItemMouse.containsMouse ? Dat.Colors.color.surface_variant : "transparent"
                                    radius: 4
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10
                                        
                                        Text {
                                            text: modelData
                                            color: Dat.Colors.color.on_surface
                                            font.pixelSize: 12
                                            Layout.fillWidth: true
                                        }
                                        
                                        Text {
                                            text: "🔒"
                                            font.pixelSize: 12
                                        }
                                        
                                        Rectangle {
                                            width: 60
                                            height: 24
                                            color: Dat.Colors.color.primary
                                            radius: 4
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: "Connect"
                                                color: Dat.Colors.color.on_primary
                                                font.pixelSize: 10
                                            }
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: networkItemMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                    }
                }
                
                Component.onCompleted: {
                    // Get current network
                    commandRunner.command = ["nmcli", "-t", "-f", "active,ssid", "dev", "wifi"]
                    commandRunner.callback = function(output) {
                        var lines = output.trim().split('\n')
                        for (var i = 0; i < lines.length; i++) {
                            if (lines[i].startsWith("yes:")) {
                                connectedNetworkText.text = lines[i].substring(4)
                                break
                            }
                        }
                    }
                    commandRunner.running = true
                    
                    // Get IP
                    commandRunner.command = ["hostname", "-I"]
                    commandRunner.callback = function(output) {
                        ipAddressText.text = output.trim().split(' ')[0]
                    }
                    commandRunner.running = true
                }
            }
            
            // === BLUETOOTH CARD ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 220
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "Bluetooth"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Status badge
                        Rectangle {
                            width: 12
                            height: 12
                            radius: 6
                            color: bluetoothSwitch.checked ? "#2196F3" : "#9E9E9E"
                        }
                    }
                    
                    // Bluetooth Toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Enable Bluetooth"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: bluetoothSwitch
                            checked: false
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: bluetoothSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: bluetoothSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: bluetoothSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                            
                            onCheckedChanged: {
                                commandRunner.command = ["bluetoothctl", "power", bluetoothSwitch.checked ? "on" : "off"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Paired Devices
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        visible: bluetoothSwitch.checked
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 5
                            
                            Text {
                                text: "Paired Devices"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 11
                                opacity: 0.7
                            }
                            
                            Repeater {
                                model: ["AirPods Pro", "Logitech Mouse", "Xbox Controller"]
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 40
                                    color: btDeviceMouse.containsMouse ? Dat.Colors.color.surface_variant : "transparent"
                                    radius: 4
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10
                                        
                                        Text {
                                            text: modelData
                                            color: Dat.Colors.color.on_surface
                                            font.pixelSize: 12
                                            Layout.fillWidth: true
                                        }
                                        
                                        Rectangle {
                                            width: 70
                                            height: 24
                                            color: index === 0 ? "#F44336" : Dat.Colors.color.primary
                                            radius: 4
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: index === 0 ? "Disconnect" : "Connect"
                                                color: Dat.Colors.color.on_primary
                                                font.pixelSize: 10
                                            }
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: btDeviceMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // === ADVANCED SECTION ===
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
                    spacing: 12
                    
                    Text {
                        text: "Advanced"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Restart Networking Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: restartNetMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Restart Networking"
                            color: restartNetMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        MouseArea {
                            id: restartNetMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandRunner.command = ["systemctl", "restart", "NetworkManager"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                    }
                    
                    // DNS Info
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 80
                            text: "DNS Server"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Text {
                            id: dnsText
                            text: "8.8.8.8"
                            color: Dat.Colors.color.on_surface
                            opacity: 0.7
                            font.pixelSize: 11
                            font.family: "monospace"
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Proxy Settings Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 36
                        color: proxyMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Configure Proxy"
                            color: proxyMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        MouseArea {
                            id: proxyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}