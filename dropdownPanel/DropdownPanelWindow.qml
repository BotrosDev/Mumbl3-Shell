// DropdownPanelWindow.qml

import QtQuick
import Quickshell
import QtQuick.Layouts
import Quickshell.Io
import QtQuick.Particles
import "modules"
import "WallpaperSelector"
import "Data" as Dat

PanelWindow {
    id: dropdownPanel

    anchors { top: true; left: true; right: true; }
    implicitHeight: 550
    color: "transparent"

    property bool isOpen: false
        property bool showWallpaperSelector: false
            property bool showCalendar: false
                property bool showAppLauncher: false
                    property bool showMediaPlayer: false
                        property bool showNotifications: false
                            property bool showSettings: false
                                property bool showDefault: false

                                    Behavior on isOpen {
                                    NumberAnimation {
                                        duration: 220
                                        easing.type: Easing.OutQuad
                                    }
                                }

                                visible: isOpen

                                Rectangle {
                                    anchors.fill: parent
                                    color: Dat.Colors.color.background
                                    radius: 2
                                    opacity: 0.85
                                    clip: true


                                    // TOP BAR (always visible)
                                    RowLayout {
                                        anchors {
                                            top: parent.top
                                            left: parent.left
                                            right: parent.right
                                            topMargin: 20
                                            leftMargin: 30
                                            rightMargin: 30
                                        }
                                        spacing: 20

                                        // Clock (left)
                                        DropdownPanelClock {
                                            Layout.preferredWidth: 480
                                            Layout.preferredHeight: 480
                                            clip: true
                                        }
                                    }

                                    // Top right buttons
                                    RowLayout {
                                        id: topRightButtons
                                        anchors {
                                            top: parent.top
                                            right: parent.right
                                            topMargin: 18
                                            rightMargin: 18
                                        }
                                        spacing: 12


                                        WallpaperButton {
                                            onClicked: {
                                                showWallpaperSelector = !showWallpaperSelector
                                                showCalendar = false  // Close others
                                                showAppLauncher = false
                                                showSettings = false
                                                isOpen = true // just to make sure 
                                            }
                                        }

                                        CalendarButton {
                                            onClicked: {
                                                showCalendar = !showCalendar
                                                showWallpaperSelector = false
                                                showAppLauncher = false
                                                showSettings = false
                                                isOpen = true
                                            }
                                        }

                                        AppLauncherButton {
                                            onClicked: {
                                                showAppLauncher = !showAppLauncher
                                                showCalendar = false
                                                showSettings = false
                                                showWallpaperSelector = false
                                                isOpen = true
                                            }
                                        }

                                        MediaPlayerButton {
                                            onClicked: {
                                                showMediaPlayer = !showMediaPlayer
                                                showNotifications = false // dont let media player and notifications be open at the same time
                                                isOpen = true
                                            }
                                        }

                                        NotifButton {
                                            onClicked: {
                                                showNotifications = !showNotifications
                                                showMediaPlayer = false
                                                isOpen = true
                                            }
                                        }

                                        SettingsButton {
                                            onClicked: {
                                                showSettings = !showSettings
                                                showWallpaperSelector = false  // Close others
                                                showCalendar = false
                                                showAppLauncher = false
                                                isOpen = true
                                            }
                                        }
                                    }

                                    // Default background image cuz why not
                                    Image {
                                        anchors {
                                            horizontalCenter: parent.horizontalCenter
                                            verticalCenter: parent.verticalCenter
                                        }
                                        anchors.bottomMargin: 100
                                        source: "../Assets/Frieren.png"
                                        width: 1050
                                        height: 600
                                        opacity: 0.95
                                        z: 1

                                        visible: isOpen && !showWallpaperSelector && !showCalendar && !showAppLauncher && !showSettings
                                    }

                                    // WALLPAPER SELECTOR
                                    WallpaperSelector {
                                        id: wpSelector
                                        anchors.centerIn: parent
                                        width: 855
                                        height: 513
                                        enabled: showWallpaperSelector
                                        z: 10

                                        scale: showWallpaperSelector ? 1.0 : 0.85
                                        opacity: showWallpaperSelector ? 1.0 : 0.0

                                        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                                        Behavior on opacity { NumberAnimation { duration: 180 } }

                                        onCloseRequested: {
                                            showWallpaperSelector = false
                                            isOpen = false
                                        }
                                    }

                                    // CALENDAR
                                    Calendar {
                                        anchors.centerIn: parent
                                        width: 850
                                        height: 513
                                        enabled: showCalendar
                                        z: 10

                                        scale: showCalendar ? 1.0 : 0.85
                                        opacity: showCalendar ? 1.0 : 0.0

                                        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                                        Behavior on opacity { NumberAnimation { duration: 180 } }
                                    }

                                    // Media Player
                                    MediaPlayer {
                                        id: mediaPlayerWidget

                                        anchors {
                                            right: parent.right
                                            bottom: parent.bottom
                                            rightMargin: 17
                                            bottomMargin: 17
                                        }
                                        width: 500
                                        height: 430
                                        enabled: showMediaPlayer
                                        z: 10

                                        scale: showMediaPlayer ? 1.0 : 0.85
                                        opacity: showMediaPlayer ? 1.0 : 0.0

                                        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                                        Behavior on opacity { NumberAnimation { duration: 180 } }

                                        onCloseRequested: {
                                            showMediaPlayer = false
                                        }

                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.centerIn: parent
                                            spacing: 0

                                            AnimatedImage {
                                                id: frierenGif
                                                Layout.preferredWidth: 120
                                                Layout.preferredHeight: 120
                                                Layout.leftMargin: 300
                                                Layout.bottomMargin: 30
                                                source: "../Assets/frieren-kuru-kuru.gif"
                                            
                                            
                                                // MADE THIS COOL THINGY .
                                                // THE ORIGINAL IDEA IS FROM ZAPHKIEL SHELL .
                                                // ========( I DID NOT STEAL ANY CODE )========


                                                 property real clickCount: 0
                                                    property real currentSpeed: Math.min(1.0 + (clickCount * 0.2), 10.0)
                                                    property bool maxedOut: false
                                                        speed: currentSpeed
                                                        opacity: maxedOut ? 0 : 1
                                                        scale: maxedOut ? 0 : 1

                                                        Behavior on opacity { NumberAnimation { duration: 300 } }
                                                        Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.InBack } }

                                                        // Particles INSIDE the AnimatedImage
                                                        ParticleSystem {
                                                            anchors.fill: parent
                                                            running: parent.currentSpeed >= 6.0 && !parent.maxedOut

                                                            ImageParticle {
                                                                source: "qrc:///particleresources/glowdot.png"
                                                                color: Dat.Colors.color.primary
                                                                colorVariation: 0.6
                                                            }

                                                            Emitter {
                                                                anchors.centerIn: parent
                                                                width: parent.width
                                                                height: parent.height
                                                                emitRate: (frierenGif.currentSpeed - 6.0) * 50
                                                                lifeSpan: 1000
                                                                size: 16
                                                                sizeVariation: 8

                                                                velocity: AngleDirection {
                                                                    angleVariation: 360
                                                                    magnitude: 50
                                                                    magnitudeVariation: 30
                                                                }
                                                            }
                                                        }

                                                        MouseArea {
                                                            anchors.fill: parent
                                                            onClicked: {
                                                                if (!frierenGif.maxedOut)
                                                                {
                                                                    frierenGif.clickCount++
                                                                    decayTimer.restart()
                                                                    if (frierenGif.currentSpeed >= 10.0)
                                                                    {
                                                                        frierenGif.maxedOut = true
                                                                        resetTimer.start()
                                                                    }
                                                                }
                                                            }
                                                        }

                                                        Timer {
                                                            id: decayTimer
                                                            interval: 1000
                                                            onTriggered: { if (!frierenGif.maxedOut) decayAnimation.start() }
                                                        }

                                                        NumberAnimation {
                                                            id: decayAnimation
                                                            target: frierenGif
                                                            property: "clickCount"
                                                            to: 0
                                                            duration: 1500
                                                            easing.type: Easing.OutQuad
                                                        }

                                                        Timer {
                                                            id: resetTimer
                                                            interval: 3000
                                                            onTriggered: {
                                                                frierenGif.maxedOut = false
                                                                frierenGif.clickCount = 0
                                                            }
                                                        }
                                                    

                                                    AnimatedImage {
                                                        id: superFrieren
                                                        Layout.preferredWidth: 120
                                                        Layout.preferredHeight: 120
                                                        Layout.leftMargin: 300
                                                        Layout.bottomMargin: 0
                                                        source: "../Assets/friedance.gif"
                                                        speed: 2.0
                                                        opacity: frierenGif.maxedOut ? 1 : 0
                                                        scale: frierenGif.maxedOut ? 1 : 0
                                                        visible: opacity > 0

                                                        Behavior on opacity { NumberAnimation { duration: 500 } }
                                                        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack } }
                                                    }
                                                } 
                                            }
                                        }
                                    }

                                    // NOTIFICATION PANEL
                                    Notif {
                                        id: notificationWidget
                                        anchors {
                                            right: parent.right
                                            bottom: parent.bottom
                                            rightMargin: 17
                                            bottomMargin: 17
                                        }
                                        width: 500
                                        height: 430
                                        enabled: showNotifications
                                        z: 10

                                        scale: showNotifications ? 1.0 : 0.85
                                        opacity: showNotifications ? 1.0 : 0.0

                                        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                                        Behavior on opacity { NumberAnimation { duration: 180 } }

                                        onCloseRequested: {
                                            showNotifications = false
                                            isOpen = false
                                        }
                                    }

                                    // SETTINGS PANEL
                                    Settings {
                                        id: settingsWidget
                                        anchors.centerIn: parent
                                        width: 850
                                        height: 513
                                        enabled: showSettings
                                        z: 10

                                        scale: showSettings ? 1.0 : 0.85
                                        opacity: showSettings ? 1.0 : 0.0

                                        Behavior on scale { NumberAnimation { duration: 220; easing.type: Easing.OutBack } }
                                        Behavior on opacity { NumberAnimation { duration: 180 } }
                                    }

                                    // App Launcher Yo
                                    AppLauncher_Embedded {
                                        id: appLauncherWidget
                                        anchors.centerIn: parent
                                        width: 850
                                        height: 513
                                        enabled: showAppLauncher
                                        z: 10

                                        scale: showAppLauncher ? 1.0 : 0.85
                                        opacity: showAppLauncher ? 1.0 : 0.0

                                        Behavior on scale { 
                                            NumberAnimation {
                                            duration: 220
                                            easing.type: Easing.OutBack
                                            }
                                        }

                                        Behavior on opacity {
                                            NumberAnimation {
                                                duration: 180
                                            }
                                        }
                                    }
}