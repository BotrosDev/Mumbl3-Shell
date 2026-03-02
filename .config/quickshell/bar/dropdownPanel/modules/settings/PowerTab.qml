import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../Data/" as Dat

Item {
    id: powerTab
    
    Process {
        id: commandRunner
        running: false
        property var callback: null
        
        onExited: {
            if (callback) callback(standardOutput)
        }
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: updateBatteryInfo()
    }
    
    function updateBatteryInfo() {
        commandRunner.command = ["cat", "/sys/class/power_supply/BAT0/capacity"]
        commandRunner.callback = function(output) {
            var percent = parseInt(output.trim())
            batteryGauge.percentage = percent
            batteryPercentText.text = percent + "%"
        }
        commandRunner.running = true
    }
    
    ScrollView {
        anchors.fill: parent
        clip: true
        
        ColumnLayout {
            width: parent.parent.width
            spacing: 15
            
            // === BATTERY OVERVIEW ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 240
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 30
                    spacing: 30
                    
                    // Battery Gauge
                    Item {
                        Layout.preferredWidth: 140
                        Layout.fillHeight: true
                        
                        Column {
                            anchors.centerIn: parent
                            spacing: 10
                            
                            Rectangle {
                                width: 120
                                height: 120
                                color: "transparent"
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "transparent"
                                    border.color: Dat.Colors.color.surface
                                    border.width: 10
                                }
                                
                                Canvas {
                                    id: batteryGauge
                                    anchors.fill: parent
                                    
                                    property real percentage: 75
                                    
                                    onPercentageChanged: requestPaint()
                                    
                                    onPaint: {
                                        var ctx = getContext("2d")
                                        ctx.clearRect(0, 0, width, height)
                                        
                                        // Color based on percentage
                                        if (percentage > 60) {
                                            ctx.strokeStyle = "#4CAF50"
                                        } else if (percentage > 20) {
                                            ctx.strokeStyle = "#FF9800"
                                        } else {
                                            ctx.strokeStyle = "#F44336"
                                        }
                                        
                                        ctx.lineWidth = 10
                                        ctx.lineCap = "round"
                                        
                                        var centerX = width / 2
                                        var centerY = height / 2
                                        var radius = (width / 2) - 5
                                        var startAngle = -Math.PI / 2
                                        var endAngle = startAngle + (percentage / 100) * 2 * Math.PI
                                        
                                        ctx.beginPath()
                                        ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                                        ctx.stroke()
                                    }
                                }
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    
                                    Text {
                                        id: batteryPercentText
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "75%"
                                        color: Dat.Colors.color.on_surface
                                        font.pixelSize: 28
                                        font.bold: true
                                    }
                                    
                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: "Battery"
                                        color: Dat.Colors.color.on_surface
                                        opacity: 0.7
                                        font.pixelSize: 11
                                    }
                                }
                            }
                            
                            Text {
                                id: chargingStatusText
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: "Charging"
                                color: Dat.Colors.color.primary
                                font.pixelSize: 12
                                font.bold: true
                            }
                        }
                    }
                    
                    // Battery Details
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 15
                        
                        Text {
                            text: "Battery Details"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 16
                            font.bold: true
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                Layout.preferredWidth: 100
                                text: "Health"
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
                                    id: healthBar
                                    width: parent.width * 0.85
                                    height: parent.height
                                    color: "#4CAF50"
                                    radius: 4
                                }
                            }
                            
                            Text {
                                id: healthText
                                text: "85%"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 11
                                Layout.preferredWidth: 40
                            }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                Layout.preferredWidth: 100
                                text: "Cycles"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            Text {
                                id: cyclesText
                                text: "247"
                                color: Dat.Colors.color.on_surface
                                opacity: 0.8
                                font.pixelSize: 12
                                font.family: "monospace"
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                Layout.preferredWidth: 100
                                text: "Time Remaining"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            Text {
                                id: timeRemainingText
                                text: "3h 42m"
                                color: Dat.Colors.color.on_surface
                                opacity: 0.8
                                font.pixelSize: 12
                                font.family: "monospace"
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Text {
                                Layout.preferredWidth: 100
                                text: "Technology"
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                            
                            Text {
                                text: "Li-ion"
                                color: Dat.Colors.color.on_surface
                                opacity: 0.8
                                font.pixelSize: 12
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                }
                
                Component.onCompleted: {
                    updateBatteryInfo()
                    
                    // Get charging status
                    commandRunner.command = ["cat", "/sys/class/power_supply/BAT0/status"]
                    commandRunner.callback = function(output) {
                        chargingStatusText.text = output.trim()
                    }
                    commandRunner.running = true
                    
                    // Get cycle count (if available)
                    commandRunner.command = ["cat", "/sys/class/power_supply/BAT0/cycle_count"]
                    commandRunner.callback = function(output) {
                        cyclesText.text = output.trim()
                    }
                    commandRunner.running = true
                }
            }
            
            // === POWER MODE SECTION ===
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
                        text: "Power Mode"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        // Performance Mode
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: perfMouse.containsMouse || powerModeGroup.checkedButton === perfRadio ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 10
                            border.color: Dat.Colors.color.primary
                            border.width: 2
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 5
                                
                                RadioButton {
                                    id: perfRadio
                                    ButtonGroup.group: powerModeGroup
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 20
                                        implicitHeight: 20
                                        radius: 10
                                        border.color: Dat.Colors.color.primary
                                        border.width: 2
                                        color: "transparent"
                                        
                                        Rectangle {
                                            width: 10
                                            height: 10
                                            radius: 5
                                            anchors.centerIn: parent
                                            color: Dat.Colors.color.primary
                                            visible: perfRadio.checked
                                        }
                                    }
                                    
                                    contentItem: Text {
                                        text: "Performance"
                                        color: parent.parent.parent.color === Dat.Colors.color.primary ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                        font.pixelSize: 13
                                        font.bold: true
                                        leftPadding: perfRadio.indicator.width + 10
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                Text {
                                    text: "Maximum speed, higher power use"
                                    color: parent.parent.color === Dat.Colors.color.primary ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    opacity: 0.7
                                    font.pixelSize: 10
                                    Layout.leftMargin: 30
                                }
                            }
                            
                            MouseArea {
                                id: perfMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    perfRadio.checked = true
                                    commandRunner.command = ["sudo", "cpupower", "frequency-set", "-g", "performance"]
                                    commandRunner.callback = null
                                    commandRunner.running = true
                                }
                            }
                        }
                        
                        // Balanced Mode
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: balMouse.containsMouse || powerModeGroup.checkedButton === balRadio ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 10
                            border.color: Dat.Colors.color.primary
                            border.width: 2
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 5
                                
                                RadioButton {
                                    id: balRadio
                                    checked: true
                                    ButtonGroup.group: powerModeGroup
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 20
                                        implicitHeight: 20
                                        radius: 10
                                        border.color: Dat.Colors.color.primary
                                        border.width: 2
                                        color: "transparent"
                                        
                                        Rectangle {
                                            width: 10
                                            height: 10
                                            radius: 5
                                            anchors.centerIn: parent
                                            color: Dat.Colors.color.primary
                                            visible: balRadio.checked
                                        }
                                    }
                                    
                                    contentItem: Text {
                                        text: "Balanced"
                                        color: parent.parent.parent.color === Dat.Colors.color.primary ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                        font.pixelSize: 13
                                        font.bold: true
                                        leftPadding: balRadio.indicator.width + 10
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                Text {
                                    text: "Optimal performance and battery life"
                                    color: parent.parent.color === Dat.Colors.color.primary ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    opacity: 0.7
                                    font.pixelSize: 10
                                    Layout.leftMargin: 30
                                }
                            }
                            
                            MouseArea {
                                id: balMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    balRadio.checked = true
                                    commandRunner.command = ["sudo", "cpupower", "frequency-set", "-g", "schedutil"]
                                    commandRunner.callback = null
                                    commandRunner.running = true
                                }
                            }
                        }
                        
                        // Power Saver Mode
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            color: saverMouse.containsMouse || powerModeGroup.checkedButton === saverRadio ? Dat.Colors.color.primary : Dat.Colors.color.surface
                            radius: 10
                            border.color: Dat.Colors.color.primary
                            border.width: 2
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 15
                                spacing: 5
                                
                                RadioButton {
                                    id: saverRadio
                                    ButtonGroup.group: powerModeGroup
                                    
                                    indicator: Rectangle {
                                        implicitWidth: 20
                                        implicitHeight: 20
                                        radius: 10
                                        border.color: Dat.Colors.color.primary
                                        border.width: 2
                                        color: "transparent"
                                        
                                        Rectangle {
                                            width: 10
                                            height: 10
                                            radius: 5
                                            anchors.centerIn: parent
                                            color: Dat.Colors.color.primary
                                            visible: saverRadio.checked
                                        }
                                    }
                                    
                                    contentItem: Text {
                                        text: "Power Saver"
                                        color: parent.parent.parent.color === Dat.Colors.color.primary ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                        font.pixelSize: 13
                                        font.bold: true
                                        leftPadding: saverRadio.indicator.width + 10
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }
                                
                                Text {
                                    text: "Extended battery life, reduced speed"
                                    color: parent.parent.color === Dat.Colors.color.primary ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    opacity: 0.7
                                    font.pixelSize: 10
                                    Layout.leftMargin: 30
                                }
                            }
                            
                            MouseArea {
                                id: saverMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    saverRadio.checked = true
                                    commandRunner.command = ["sudo", "cpupower", "frequency-set", "-g", "powersave"]
                                    commandRunner.callback = null
                                    commandRunner.running = true
                                }
                            }
                        }
                    }
                    
                    ButtonGroup {
                        id: powerModeGroup
                    }
                }
            }
            
            // === ADVANCED SETTINGS ===
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
                    
                    Text {
                        text: "Advanced"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // CPU Governor
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 140
                            text: "CPU Governor"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["schedutil", "performance", "powersave", "ondemand", "conservative"]
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
                                commandRunner.command = ["sudo", "cpupower", "frequency-set", "-g", currentText]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                    }
                    
                    // Auto Suspend Time
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 140
                            text: "Auto Suspend"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: suspendSlider
                            Layout.fillWidth: true
                            from: 5
                            to: 60
                            value: 15
                            stepSize: 5
                            
                            background: Rectangle {
                                x: suspendSlider.leftPadding
                                y: suspendSlider.topPadding + suspendSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: suspendSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: suspendSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: suspendSlider.leftPadding + suspendSlider.visualPosition * (suspendSlider.availableWidth - width)
                                y: suspendSlider.topPadding + suspendSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: Math.round(suspendSlider.value) + " min"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 50
                        }
                    }
                    
                    // Battery Charge Threshold (ThinkPad specific)
                    Text {
                        text: "Battery Charge Threshold (ThinkPad)"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 13
                        font.bold: true
                        Layout.topMargin: 5
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 140
                            text: "Start Threshold"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: startThresholdSlider
                            Layout.fillWidth: true
                            from: 40
                            to: 95
                            value: 75
                            stepSize: 5
                            
                            background: Rectangle {
                                x: startThresholdSlider.leftPadding
                                y: startThresholdSlider.topPadding + startThresholdSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: startThresholdSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: startThresholdSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: startThresholdSlider.leftPadding + startThresholdSlider.visualPosition * (startThresholdSlider.availableWidth - width)
                                y: startThresholdSlider.topPadding + startThresholdSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                            
                            onValueChanged: {
                                commandRunner.command = ["bash", "-c", "echo " + Math.round(value) + " | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Text {
                            text: Math.round(startThresholdSlider.value) + "%"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 140
                            text: "Stop Threshold"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: stopThresholdSlider
                            Layout.fillWidth: true
                            from: 50
                            to: 100
                            value: 80
                            stepSize: 5
                            
                            background: Rectangle {
                                x: stopThresholdSlider.leftPadding
                                y: stopThresholdSlider.topPadding + stopThresholdSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: stopThresholdSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: stopThresholdSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: stopThresholdSlider.leftPadding + stopThresholdSlider.visualPosition * (stopThresholdSlider.availableWidth - width)
                                y: stopThresholdSlider.topPadding + stopThresholdSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                            
                            onValueChanged: {
                                commandRunner.command = ["bash", "-c", "echo " + Math.round(value) + " | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Text {
                            text: Math.round(stopThresholdSlider.value) + "%"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}