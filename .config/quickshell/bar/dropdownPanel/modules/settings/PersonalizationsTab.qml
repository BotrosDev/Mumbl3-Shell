import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../Data/" as Dat

Item {
    id: personalizationsTab
    
    // UI states mapped to ThemeSettings
    readonly property var fonts: Dat.Fonts

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
                        color: colorModeCombo.currentIndex === 0 ? "#1a1a1a" : "#f5f5f5"
                        radius: 8
                        border.color: Dat.Colors.color.primary
                        border.width: 2
                        
                        Behavior on color { ColorAnimation { duration: 300 } }
                        
                        // Mini bar preview
                        Rectangle {
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: barPositionCombo.currentIndex === 0 ? parent.top : undefined
                                bottom: barPositionCombo.currentIndex === 1 ? parent.bottom : undefined
                            }
                            height: 30
                            color: Dat.Colors.color.primary
                            opacity: transparencySlider.value
                            
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                spacing: spacingSlider.value / 2
                                
                                Repeater {
                                    model: 4
                                    Rectangle {
                                        width: 40
                                        height: 20
                                        color: colorModeCombo.currentIndex === 0 ? "#2a2a2a" : "#ffffff"
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
                            color: colorModeCombo.currentIndex === 0 ? "#2a2a2a" : "#ffffff"
                            radius: 6
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            opacity: transparencySlider.value
                            
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }
                        
                        // Blur indicator
                        Text {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 5
                            text: `Blur: ${Math.round(blurSlider.value)}`
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 10
                            opacity: 0.6
                        }
                    }
                }
            }
            
            // === APPEARANCE SECTION ===
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
                        text: "Appearance"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    // Color Mode (Light/Dark)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Color Mode"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        ComboBox {
                            id: colorModeCombo
                            Layout.fillWidth: true
                            model: ["Dark Mode", "Light Mode"]
                            currentIndex: Dat.ThemeSettings.colorMode === "dark" ? 0 : 1
                            
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

                            delegate: ItemDelegate {
                                width: colorModeCombo.width - 20
                                contentItem: Text {
                                    text: modelData
                                    color: parent.highlighted ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    font.pixelSize: 12
                                    leftPadding: 10
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: colorModeCombo.highlightedIndex === index
                                background: Rectangle {
                                    color: parent.highlighted ? Dat.Colors.color.primary : "transparent"
                                    radius: 4
                                }
                            }

                            popup: Popup {
                                y: colorModeCombo.height + 5
                                width: colorModeCombo.width
                                implicitHeight: contentItem.implicitHeight + 10
                                padding: 5

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: colorModeCombo.delegateModel
                                    currentIndex: colorModeCombo.highlightedIndex
                                }

                                background: Rectangle {
                                    color: Dat.Colors.color.surface
                                    radius: 8
                                    border.color: Dat.Colors.color.primary
                                    border.width: 1
                                }
                            }
                            
                            onCurrentIndexChanged: {
                                var mode = currentIndex === 0 ? "dark" : "light"
                                Dat.ThemeSettings.setColorMode(mode)
                            }
                        }
                    }
                    
                    // Palette Selector (0-4)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.preferredWidth: 120
                            text: "Color Palette"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        
                        // Palette buttons
                        Row {
                            spacing: 8
                            
                            Repeater {
                                model: 5
                                
                                Rectangle {
                                    width: 40
                                    height: 40
                                    radius: 20
                                    color: paletteIndexSlider.value === index ? Dat.Colors.color.primary : Dat.Colors.color.surface
                                    border.color: Dat.Colors.color.primary
                                    border.width: 2
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: (index + 1).toString()
                                        color: paletteIndexSlider.value === index ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                        font.pixelSize: 14
                                        font.bold: true
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            paletteIndexSlider.value = index
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Hidden slider for state management
                        Slider {
                            id: paletteIndexSlider
                            visible: false
                            from: 0
                            to: 4
                            stepSize: 1
                            value: 0
                            
                            onValueChanged: {
                                Dat.ThemeSettings.setPaletteIndex(Math.round(value))
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    Text {
                        text: "Tip: Each palette shows different color schemes from your wallpaper"
                        color: Dat.Colors.color.on_surface
                        font.pixelSize: 10
                        opacity: 0.6
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
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
                            from: 0
                            to: 1.0
                            value: Dat.ThemeSettings.transparency
                            stepSize: 0.01
                            
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
                            
                            onPressedChanged: {
                                if (!pressed) {
                                    Dat.ThemeSettings.setTransparency(value)
                                }
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
                            value: Dat.ThemeSettings.blurStrength
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
                            
                            onPressedChanged: {
                                if (!pressed) {
                                    Dat.ThemeSettings.setBlurStrength(value)
                                }
                            }
                        }
                        
                        Text {
                            text: Math.round(blurSlider.value).toString()
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
                            currentIndex: Dat.ThemeSettings.barPosition === "top" ? 0 : 1
                            
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

                            delegate: ItemDelegate {
                                width: barPositionCombo.width - 20
                                contentItem: Text {
                                    text: modelData
                                    color: parent.highlighted ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    font.pixelSize: 12
                                    leftPadding: 10
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: barPositionCombo.highlightedIndex === index
                                background: Rectangle {
                                    color: parent.highlighted ? Dat.Colors.color.primary : "transparent"
                                    radius: 4
                                }
                            }

                            popup: Popup {
                                y: barPositionCombo.height + 5
                                width: barPositionCombo.width
                                implicitHeight: contentItem.implicitHeight + 10
                                padding: 5

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: barPositionCombo.delegateModel
                                    currentIndex: barPositionCombo.highlightedIndex
                                }

                                background: Rectangle {
                                    color: Dat.Colors.color.surface
                                    radius: 8
                                    border.color: Dat.Colors.color.primary
                                    border.width: 1
                                }
                            }
                            
                            onCurrentIndexChanged: {
                                var position = currentIndex === 0 ? "top" : "bottom"
                                Dat.ThemeSettings.setBarPosition(position)
                            }
                        }
                        
                        Text {
                            text: "Requires restart"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 10
                            opacity: 0.5
                        }
                    }

                    // Font (options from Data/Fonts.qml)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        Text {
                            Layout.preferredWidth: 120
                            text: "Font"
                            color: Dat.Colors.color.on_surface
                            font.pixelSize: 12
                        }
                        ComboBox {
                            id: fontCombo
                            Layout.fillWidth: true
                            model: Dat.Fonts.fontDisplayNames
                            currentIndex: Math.max(0, Dat.Fonts.fontFamilies.indexOf(Dat.ThemeSettings.fontFamily))

                            background: Rectangle {
                                color: Dat.Colors.color.surface
                                radius: 6
                                border.color: Dat.Colors.color.primary
                                border.width: 1
                            }

                            contentItem: Text {
                                text: parent.displayText
                                color: Dat.Colors.color.on_surface
                                font.family: Dat.ThemeSettings.fontFamily
                                leftPadding: 10
                                verticalAlignment: Text.AlignVCenter
                            }

                            // Customize how each option looks in the dropdown (each in its own font)
                            delegate: ItemDelegate {
                                width: fontCombo.width - 20
                                contentItem: Text {
                                    text: modelData
                                    color: parent.highlighted ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                                    font.family: index >= 0 && index < Dat.Fonts.fontFamilies.length ? Dat.Fonts.fontFamilies[index] : ""
                                    font.pixelSize: 12
                                    leftPadding: 10
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: fontCombo.highlightedIndex === index
                                background: Rectangle {
                                    color: parent.highlighted ? Dat.Colors.color.primary : "transparent"
                                    radius: 4
                                }
                            }

                            popup: Popup {
                                y: fontCombo.height + 5
                                width: fontCombo.width
                                implicitHeight: Math.min(contentItem.implicitHeight + 10, 400) // limit height
                                padding: 5

                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: fontCombo.delegateModel
                                    currentIndex: fontCombo.highlightedIndex
                                }

                                background: Rectangle {
                                    color: Dat.Colors.color.surface
                                    radius: 8
                                    border.color: Dat.Colors.color.primary
                                    border.width: 1
                                }
                            }

                            onCurrentIndexChanged: {
                                if (currentIndex >= 0 && currentIndex < Dat.Fonts.fontFamilies.length)
                                    Dat.ThemeSettings.setFontFamily(Dat.Fonts.fontFamilies[currentIndex])
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
                            value: Dat.ThemeSettings.panelWidth
                            stepSize: 1
                            
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
                            
                            onMoved: {
                                Dat.ThemeSettings.setPanelWidth(Math.round(value))
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
                            value: Dat.ThemeSettings.widgetSpacing
                            stepSize: 1
                            
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
                            
                            onMoved: {
                                Dat.ThemeSettings.setWidgetSpacing(Math.round(value))
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
                            checked: Dat.ThemeSettings.animationsEnabled
                            
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
                            
                            onToggled: {
                                Dat.ThemeSettings.setAnimationsEnabled(checked)
                            }
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
}
