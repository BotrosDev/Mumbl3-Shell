import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io
import "../Data" as Dat

Rectangle {
    id: appWindow
    property string searchQuery: ""

    color: Dat.Colors.color.surface_variant
    radius: 12
    border.color: Dat.Colors.color.primary
    border.width: 2

    Process { id: launcherProcess }

    Process {
        id: countUpdater
        property string pendingApp: ""
        command: [
            "python3",
            "/home/SillyGoat/.config/quickshell/scripts/mumbl3-increment-count.py",
            countUpdater.pendingApp
        ]
    }

    ListModel { id: appsModel }

    Process {
        id: appsDiscovery
        command: ["python3", "/home/SillyGoat/.config/quickshell/scripts/mumbl3-list-apps.py"]

        stdout: StdioCollector {
            onStreamFinished: {
                const output = this.text.trim();
                appsModel.clear();
                if (!output) return;

                const lines = output.split("\n");
                for (let i = 0; i < lines.length; ++i) {
                    const parts = lines[i].split("|");
                    if (parts.length < 2) continue;
                    appsModel.append({
                        name:  parts[0],
                        exec:  parts[1],
                        icon:  parts.length > 2 ? parts[2] : "",
                        count: parts.length > 3 ? parseInt(parts[3]) : 0
                    });
                }
            }
        }
    }

    Component.onCompleted: appsDiscovery.running = true

    function matchesFilter(appName) {
        if (!searchQuery || searchQuery.trim().length === 0) return true;
        return appName.toLowerCase().indexOf(searchQuery.toLowerCase()) !== -1;
    }

    Rectangle {
        anchors.centerIn: parent
        height: appWindow.height - 20
        width: appWindow.width - 20
        radius: 12
        color: Dat.Colors.color.surface

        // search field doesn't work in dropdown panels for some reason. 
        // so i deleted it `Emilia``: love you Botros <3

        ColumnLayout {
            anchors { margins: 20; fill: parent }
            spacing: 12


            ScrollView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                GridView {
                    id: appsGrid
                    anchors.fill: parent
                    cellWidth: 96
                    cellHeight: 96
                    model: appsModel
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Item {
                        width: 96
                        height: 96

                        readonly property string appName:  name   // not namee
                        readonly property string appExec:  exec   // not execc
                        readonly property string appIcon:  icon   // not iconn
                        readonly property int    appCount: count

                        visible: appWindow.matchesFilter(appName)

                        Column {
                            anchors.centerIn: parent
                            spacing: 6

                            Rectangle {
                                width: 48
                                height: 48
                                radius: 10
                                color: mouseArea.containsMouse
                                       ? Dat.Colors.color.surface_variant
                                       : Dat.Colors.color.surface_container_high
                                border.width: 1
                                border.color: Dat.Colors.color.outline_variant

                                Text {
                                    anchors.centerIn: parent
                                    text: appName.length > 0 ? appName[0].toUpperCase() : "?"
                                    color: Dat.Colors.color.primary
                                    font.pixelSize: 20
                                    font.bold: true
                                }

                                Image {
                                    id: iconImg
                                    anchors.fill: parent
                                    anchors.margins: 6
                                    source: appIcon !== "" ? ("file://" + appIcon) : ""
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    asynchronous: true
                                    visible: status === Image.Ready
                                }
                            }

                            Text {
                                width: 84
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideRight
                                text: appName
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 11
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                if (!appExec || appExec.trim().length === 0) return;
                                countUpdater.pendingApp = appName;
                                countUpdater.running = true;
                                launcherProcess.command = appExec.trim().split(/\s+/);
                                launcherProcess.running = true;
                            }
                        }
                    }
                }
            }
        }
    }
}