import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import Qt5Compat.GraphicalEffects
import "../Data/" as Dat

Item {
    id: root
    signal closeRequested()
    property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
        property int playbackState: player?.playbackState ?? MprisPlaybackState.Stopped
            Timer {
                interval: 500 
                running: player && player.playbackState === MprisPlaybackState.Playing
                repeat: true
                onTriggered: {
                    if (player)
                    {
                        player.positionChanged()  
                    }
                }
            }
            Rectangle {
                anchors.fill: parent
                color: Dat.Colors.color.surface
                radius: 12
                border.color: Dat.Colors.color.primary
                border.width: 1
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 20

                    // HEADER 
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Media Player"
                            font.pixelSize: 24
                            font.bold: true
                            color: Dat.Colors.color.on_surface
                        }
                        Item { Layout.fillWidth: true }
                    }

                    // ALBUM ART & INFO 
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 20

                        // Album Art
                        Rectangle {
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 200
                            Layout.alignment: Qt.AlignTop
                            color: Dat.Colors.color.surface_variant
                            radius: 8
                            border.color: Dat.Colors.color.primary
                            border.width: 1

                            Image {
                                anchors.fill: parent
                                anchors.margins: 1
                                source: player?.trackArtUrl ?? ""
                                fillMode: Image.PreserveAspectCrop
                                visible: source != ""
                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: 12
                                        height: 12
                                        radius: 8
                                    }
                                }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "" 
                                font.pixelSize: 64
                                color: Dat.Colors.color.on_surface_variant
                                visible: !player || player.trackArtUrl === ""
                            }
                        }

                        // Info
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.alignment: Qt.AlignTop
                            spacing: 8

                            // Title
                            Text {
                                Layout.fillWidth: true
                                text: player?.trackTitle ?? "No media playing"
                                font.pixelSize: 22
                                font.bold: true
                                color: Dat.Colors.color.on_surface
                                elide: Text.ElideRight
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                            }

                            // Artist
                            Text {
                                Layout.fillWidth: true
                                text: player?.trackArtist ?? ""
                                font.pixelSize: 16
                                color: Dat.Colors.color.on_surface_variant  
                                elide: Text.ElideRight
                                visible: text != ""
                            }

                            // Album
                            Text {
                                Layout.fillWidth: true
                                text: player?.trackAlbum ?? ""
                                font.pixelSize: 14
                                color: Dat.Colors.color.on_surface_variant
                                elide: Text.ElideRight
                                visible: text != ""
                            }
                            Item { Layout.fillHeight: true }

                            // Progress bar
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 6
                                    radius: 3
                                    color: Dat.Colors.color.surface_variant
                                    border.color: Dat.Colors.color.primary
                                    border.width: 1


                                    Rectangle {
                                        id: progressBar
                                        width: {
                                            if (!player) return 0
                                            var pos = player.position ?? 0
                                            var len = player.length ?? 1
                                            return parent.width * pos / Math.max(len, 1)
                                        }
                                        height: parent.height
                                        radius: parent.radius
                                        color: Dat.Colors.color.primary
                                        Behavior on width {
                                        NumberAnimation { duration: 100 }
                                    }
                                }
                            }

                            // Time labels
                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    id: positionText
                                    text: formatTime(player?.position ?? 0)
                                    font.pixelSize: 12
                                    color: Dat.Colors.color.on_surface_variant
                                }
                                Item { Layout.fillWidth: true }

                                Text {
                                    text: formatTime(player?.length ?? 0)
                                    font.pixelSize: 12
                                    color: Dat.Colors.color.on_surface_variant
                                }
                            }
                        }
                    }
                }

                // CONTROLS 
                RowLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12
                    Item { Layout.fillWidth: true }

                    MediaControlButton {
                        text: "⏮"
                        enabled: player?.canGoPrevious ?? false
                        onClicked: if (player) player.previous()
                    }

                    MediaControlButton {
                        text: root.playbackState === MprisPlaybackState.Playing ? "⏸" : "▶"
                        fontSize: 32
                        buttonSize: 64
                        enabled: player?.canControl ?? false
                        onClicked: {
                            if (player)
                            {
                                if (root.playbackState === MprisPlaybackState.Playing)
                                {
                                    player.pause()
                                } else {
                                player.play()
                            }
                        }
                    }
                }

                MediaControlButton {
                    text: "⏭"
                    enabled: player?.canGoNext ?? false
                    onClicked: if (player) player.next()
                }
                Item { Layout.fillWidth: true }

            }

            //  STATUS INFO 
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: {
                    if (!player) return "No media player detected"
                    if (player.trackTitle === "") return "No media playing"
                    return ""
                }
                font.pixelSize: 12
                color: Dat.Colors.color.on_surface_variant
                visible: text != ""
            }
        }
    }

    // Helper function to format time
    function formatTime(seconds)
    {
        var mins = Math.floor(seconds / 60)
        var secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
    // Nested component for control buttons
    component MediaControlButton: Rectangle {
    property alias text: buttonText.text
        property int fontSize: 24
            property int buttonSize: 52
                property bool enabled: true
                    signal clicked()
                    width: buttonSize
                    height: buttonSize
                    radius: buttonSize / 2
                    color: {
                        if (!enabled) return Dat.Colors.color.surface_variant
                        return mouseArea.containsMouse ? Dat.Colors.color.primary : Dat.Colors.color.surface
                    }
                    opacity: enabled ? 1.0 : 0.3
                    Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                Text {
                    id: buttonText
                    anchors.centerIn: parent
                    font.pixelSize: fontSize
                    color: enabled && mouseArea.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface_variant
                    Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
            
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: enabled
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                enabled: parent.enabled
                onClicked: parent.clicked()
            }
        }
    }