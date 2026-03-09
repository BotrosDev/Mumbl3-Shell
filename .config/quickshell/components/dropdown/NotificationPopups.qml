import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "../../core" as Dat
import "../generics" as Gen

Item {
    id: root

    Component {
        id: popupComponent
        
        PanelWindow {
            id: popupWindow
            property Notification notif
            
            anchors {
                top: true
                right: true
            }
            
            implicitWidth: 370 // Increased to accommodate margins inside
            implicitHeight: 140
            color: "transparent"
            
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 20
                anchors.rightMargin: 20
                color: Dat.Colors.color.surface
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Rectangle {
                        Layout.preferredWidth: 48
                        Layout.preferredHeight: 48
                        radius: 24
                        color: Dat.Colors.color.primary_container
                        
                        Text {
                            anchors.centerIn: parent
                            text: ""
                            font.pixelSize: 24
                            color: Dat.Colors.color.on_primary_container
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: popupWindow.notif.summary || popupWindow.notif.appName || "Notification"
                            font.bold: true
                            font.pixelSize: 14
                            color: Dat.Colors.color.on_surface
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            text: popupWindow.notif.body
                            font.pixelSize: 12
                            color: Dat.Colors.color.on_surface_variant
                            elide: Text.ElideRight
                            maximumLineCount: 2
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        popupWindow.visible = false;
                        popupWindow.destroy();
                    }
                }
            }
            
            Timer {
                interval: 5000
                running: true
                onTriggered: {
                    popupWindow.visible = false;
                    popupWindow.destroy();
                }
            }
        }
    }

Connections {
    // Only bind if the server actually exists
    target: Dat.NotifServer.server ? Dat.NotifServer.server : null
    
    // Optional: ignore errors if the target is null temporarily
    ignoreUnknownSignals: true 

    function onNotification(n) {
        if (!Dat.NotifServer.dndEnabled) {
            var popup = popupComponent.createObject(root, { "notif": n });
            popup.visible = true;
        }
    }
}

}
