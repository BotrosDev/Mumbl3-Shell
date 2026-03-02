// WallpaperSelector.qml
import Quickshell
import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import QtCore
import Quickshell.Io
import Quickshell.Hyprland
import "../Data" as Dat

Item {
    id: wallpaperSelector

    signal closeRequested()   

    property string wallpaperDir: StandardPaths.writableLocation(StandardPaths.PicturesLocation) + "/Wallpapers"

    function setWallpaper(path) {
        setWallpaperProc.command = ["swww", "img", path, "--transition-type", "fade", "--transition-fps", "60"]
        setWallpaperProc.running = true
        
        // Generate colors with matugen (source-color-index prevents interactive prompt)
        matugenProc.command = ["matugen", "image", path, "--mode", "dark", "--source-color-index", "0"]
        matugenProc.running = true
        
        closeRequested()   
    }
    
    // FolderListModel 
    FolderListModel {
        id: folderModel
        folder: wallpaperDir  
        nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.JPEG", "*.PNG", "*.WEBP"]
        showDirs: false
        sortField: FolderListModel.Name
    }
    
    Rectangle {
        id: mainContainer
        anchors.fill: parent
        color: Dat.Colors.color.surface_variant
        radius: 12
        border.color: Dat.Colors.color.primary
        border.width: 2
        
        Column {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15
            
            // Path display
            Text {
                text: "Directory: " + wallpaperDir
                color: Dat.Colors.color.on_surface
                font.pixelSize: 12
                font.family: "monospace"
            }
            
            // Scrollable grid view
            Rectangle {
                width: parent.width
                height: parent.height - 80
                color: Dat.Colors.color.surface
                border.color: Dat.Colors.color.primary
                radius: 8
                clip: true
                
                GridView {
                    id: gridView
                    anchors.fill: parent
                    anchors.margins: 10
                    
                    cellWidth: 265  
                    cellHeight: 195  
                    
                    model: folderModel
                    clip: true
                    
                    // only keep a small cache of items outside visible area to prevent memory bloat with many wallpapers
                    cacheBuffer: 400  // Only keep ~2 rows outside visible area
                    
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                    
                    delegate: Rectangle {
                        id: rect
                        required property string filePath
                        required property string fileName
                        
                        width: 250
                        height: 180
                        color: Dat.Colors.color.surface_variant
                        radius: 8
                        border.color: itemMouseArea.containsMouse ? Dat.Colors.color.primary : "transparent"
                        border.width: 2
                        
                        Behavior on border.color {
                            ColorAnimation { duration: 150 }
                        }
                        
                        Column {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 5
                            
                            // Image preview
                            Rectangle {
                                width: parent.width
                                height: parent.height - 30
                                color: Dat.Colors.color.surface
                                radius: 4
                                clip: true
                                
                                Image {
                                    anchors.fill: parent
                                    source: "file://" + rect.filePath
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                    cache: false  // Don't cache to avoid memory issues with many images
                                    
                                    // Show loading indicator
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Loading..."
                                        color: Dat.Colors.color.on_surface
                                        visible: parent.status === Image.Loading
                                    }
                                    
                                    // Show error if image fails to load
                                    Text {
                                        anchors.centerIn: parent
                                        text: "Image failed to load :("
                                        color: Dat.Colors.color.error
                                        visible: parent.status === Image.Error
                                    }
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        color: "transparent"
                                        border.color: Dat.Colors.color.primary
                                        border.width: 1
                                        radius: 4
                                    }
                                }
                            }
                            
                            // Filename
                            Text {
                                width: parent.width
                                text: rect.fileName
                                color: Dat.Colors.color.on_surface
                                font.pixelSize: 11
                                font.family: "monospace"
                                elide: Text.ElideMiddle
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        
                        MouseArea {
                            id: itemMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            
                            onClicked: {
                                wallpaperSelector.setWallpaper(rect.filePath)
                            }
                        }
                    }
                }
                
                // Empty state
                Text {
                    visible: folderModel.count === 0
                    anchors.centerIn: parent
                    text: "No wallpapers found in:\n" + folderModel.folder + "\n\n" +
                          "Looking for: *.jpg, *.jpeg, *.png, *.webp\n\n" +
                          "Make sure the folder exists and contains image files"
                    color: Dat.Colors.color.on_surface
                    font.pixelSize: 14
                    font.family: "monospace"
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
    
    // Process to set wallpaper
    Process {
        id: setWallpaperProc
        running: false
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0) {
                    console.log("Wallpaper set error:", this.text)
                }
            }
        }
    }
    
    // Process to generate colors with matugen
    Process {
        id: matugenProc
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("Matugen output:", this.text)
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (this.text.trim().length > 0) {
                    console.log("Matugen error:", this.text)
                }
            }
        }
    }
}