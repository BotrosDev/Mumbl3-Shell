import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../core" as Dat

Item {
    id: launcherRoot
    
    property bool isOpen: false
    
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Dat.ThemeSettings.panelWidth + 5 // Above the bar
    
    width: 600
    height: 400
    
    // Animation
    opacity: isOpen ? 1 : 0
    scale: isOpen ? 1 : 0.95
    visible: opacity > 0
    
    Behavior on opacity { NumberAnimation { duration: 200 }} 
    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    Rectangle {
        anchors.fill: parent
        color: Dat.Colors.color.surface
        radius: 12
        border.color: Dat.Colors.color.primary
        border.width: 2
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            
            Text {
                text: "Simple Launcher"
                font.pixelSize: 24
                color: Dat.Colors.color.primary
                Layout.alignment: Qt.AlignHCenter
            }
            
            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Search..."
                focus: true
                
                onAccepted: {
                    launcherRoot.isOpen = false
                }
                
                Keys.onEscapePressed: {
                    launcherRoot.isOpen = false
                }
            }
            
            Item { Layout.fillHeight: true }
        }
    }
    
    onIsOpenChanged: {
        if (isOpen) {
            searchInput.forceActiveFocus();
        } else {
            searchInput.text = "";
        }
    }
}
