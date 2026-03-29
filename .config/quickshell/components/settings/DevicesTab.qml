import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Io
import "../generics"
import "../../core" as Dat

Item {
    id: root
    anchors.fill: parent

    // ── STATE ─────────────────────────────────────────────────────────────────
    property string touchpadName: ""
    property string mouseName:    ""
    property bool   btScanning:   false

    // Volume slider guard — prevents a polled value from snapping the slider
    // while the user is dragging
    property bool userAdjustingVolume:  false
    property bool userAdjustingMicVol:  false

    Component.onCompleted: {
        devicesProcess.running   = true
        sinkProcess.running      = true
        sourceProcess.running    = true
        volumeReadProcess.running = true
        micVolReadProcess.running = true
        btListProcess.running    = true
        monitorProcess.running   = true
        usbProcess.running       = true
    }

    // ══════════════════════════════════════════════════════════════════════════
    // PROCESSES
    // ══════════════════════════════════════════════════════════════════════════

    // ── INPUT DEVICES (hyprctl) ───────────────────────────────────────────────
    Process {
        id: devicesProcess
        command: ["hyprctl", "devices", "-j"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => devicesProcess.buf += data + "\n" }
        onExited: {
            try {
                const data = JSON.parse(buf)
                if (data.mice) {
                    root.touchpadName = ""
                    root.mouseName    = ""
                    for (var i = 0; i < data.mice.length; i++) {
                        const n = data.mice[i].name.toLowerCase()
                        if (n.indexOf("touchpad") !== -1)
                            root.touchpadName = data.mice[i].name
                        else if (n.indexOf("mouse") !== -1 || n.indexOf("pointer") !== -1)
                            root.mouseName = data.mice[i].name
                    }
                    // Fallback: first mouse-like device
                    if (!root.mouseName && data.mice.length > 0)
                        root.mouseName = data.mice[0].name
                }
            } catch(e) { console.warn("hyprctl devices parse:", e) }
            buf = ""
        }
    }

    // ── AUDIO: READ ───────────────────────────────────────────────────────────
    Process {
        id: sinkProcess
        command: ["pactl", "--format=json", "list", "sinks"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => sinkProcess.buf += data + "\n" }
        onExited: {
            try {
                const sinks = JSON.parse(buf)
                sinkModel.clear()
                sinks.forEach(s => sinkModel.append({ name: s.name, description: s.description || s.name }))
                defaultSinkProcess.running = true
            } catch(e) { console.warn("pactl sinks:", e) }
            buf = ""
        }
    }

    Process {
        id: defaultSinkProcess
        command: ["pactl", "get-default-sink"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => defaultSinkProcess.buf += data + "\n" }
        onExited: {
            const def = buf.trim()
            for (var i = 0; i < sinkModel.count; i++) {
                if (sinkModel.get(i).name === def) { outputCombo.currentIndex = i; break }
            }
            buf = ""
        }
    }

    Process {
        id: sourceProcess
        command: ["pactl", "--format=json", "list", "sources"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => sourceProcess.buf += data + "\n" }
        onExited: {
            try {
                const sources = JSON.parse(buf)
                sourceModel.clear()
                sources.forEach(s => {
                    // Skip monitor sources (loopbacks of sinks)
                    if (s.name.indexOf(".monitor") === -1)
                        sourceModel.append({ name: s.name, description: s.description || s.name })
                })
                defaultSourceProcess.running = true
            } catch(e) { console.warn("pactl sources:", e) }
            buf = ""
        }
    }

    Process {
        id: defaultSourceProcess
        command: ["pactl", "get-default-source"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => defaultSourceProcess.buf += data + "\n" }
        onExited: {
            const def = buf.trim()
            for (var i = 0; i < sourceModel.count; i++) {
                if (sourceModel.get(i).name === def) { inputCombo.currentIndex = i; break }
            }
            buf = ""
        }
    }

    Process {
        id: volumeReadProcess
        command: ["bash", "-c",
            "pactl get-sink-volume @DEFAULT_SINK@ | grep -oP '\\d+%' | head -1 | tr -d '%'"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => volumeReadProcess.buf += data + "\n" }
        onExited: {
            const v = parseInt(buf.trim())
            if (!isNaN(v) && !root.userAdjustingVolume) volumeSlider.value = v
            buf = ""
        }
    }

    Process {
        id: micVolReadProcess
        command: ["bash", "-c",
            "pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\\d+%' | head -1 | tr -d '%'"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => micVolReadProcess.buf += data + "\n" }
        onExited: {
            const v = parseInt(buf.trim())
            if (!isNaN(v) && !root.userAdjustingMicVol) micVolumeSlider.value = v
            buf = ""
        }
    }

    // ── AUDIO: WRITE (fire-and-forget, no stdout needed) ─────────────────────
    Process { id: paSetSinkProcess;   running: false }
    Process { id: paSetSourceProcess; running: false }
    Process { id: paSetVolProcess;    running: false }
    Process { id: paSetMicVolProcess; running: false }
    Process { id: paPlayProcess;      running: false }

    // ── HYPRCTL INPUT WRITES ──────────────────────────────────────────────────
    // Each control gets its own Process so rapid slider moves never drop
    // commands by hitting a still-running instance.
    Process { id: hyprSensProcess;         running: false }
    Process { id: hyprScrollProcess;       running: false }
    Process { id: hyprTouchpadProcess;     running: false }
    Process { id: hyprNaturalScrollProcess;running: false }
    Process { id: hyprRepeatRateProcess;   running: false }
    Process { id: hyprRepeatDelayProcess;  running: false }

    // Hyprland device keyword names are lowercased with spaces → hyphens.
    // e.g. "SYNA3602:00 06CB:CE44 Touchpad" → "syna3602:00-06cb:ce44-touchpad"
    function toHyprName(name) {
        return name.toLowerCase().replace(/ /g, "-")
    }

    // ── BLUETOOTH ────────────────────────────────────────────────────────────
    // Lists all known devices and their connected/paired state in one bash pass
    Process {
        id: btListProcess
        command: ["bash", "-c",
            "bluetoothctl devices 2>/dev/null | while IFS= read -r line; do " +
            "  mac=$(echo \"$line\" | awk '{print $2}'); " +
            "  name=$(echo \"$line\" | cut -d' ' -f3-); " +
            "  [ -z \"$mac\" ] && continue; " +
            "  info=$(bluetoothctl info \"$mac\" 2>/dev/null); " +
            "  conn=$(echo \"$info\" | grep 'Connected:' | awk '{print $2}'); " +
            "  paired=$(echo \"$info\" | grep 'Paired:' | awk '{print $2}'); " +
            "  echo \"$mac|$name|${conn:-no}|${paired:-no}\"; " +
            "done"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => btListProcess.buf += data + "\n" }
        onExited: {
            btModel.clear()
            const lines = buf.split('\n')
            for (var i = 0; i < lines.length; i++) {
                const cols = lines[i].trim().split('|')
                if (cols.length < 4 || !cols[0]) continue
                btModel.append({
                    mac:       cols[0],
                    name:      cols[1] || cols[0],
                    connected: cols[2] === "yes",
                    paired:    cols[3] === "yes"
                })
            }
            root.btScanning = false
            buf = ""
        }
    }

    // Runs `bluetoothctl scan on` for 6 seconds via timeout, then refreshes list
    Process {
        id: btScanProcess
        command: ["timeout", "6", "bluetoothctl", "scan", "on"]
        running: false
        onExited: { btListProcess.running = true }
    }

    // Connect or disconnect — command set before running
    Process { id: btActionProcess; running: false }

    // ── MONITORS ─────────────────────────────────────────────────────────────
    Process {
        id: monitorProcess
        command: ["hyprctl", "monitors", "-j"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => monitorProcess.buf += data + "\n" }
        onExited: {
            try {
                const mons = JSON.parse(buf)
                monitorModel.clear()
                mons.forEach(m => {
                    monitorModel.append({
                        name:        m.name        || "unknown",
                        description: m.description || "",
                        width:       m.width        || 0,
                        height:      m.height       || 0,
                        refreshRate: m.refreshRate  || 0,
                        scale:       m.scale        || 1,
                        x:           m.x            || 0,
                        y:           m.y            || 0,
                        focused:     m.focused      || false,
                        dpms:        m.dpmsStatus   !== false
                    })
                })
            } catch(e) { console.warn("hyprctl monitors:", e) }
            buf = ""
        }
    }

    // ── USB ───────────────────────────────────────────────────────────────────
    // lsusb line: Bus 001 Device 002: ID 1234:5678 Device Description
    Process {
        id: usbProcess
        command: ["lsusb"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => usbProcess.buf += data + "\n" }
        onExited: {
            usbModel.clear()
            const lines = buf.split('\n')
            for (var i = 0; i < lines.length; i++) {
                const line = lines[i].trim()
                if (!line) continue
                // "Bus 001 Device 002: ID 1a2b:3c4d Description here"
                const m = line.match(/Bus (\d+) Device (\d+): ID ([0-9a-f:]+) (.*)/)
                if (m) usbModel.append({ bus: m[1], device: m[2], id: m[3], description: m[4] })
            }
            buf = ""
        }
    }

    // ── MODELS ────────────────────────────────────────────────────────────────
    ListModel { id: sinkModel    }
    ListModel { id: sourceModel  }
    ListModel { id: btModel      }
    ListModel { id: monitorModel }
    ListModel { id: usbModel     }

    // ══════════════════════════════════════════════════════════════════════════
    // UI
    // ══════════════════════════════════════════════════════════════════════════
    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 20

            // ── AUDIO ─────────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "Audio"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2 }
                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                // Output device
                SettingRow {
                    label: "Output"
                    ComboBox {
                        id: outputCombo
                        Layout.fillWidth: true
                        model: sinkModel
                        textRole: "description"
                        background: Rectangle { color: Dat.Colors.color.surface; radius: 6; border.color: Dat.Colors.color.primary; border.width: 1 }
                        contentItem: Text { text: parent.displayText; color: Dat.Colors.color.on_surface; leftPadding: 10; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                        onActivated: function(idx) {
                            paSetSinkProcess.command = ["pactl", "set-default-sink", sinkModel.get(idx).name]
                            paSetSinkProcess.running = true
                        }
                    }
                }

                // Volume
                SettingRow {
                    label: "Volume"
                    StyledSlider {
                        id: volumeSlider
                        Layout.fillWidth: true
                        from: 0; to: 150; stepSize: 1
                        onPressedChanged: root.userAdjustingVolume = pressed
                        onMoved: {
                            paSetVolProcess.command = ["pactl", "set-sink-volume", "@DEFAULT_SINK@", Math.round(value) + "%"]
                            paSetVolProcess.running = true
                        }
                    }
                    Text { text: Math.round(volumeSlider.value) + "%"; color: Dat.Colors.color.on_surface; font.pixelSize: 12; Layout.preferredWidth: 40 }
                }

                // Mic input device
                SettingRow {
                    label: "Microphone"
                    ComboBox {
                        id: inputCombo
                        Layout.fillWidth: true
                        model: sourceModel
                        textRole: "description"
                        background: Rectangle { color: Dat.Colors.color.surface; radius: 6; border.color: Dat.Colors.color.primary; border.width: 1 }
                        contentItem: Text { text: parent.displayText; color: Dat.Colors.color.on_surface; leftPadding: 10; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight }
                        onActivated: function(idx) {
                            paSetSourceProcess.command = ["pactl", "set-default-source", sourceModel.get(idx).name]
                            paSetSourceProcess.running = true
                        }
                    }
                }

                // Mic volume
                SettingRow {
                    label: "Mic Volume"
                    StyledSlider {
                        id: micVolumeSlider
                        Layout.fillWidth: true
                        from: 0; to: 150; stepSize: 1
                        onPressedChanged: root.userAdjustingMicVol = pressed
                        onMoved: {
                            paSetMicVolProcess.command = ["pactl", "set-source-volume", "@DEFAULT_SOURCE@", Math.round(value) + "%"]
                            paSetMicVolProcess.running = true
                        }
                    }
                    Text { text: Math.round(micVolumeSlider.value) + "%"; color: Dat.Colors.color.on_surface; font.pixelSize: 12; Layout.preferredWidth: 40 }
                }

                // Test sound
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4

                    Rectangle {
                        width: 110; height: 30; radius: 6
                        color: testMouse.containsMouse ? Dat.Colors.color.primary : "transparent"
                        border.color: Dat.Colors.color.primary; border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text {
                            anchors.centerIn: parent; text: "Test Sound"; font.pixelSize: 11
                            color: testMouse.containsMouse ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                        }
                        MouseArea {
                            id: testMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: { paPlayProcess.command = ["paplay", "/usr/share/sounds/freedesktop/stereo/bell.oga"]; paPlayProcess.running = true }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }
            }

            // ── INPUT DEVICES ─────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "Input Devices"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2 }
                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                // Mouse sensitivity
                SettingRow {
                    label: "Mouse Sensitivity"
                    StyledSlider {
                        id: mouseSensSlider
                        Layout.fillWidth: true
                        from: -1.0; to: 1.0; stepSize: 0.05
                        value: 0.0
                        onMoved: {
                            if (!root.mouseName) return
                            hyprSensProcess.command = ["hyprctl", "keyword",
                                "device:" + root.toHyprName(root.mouseName) + ":sensitivity",
                                value.toFixed(2)]
                            hyprSensProcess.running = true
                        }
                    }
                    Text { text: mouseSensSlider.value.toFixed(2); color: Dat.Colors.color.on_surface; font.pixelSize: 12; Layout.preferredWidth: 44 }
                }

                // Scroll factor
                SettingRow {
                    label: "Scroll Factor"
                    StyledSlider {
                        id: scrollSlider
                        Layout.fillWidth: true
                        from: 0.5; to: 5.0; stepSize: 0.5; value: 1.0
                        onMoved: {
                            if (!root.mouseName) return
                            hyprScrollProcess.command = ["hyprctl", "keyword",
                                "device:" + root.toHyprName(root.mouseName) + ":scroll_factor",
                                value.toFixed(1)]
                            hyprScrollProcess.running = true
                        }
                    }
                    Text { text: scrollSlider.value.toFixed(1) + "x"; color: Dat.Colors.color.on_surface; font.pixelSize: 12; Layout.preferredWidth: 44 }
                }

                // Touchpad toggle
                SettingRow {
                    label: "Touchpad"
                    visible: root.touchpadName !== ""
                    StyledSwitch {
                        id: touchpadSwitch
                        checked: true
                        onCheckedChanged: {
                            if (!root.touchpadName) return
                            hyprTouchpadProcess.command = ["hyprctl", "keyword",
                                "device:" + root.toHyprName(root.touchpadName) + ":enabled",
                                checked ? "true" : "false"]
                            hyprTouchpadProcess.running = true
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                // Natural scroll
                SettingRow {
                    label: "Natural Scroll"
                    visible: root.touchpadName !== ""
                    StyledSwitch {
                        id: naturalScrollSwitch
                        checked: false
                        onCheckedChanged: {
                            const val = checked ? "true" : "false"
                            // Apply to touchpad and mouse separately via one process each
                            if (root.touchpadName) {
                                hyprNaturalScrollProcess.command = ["hyprctl", "keyword",
                                    "device:" + root.toHyprName(root.touchpadName) + ":natural_scroll", val]
                                hyprNaturalScrollProcess.running = true
                            }
                            if (root.mouseName) {
                                hyprScrollProcess.command = ["hyprctl", "keyword",
                                    "device:" + root.toHyprName(root.mouseName) + ":natural_scroll", val]
                                hyprScrollProcess.running = true
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }
                }

                // Key repeat rate
                SettingRow {
                    label: "Key Repeat Rate"
                    StyledSlider {
                        id: repeatSlider
                        Layout.fillWidth: true
                        from: 20; to: 80; stepSize: 5; value: 40
                        onMoved: {
                            hyprRepeatRateProcess.command = ["hyprctl", "keyword",
                                "input:repeat_rate", Math.round(value).toString()]
                            hyprRepeatRateProcess.running = true
                        }
                    }
                    Text { text: Math.round(repeatSlider.value) + " /s"; color: Dat.Colors.color.on_surface; font.pixelSize: 12; Layout.preferredWidth: 44 }
                }

                // Key repeat delay
                SettingRow {
                    label: "Repeat Delay"
                    StyledSlider {
                        id: repeatDelaySlider
                        Layout.fillWidth: true
                        from: 150; to: 800; stepSize: 50; value: 300
                        onMoved: {
                            hyprRepeatDelayProcess.command = ["hyprctl", "keyword",
                                "input:repeat_delay", Math.round(value).toString()]
                            hyprRepeatDelayProcess.running = true
                        }
                    }
                    Text { text: Math.round(repeatDelaySlider.value) + " ms"; color: Dat.Colors.color.on_surface; font.pixelSize: 12; Layout.preferredWidth: 44 }
                }
            }

            // ── BLUETOOTH ─────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true

                    Text { text: "Bluetooth"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2; Layout.fillWidth: true }

                    // Scan button
                    Rectangle {
                        width: 80; height: 26; radius: 5
                        color: root.btScanning ? Dat.Colors.color.primary
                             : scanMouse.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        border.color: Dat.Colors.color.primary; border.width: 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: root.btScanning ? "Scanning…" : "Scan"
                            font.pixelSize: 11
                            color: root.btScanning ? Dat.Colors.color.on_primary : Dat.Colors.color.on_surface
                        }
                        MouseArea {
                            id: scanMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            enabled: !root.btScanning
                            onClicked: { root.btScanning = true; btScanProcess.running = true }
                        }
                    }

                    Rectangle {
                        width: 80; height: 26; radius: 5
                        color: refreshBtMouse.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        border.color: Dat.Colors.color.on_surface; border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "Refresh"; font.pixelSize: 11; color: Dat.Colors.color.on_surface }
                        MouseArea {
                            id: refreshBtMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: btListProcess.running = true
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                // Header
                RowLayout {
                    Layout.fillWidth: true; Layout.rightMargin: 4; Layout.leftMargin: 4
                    Text { text: "Device";    font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }
                    Text { text: "Status";    font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignHCenter }
                    Text { text: "Action";    font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignRight }
                }

                Repeater {
                    model: btModel
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 38
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.03)
                        radius: 3

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4; spacing: 8

                            ColumnLayout {
                                Layout.fillWidth: true; spacing: 1
                                Text { text: model.name; font.pixelSize: 12; color: Dat.Colors.color.on_surface; elide: Text.ElideRight; Layout.fillWidth: true }
                                Text { text: model.mac;  font.pixelSize: 9;  color: Dat.Colors.color.on_surface; opacity: 0.4; font.family: "monospace" }
                            }

                            Rectangle {
                                width: 70; height: 18; radius: 9
                                color: model.connected ? Qt.rgba(0.13, 0.77, 0.33, 0.18) : Qt.rgba(1,1,1,0.07)
                                Text {
                                    anchors.centerIn: parent
                                    text: model.connected ? "Connected" : model.paired ? "Paired" : "Known"
                                    font.pixelSize: 9
                                    color: model.connected ? "#22c55e" : Dat.Colors.color.on_surface
                                    opacity: model.connected ? 1.0 : 0.5
                                }
                            }

                            Rectangle {
                                width: 86; height: 26; radius: 5
                                color: model.connected ? Qt.rgba(0.94, 0.27, 0.27, 0.15) : Qt.rgba(0.13, 0.77, 0.33, 0.15)
                                border.color: model.connected ? "#ef4444" : "#22c55e"; border.width: 1
                                Text {
                                    anchors.centerIn: parent
                                    text: model.connected ? "Disconnect" : "Connect"
                                    font.pixelSize: 11
                                    color: model.connected ? "#ef4444" : "#22c55e"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        btActionProcess.command = model.connected
                                            ? ["bluetoothctl", "disconnect", model.mac]
                                            : ["bluetoothctl", "connect",    model.mac]
                                        btActionProcess.running = true
                                        btRefreshTimer.start()
                                    }
                                }
                            }
                        }
                    }
                }

                Text {
                    visible: btModel.count === 0 && !root.btScanning
                    text: "No paired devices found. Press Scan to discover nearby devices."
                    font.pixelSize: 12; color: Dat.Colors.color.on_surface; opacity: 0.45
                    wrapMode: Text.WordWrap; Layout.fillWidth: true; leftPadding: 4
                }

                Timer { id: btRefreshTimer; interval: 1500; repeat: false; onTriggered: btListProcess.running = true }
            }

            // ── DISPLAYS ──────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "Displays"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2; Layout.fillWidth: true }
                    Rectangle {
                        width: 80; height: 26; radius: 5
                        color: monRefreshMouse.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        border.color: Dat.Colors.color.on_surface; border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "Refresh"; font.pixelSize: 11; color: Dat.Colors.color.on_surface }
                        MouseArea {
                            id: monRefreshMouse
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: monitorProcess.running = true
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                Repeater {
                    model: monitorModel
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: monitorContent.implicitHeight + 20
                        radius: 6
                        color: Qt.rgba(1,1,1, model.focused ? 0.06 : 0.03)
                        border.color: Dat.Colors.color.primary
                        border.width: model.focused ? 1 : 0

                        ColumnLayout {
                            id: monitorContent
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: model.name
                                    font.bold: true; font.pixelSize: 13; font.family: "monospace"
                                    color: Dat.Colors.color.on_surface
                                }
                                Rectangle {
                                    visible: model.focused
                                    width: 52; height: 18; radius: 9
                                    color: Qt.rgba(0.13, 0.77, 0.33, 0.18)
                                    Text { anchors.centerIn: parent; text: "focused"; font.pixelSize: 9; color: "#22c55e" }
                                }
                                Rectangle {
                                    visible: !model.dpms
                                    width: 52; height: 18; radius: 9
                                    color: Qt.rgba(0.94, 0.27, 0.27, 0.15)
                                    Text { anchors.centerIn: parent; text: "DPMS off"; font.pixelSize: 9; color: "#ef4444" }
                                }
                                Item { Layout.fillWidth: true }
                                Text {
                                    text: model.description
                                    font.pixelSize: 10; color: Dat.Colors.color.on_surface; opacity: 0.45
                                    elide: Text.ElideRight; Layout.maximumWidth: 220
                                }
                            }

                            GridLayout {
                                columns: 4; columnSpacing: 24; rowSpacing: 4

                                InfoChip { label: "Resolution"; value: model.width + "×" + model.height }
                                InfoChip { label: "Refresh";    value: model.refreshRate.toFixed(2) + " Hz" }
                                InfoChip { label: "Scale";      value: model.scale + "×" }
                                InfoChip { label: "Position";   value: model.x + ", " + model.y }
                            }
                        }
                    }
                }
            }

            // ── USB DEVICES ───────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text { text: "USB Devices"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2; Layout.fillWidth: true }
                    Rectangle {
                        width: 80; height: 26; radius: 5
                        color: usbRefreshMouse.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                        border.color: Dat.Colors.color.on_surface; border.width: 1
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Text { anchors.centerIn: parent; text: "Refresh"; font.pixelSize: 11; color: Dat.Colors.color.on_surface }
                        MouseArea {
                            id: usbRefreshMouse
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: usbProcess.running = true
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                RowLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 4; Layout.rightMargin: 4
                    Text { text: "Description"; font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }
                    Text { text: "ID";          font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 85; horizontalAlignment: Text.AlignRight }
                    Text { text: "Bus·Dev";     font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 65; horizontalAlignment: Text.AlignRight }
                }

                Repeater {
                    model: usbModel
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 30
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.03); radius: 3
                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4
                            Text { text: model.description; font.pixelSize: 12; color: Dat.Colors.color.on_surface; elide: Text.ElideRight; Layout.fillWidth: true }
                            Text { text: model.id;          font.pixelSize: 11; font.family: "monospace"; color: Dat.Colors.color.on_surface; opacity: 0.6; Layout.preferredWidth: 85; horizontalAlignment: Text.AlignRight }
                            Text { text: model.bus + "·" + model.device; font.pixelSize: 11; font.family: "monospace"; color: Dat.Colors.color.on_surface; opacity: 0.4; Layout.preferredWidth: 65; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }

            Item { height: 16 }
        }
    }

    // ── INLINE COMPONENTS ─────────────────────────────────────────────────────
    // SettingRow: label + arbitrary content in a consistent row layout
    component SettingRow: RowLayout {
        property string label: ""
        Layout.fillWidth: true
        Layout.leftMargin: 4; Layout.rightMargin: 4; spacing: 10

        Text {
            text: parent.label
            color: Dat.Colors.color.on_surface
            font.pixelSize: 12
            Layout.preferredWidth: 130
        }
    }

    // StyledSwitch: themed toggle to avoid repeating indicator boilerplate
    component StyledSwitch: Switch {
        id: sw
        indicator: Rectangle {
            implicitWidth: 44; implicitHeight: 22
            x: sw.leftPadding
            y: parent.height / 2 - height / 2
            radius: 11
            color: sw.checked ? Dat.Colors.color.primary : Dat.Colors.color.surface
            border.color: Dat.Colors.color.primary; border.width: 1
            Behavior on color { ColorAnimation { duration: 150 } }
            Rectangle {
                x: sw.checked ? parent.width - width - 2 : 2; y: 2
                width: 18; height: 18; radius: 9
                color: Dat.Colors.color.on_primary
                Behavior on x { NumberAnimation { duration: 150 } }
            }
        }
    }

    // InfoChip: label + value pair used in monitor cards
    component InfoChip: ColumnLayout {
        property string label: ""
        property string value: ""
        spacing: 1
        Text { text: parent.label; font.pixelSize: 9;  color: Dat.Colors.color.on_surface; opacity: 0.45 }
        Text { text: parent.value; font.pixelSize: 12; color: Dat.Colors.color.on_surface; font.family: "monospace" }
    }
}
