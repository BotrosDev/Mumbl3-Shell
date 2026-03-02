import QtQuick
import QtQuick.Layouts
import Quickshell
import "../Data/" as Dat

Rectangle {
    id: settingsWindow
    
    property int tabHeight: 30
    property int spacing: 10
    property int currentPage: 0
    property int selectedTab: 0  // Track which tab is clicked
    
    readonly property var tabPages: [
        ["System", "Devices", "Networks", "Personalizations"],
        ["Accounts", "Data", "Power", "Privacy"]
    ]
    
    readonly property var tabSources: [
        ["settings/SystemTab.qml", "settings/DevicesTab.qml", "settings/NetworksTab.qml", "settings/PersonalizationsTab.qml"],
        ["settings/AccountsTab.qml", "settings/DataTab.qml", "settings/PowerTab.qml", "settings/PrivacyTab.qml"]
    ]
    
    color: Dat.Colors.color.surface
    radius: 4
    border.color: Dat.Colors.color.primary
    border.width: 1
    
    // Tab navigation container
    Item {
        id: tabContainer
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: spacing
        }
        height: settingsWindow.tabHeight
        
        // Navigation buttons row
        RowLayout {
            anchors.fill: parent
            spacing: settingsWindow.spacing
            
            // Previous button
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: settingsWindow.tabHeight
                color: prevMouse.containsMouse && settingsWindow.currentPage === 1 
                       ? Dat.Colors.color.surface_variant 
                       : Dat.Colors.color.surface
                radius: 4
                border.color: Dat.Colors.color.primary
                border.width: 1
                opacity: settingsWindow.currentPage === 1 ? 1.0 : 0.3
                
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
                
                Text {
                    anchors.centerIn: parent
                    text: "<"
                    color: Dat.Colors.color.on_surface
                    font.pixelSize: 16
                    font.bold: true
                }
                
                MouseArea {
                    id: prevMouse
                    anchors.fill: parent
                    hoverEnabled: settingsWindow.currentPage === 1
                    cursorShape: settingsWindow.currentPage === 1 ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    enabled: settingsWindow.currentPage === 1
                    onClicked: {
                        settingsWindow.currentPage = 0
                        settingsWindow.selectedTab = 0  // Reset to first tab
                    }
                }
            }
            
            // Tabs viewport with sliding
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: settingsWindow.tabHeight
                clip: true
                
                // First page tabs
                RowLayout {
                    id: page1Tabs
                    width: parent.width
                    height: parent.height
                    spacing: settingsWindow.spacing
                    x: settingsWindow.currentPage === 0 ? 0 : -width
                    opacity: settingsWindow.currentPage === 0 ? 1 : 0
                    
                    Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                    
                    Repeater {
                        model: settingsWindow.tabPages[0]
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: settingsWindow.tabHeight
                            color: {
                                if (settingsWindow.currentPage === 0 && settingsWindow.selectedTab === index) {
                                    return Dat.Colors.color.primary
                                }
                                return mouseArea1.containsMouse ? Dat.Colors.color.surface_variant : Dat.Colors.color.surface
                            }
                            radius: 4
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            MouseArea {
                                id: mouseArea1
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    settingsWindow.selectedTab = index
                                }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: settingsWindow.currentPage === 0 && settingsWindow.selectedTab === index 
                                       ? Dat.Colors.color.on_primary 
                                       : Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                        }
                    }
                }
                
                // Second page tabs
                RowLayout {
                    id: page2Tabs
                    width: parent.width
                    height: parent.height
                    spacing: settingsWindow.spacing
                    x: settingsWindow.currentPage === 1 ? 0 : width
                    opacity: settingsWindow.currentPage === 1 ? 1 : 0
                    
                    Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                    
                    Repeater {
                        model: settingsWindow.tabPages[1]
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: settingsWindow.tabHeight
                            color: {
                                if (settingsWindow.currentPage === 1 && settingsWindow.selectedTab === index) {
                                    return Dat.Colors.color.primary
                                }
                                return mouseArea2.containsMouse ? Dat.Colors.color.surface_variant : Dat.Colors.color.surface
                            }
                            radius: 4
                            border.color: Dat.Colors.color.primary
                            border.width: 1
                            
                            Behavior on color { ColorAnimation { duration: 150 } }
                            
                            MouseArea {
                                id: mouseArea2
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    settingsWindow.selectedTab = index
                                }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: settingsWindow.currentPage === 1 && settingsWindow.selectedTab === index 
                                       ? Dat.Colors.color.on_primary 
                                       : Dat.Colors.color.on_surface
                                font.pixelSize: 12
                            }
                        }
                    }
                }
            }
            
            // Next button
            Rectangle {
                Layout.preferredWidth: 30
                Layout.preferredHeight: settingsWindow.tabHeight
                color: nextMouse.containsMouse && settingsWindow.currentPage === 0 
                       ? Dat.Colors.color.surface_variant 
                       : Dat.Colors.color.surface
                radius: 4
                border.color: Dat.Colors.color.primary
                border.width: 1
                opacity: settingsWindow.currentPage === 0 ? 1.0 : 0.3
                
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on opacity { NumberAnimation { duration: 200 } }
                
                Text {
                    anchors.centerIn: parent
                    text: ">"
                    color: Dat.Colors.color.on_surface
                    font.pixelSize: 16
                    font.bold: true
                }
                
                MouseArea {
                    id: nextMouse
                    anchors.fill: parent
                    hoverEnabled: settingsWindow.currentPage === 0
                    cursorShape: settingsWindow.currentPage === 0 ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                    enabled: settingsWindow.currentPage === 0
                    onClicked: {
                        settingsWindow.currentPage = 1
                        settingsWindow.selectedTab = 0  // Reset to first tab
                    }
                }
            }
        }
    }
    
    // Content area with dynamic loader
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            top: tabContainer.bottom
            bottom: parent.bottom
            margins: spacing
        }
        color: Dat.Colors.color.surface
        radius: 4
        border.color: Dat.Colors.color.primary
        border.width: 1
        
        Loader {
            anchors.fill: parent
            anchors.margins: spacing
            source: settingsWindow.tabSources[settingsWindow.currentPage][settingsWindow.selectedTab]
            
            onStatusChanged: {
                if (status === Loader.Error) {
                    console.error("Failed to load:", source)
                }
            }
        }
    }
}