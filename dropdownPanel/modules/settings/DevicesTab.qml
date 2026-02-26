import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../Data/" as Dat

Item {
    id: devicesTab
    
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
            
            // === DISPLAY SECTION ===
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
                    spacing: 12
                    
                    Text {
                        text: "Display"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Resolution
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Resolution"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["1920x1080", "2560x1440", "3840x2160"]
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
                    
                    // Refresh Rate
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Refresh Rate"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["60Hz", "75Hz", "120Hz", "144Hz", "165Hz"]
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
                    
                    // Scale Factor
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Scale Factor"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: scaleSlider
                            Layout.fillWidth: true
                            from: 1.0
                            to: 2.0
                            value: 1.0
                            stepSize: 0.25
                            
                            background: Rectangle {
                                x: scaleSlider.leftPadding
                                y: scaleSlider.topPadding + scaleSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: scaleSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: scaleSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: scaleSlider.leftPadding + scaleSlider.visualPosition * (scaleSlider.availableWidth - width)
                                y: scaleSlider.topPadding + scaleSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: scaleSlider.value.toFixed(2) + "x"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                    
                    // Night Light
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Night Light"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: nightLightSwitch
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: nightLightSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: nightLightSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: nightLightSwitch.checked ? parent.width - width - 2 : 2
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
                    
                    // Brightness
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Brightness"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: brightnessSlider
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: 70
                            
                            background: Rectangle {
                                x: brightnessSlider.leftPadding
                                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: brightnessSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: brightnessSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width)
                                y: brightnessSlider.topPadding + brightnessSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                            
                            onValueChanged: {
                                commandRunner.command = ["brightnessctl", "set", Math.round(value) + "%"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Text {
                            text: Math.round(brightnessSlider.value) + "%"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                }
            }
            
            // === AUDIO SECTION ===
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
                    spacing: 12
                    
                    Text {
                        text: "Audio"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Output Device
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Output Device"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Built-in Audio", "HDMI Output", "USB Headset"]
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
                    
                    // Volume
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Volume"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: volumeSlider
                            Layout.fillWidth: true
                            from: 0
                            to: 100
                            value: 50
                            
                            background: Rectangle {
                                x: volumeSlider.leftPadding
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: volumeSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: volumeSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                                y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                            
                            onValueChanged: {
                                commandRunner.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", Math.round(value) + "%"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Text {
                            text: Math.round(volumeSlider.value) + "%"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                    
                    // Microphone
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Microphone"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Built-in Microphone", "USB Microphone"]
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
                    
                    // Test Sound Button
                    Rectangle {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 32
                        color: testSoundMouse.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                        radius: 6
                        border.color: Dat.Colors.color.primary
                        border.width: 1
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "Test Sound"
                            color: testSoundMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                            font.pixelSize: 11
                        }
                        
                        MouseArea {
                            id: testSoundMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                commandRunner.command = ["paplay", "/usr/share/sounds/freedesktop/stereo/bell.oga"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                    }
                }
            }
            
            // === INPUT SECTION ===
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
                        text: "Input Devices"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Mouse Sensitivity
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Mouse Sensitivity"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: mouseSensSlider
                            Layout.fillWidth: true
                            from: 0.5
                            to: 2.0
                            value: 1.0
                            stepSize: 0.1
                            
                            background: Rectangle {
                                x: mouseSensSlider.leftPadding
                                y: mouseSensSlider.topPadding + mouseSensSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: mouseSensSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: mouseSensSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: mouseSensSlider.leftPadding + mouseSensSlider.visualPosition * (mouseSensSlider.availableWidth - width)
                                y: mouseSensSlider.topPadding + mouseSensSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: mouseSensSlider.value.toFixed(1) + "x"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                    
                    // Scroll Speed
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Scroll Speed"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: scrollSlider
                            Layout.fillWidth: true
                            from: 1
                            to: 5
                            value: 3
                            stepSize: 1
                            
                            background: Rectangle {
                                x: scrollSlider.leftPadding
                                y: scrollSlider.topPadding + scrollSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: scrollSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: scrollSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: scrollSlider.leftPadding + scrollSlider.visualPosition * (scrollSlider.availableWidth - width)
                                y: scrollSlider.topPadding + scrollSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: Math.round(scrollSlider.value)
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                            Layout.preferredWidth: 40
                        }
                    }
                    
                    // Touchpad Toggle
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Touchpad"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Switch {
                            id: touchpadSwitch
                            checked: true
                            
                            indicator: Rectangle {
                                implicitWidth: 48
                                implicitHeight: 24
                                x: touchpadSwitch.leftPadding
                                y: parent.height / 2 - height / 2
                                radius: 12
                                color: touchpadSwitch.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                                
                                Rectangle {
                                    x: touchpadSwitch.checked ? parent.width - width - 2 : 2
                                    y: 2
                                    width: 20
                                    height: 20
                                    radius: 10
                                    color: Dat.Colors.color.on_primary
                                    
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                            }
                            
                            onCheckedChanged: {
                                commandRunner.command = ["xinput", touchpadSwitch.checked ? "enable" : "disable", "touchpad"]
                                commandRunner.callback = null
                                commandRunner.running = true
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Keyboard Repeat Rate
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Key Repeat Rate"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        Slider {
                            id: repeatSlider
                            Layout.fillWidth: true
                            from: 20
                            to: 60
                            value: 40
                            stepSize: 5
                            
                            background: Rectangle {
                                x: repeatSlider.leftPadding
                                y: repeatSlider.topPadding + repeatSlider.availableHeight / 2 - height / 2
                                implicitWidth: 200
                                implicitHeight: 4
                                width: repeatSlider.availableWidth
                                height: implicitHeight
                                radius: 2
                                color: Dat.Colors.color.surface
                                
                                Rectangle {
                                    width: repeatSlider.visualPosition * parent.width
                                    height: parent.height
                                    color: Dat.Colors.color.primary
                                    radius: 2
                                }
                            }
                            
                            handle: Rectangle {
                                x: repeatSlider.leftPadding + repeatSlider.visualPosition * (repeatSlider.availableWidth - width)
                                y: repeatSlider.topPadding + repeatSlider.availableHeight / 2 - height / 2
                                implicitWidth: 16
                                implicitHeight: 16
                                radius: 8
                                color: Dat.Colors.color.primary
                                border.color: Dat.Colors.color.on_primary
                                border.width: 2
                            }
                        }
                        
                        Text {
                            text: Math.round(repeatSlider.value)
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