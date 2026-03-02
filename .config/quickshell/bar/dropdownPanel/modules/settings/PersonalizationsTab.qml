import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../Data/" as Dat

Item {
    id: personalizationsTab
    
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
            
            // === LIVE PREVIEW CARD ===
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
                    spacing: 10
                    
                    Text {
                        text: "Live Preview"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 14
                        font.bold: true
                    }
                    
                    // Mini preview of the interface
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: darkModeSwitch.checked ? "#1a1a1a" : "#f5f5f5"
                        radius: 8
                        border.color: accentColorPicker.selectedColor
                        border.width: 2
                        
                        Behavior on color { ColorAnimation { duration: 300 } }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                        
                        // Mini bar preview
                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: barPositionCombo.currentIndex === 0 ? parent.top : undefined
                                bottom: barPositionCombo.currentIndex === 1 ? parent.bottom : undefined
                            }
                            height: 30
                            color: accentColorPicker.selectedColor
                            opacity: transparencySlider.value
                            
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: 5
                                
                                Repeater {
                                    model: 4
                                    Rectangle {
                                        width: 40
                                        height: 20
                                        color: darkModeSwitch.checked ? "#2a2a2a" : "#ffffff"
                                        radius: 4
                                    }
                                }
                            }
                        }
                        
                        // Mini window preview
                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width * 0.6
                            height: parent.height * 0.5
                            color: darkModeSwitch.checked ? "#2a2a2a" : "#ffffff"
                            radius: 6
                            border.color: accentColorPicker.selectedColor
                            border.width: 1
                            opacity: blurSlider.value
                            
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                    }
                }
            }
            
            // === APPEARANCE SECTION ===
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 300
                color: Dat.Colors.color.surface_variant
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 12
                    
                    Text {
                        text: "Appearance"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Theme Selector
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Theme"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Catppuccin Mocha", "Nord", "Dracula", "Gruvbox", "Tokyo Night"]
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
                            }
                        }
                    }
                    
                    // Accent Color Picker
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Accent Color"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Row {
                            spacing: 8
                            
                            Repeater {
                                id: accentColorPicker
                                property color selectedColor: "#89b4fa"
                                
                                model: ["#89b4fa", "#f38ba8", "#a6e3a1", "#fab387", "#cba6f7", "#f9e2af"]
                                
                                Rectangle {
                                    width: 32
                                    height: 32
                                    color: modelData
                                    radius: 16
                                    border.color: Dat.Colors.color.on_surface
                                    border.width: accentColorPicker.selectedColor === modelData ? 3 : 0
                                    
                                    Behavior on border.width { NumberAnimation { duration: 150 } }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            accentColorPicker.selectedColor = modelData
                                        }
                                    }
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Dark/Light Toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Dark Mode"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: darkModeSwitch
                            checked: true
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: darkModeSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: darkModeSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: darkModeSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Transparency Slider
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Transparency"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: transparencySlider
                            Layout.fillWidth: true
                            from: 0.5
                            to: 1.0
                            value: 0.9
                            stepSize: 0.05
                            
                            background: Rectangle {
                                x: transparencySlider.leftPadding
                                y: transparencySlider.topPadding + transparencySlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: transparencySlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: transparencySlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: transparencySlider.leftPadding + transparencySlider.visualPosition * (transparencySlider.availableWidth - width)
                                y: transparencySlider.topPadding + transparencySlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: Math.round(transparencySlider.value * 100) + "%"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                    
                    // Blur Strength
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Blur Strength"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: blurSlider
                            Layout.fillWidth: true
                            from: 0
                            to: 10
                            value: 5
                            stepSize: 1
                            
                            background: Rectangle {
                                x: blurSlider.leftPadding
                                y: blurSlider.topPadding + blurSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: blurSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: blurSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: blurSlider.leftPadding + blurSlider.visualPosition * (blurSlider.availableWidth - width)
                                y: blurSlider.topPadding + blurSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                            
                            onValueChanged: {
                                commandRunner.command = ["hyprctl", "keyword", "decoration:blur:size", Math.round(value).toString()]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Text {
                            text: Math.round(blurSlider.value)
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                }
            }
            
            // === LAYOUT SECTION ===
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
                        text: "Layout"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Bar Position
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Bar Position"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            id: barPositionCombo
                            Layout.fillWidth: true
                            model: ["Top", "Bottom"]
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
                            }
                        }
                    }
                    
                    // Panel Width
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Panel Width"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: panelWidthSlider
                            Layout.fillWidth: true
                            from: 30
                            to: 60
                            value: 45
                            stepSize: 5
                            
                            background: Rectangle {
                                x: panelWidthSlider.leftPadding
                                y: panelWidthSlider.topPadding + panelWidthSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: panelWidthSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: panelWidthSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: panelWidthSlider.leftPadding + panelWidthSlider.visualPosition * (panelWidthSlider.availableWidth - width)
                                y: panelWidthSlider.topPadding + panelWidthSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: Math.round(panelWidthSlider.value) + "px"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 45
                        }
                    }
                    
                    // Widget Spacing
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Widget Spacing"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: spacingSlider
                            Layout.fillWidth: true
                            from: 5
                            to: 20
                            value: 10
                            stepSize: 5
                            
                            background: Rectangle {
                                x: spacingSlider.leftPadding
                                y: spacingSlider.topPadding + spacingSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: spacingSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: spacingSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: spacingSlider.leftPadding + spacingSlider.visualPosition * (spacingSlider.availableWidth - width)
                                y: spacingSlider.topPadding + spacingSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: Math.round(spacingSlider.value) + "px"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 45
                        }
                    }
                    
                    // Enable Animations
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Enable Animations"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: animationsSwitch
                            checked: true
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: animationsSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: animationsSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: animationsSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                            
                            onCheckedChanged: {
                                commandRunner.command = ["hyprctl", "keyword", "animations:enabled", animationsSwitch.checked ? "true" : "false"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            
            // === WALLPAPER SECTION ===
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
                        text: "Wallpaper"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Select Wallpaper Button
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        color: selectWallMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Select Wallpaper"
                            color: selectWallMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        MouseArea {
                            id: selectWallMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandRunner.command = ["zenity", "--file-selection", "--title=Select Wallpaper"]
                                commandRunner.callback = function(output) {
                                    if (output.trim()) {
                                        commandRunner.command = ["swww", "img", output.trim()]
                                        commandRunner.callback = null
                                        commandRunner.running = true
                                    }
                                }
                                commandRunner.running = true
                            }
                        }
                    }
                    
                    // Slideshow Toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Slideshow"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: slideshowSwitch
                            checked: false
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: slideshowSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: slideshowSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: slideshowSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Interval Slider
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        visible: slideshowSwitch.checked
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Interval"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: intervalSlider
                            Layout.fillWidth: true
                            from: 5
                            to: 60
                            value: 15
                            stepSize: 5
                            
                            background: Rectangle {
                                x: intervalSlider.leftPadding
                                y: intervalSlider.topPadding + intervalSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: intervalSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: intervalSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: intervalSlider.leftPadding + intervalSlider.visualPosition * (intervalSlider.availableWidth - width)
                                y: intervalSlider.topPadding + intervalSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: Math.round(intervalSlider.value) + " min"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 50
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}