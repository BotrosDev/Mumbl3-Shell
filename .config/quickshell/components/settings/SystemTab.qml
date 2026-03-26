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
    property var    prevCpuStats:  ({})
    property var    prevCoreStats: ([])
    property var    prevNetStats:  ({})      // { iface: { rx, tx } }

    // GPU
    property string gpuType:          "none" // "nvidia" | "amd" | "intel" | "none"
    property string gpuLabel:         "GPU"
    property bool   hasIgpu:          false
    property bool   igpuFreqFallback: false

    // Temps
    property real   cpuTemp:    0
    property real   gpuTemp:    0
    property bool   hasCpuTemp: false
    property bool   hasGpuTemp: false

    // Battery
    property bool   hasBattery:    false
    property real   batteryLevel:  0
    property string batteryStatus: ""

    // Swap
    property real   swapUsed:  0
    property real   swapTotal: 0

    // Updates  (-1 = not yet checked)
    property int    pendingUpdates: -1
    property bool   isCPU_Open:     true
    property bool   isGPU_Open:     true
    property bool   isRAM_Open:     true
    property bool   isSwap_Open:    true
    property bool   isBattery_Open: true

    Component.onCompleted: {
        fastTimer.start()
        slowTimer.start()

        // First-tick fast metrics
        cpuProcess.running      = true
        cpuCoreProcess.running  = true
        ramProcess.running      = true
        gpuEnumProcess.running  = true   // defers GPU usage/temp polls until type is known
        netProcess.running      = true
        tempProcess.running     = true
        batteryProcess.running  = true
        topProcess.running      = true

        // Slow one-shots
        kernelProcess.running  = true
        diskProcess.running    = true
        updatesProcess.running = true
    }

    // ── TIMERS ───────────────────────────────────────────────────────────────
    Timer {
        id: fastTimer
        interval: 2000
        repeat: true
        running: false
        onTriggered: {
            cpuProcess.running     = true
            cpuCoreProcess.running = true
            ramProcess.running     = true
            netProcess.running     = true
            tempProcess.running    = true
            batteryProcess.running = true
            kernelProcess.running  = true
            topProcess.running     = true

            const gpuBusy = nvidiaProcess.running || amdProcess.running ||
                            intelProcess.running  || igpuFreqProcess.running
            if (!gpuBusy) triggerGpuPoll()

            const gpuTempBusy = nvidiaTempProcess.running || amdTempProcess.running
            if (!gpuTempBusy) triggerGpuTempPoll()
        }
    }

    Timer {
        id: slowTimer
        interval: 300000   // 5 minutes
        repeat: true
        running: false
        onTriggered: {
            updatesProcess.running = true
            diskProcess.running    = true
        }
    }

    // ── GPU: ENUMERATE ────────────────────────────────────────────────────────
    Process {
        id: gpuEnumProcess
        command: ["bash", "-c",
            "for f in /sys/class/drm/card*/device/vendor; do cat \"$f\" 2>/dev/null; done"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => gpuEnumProcess.buf += data + "\n" }
        onExited: {
            const raw       = buf.toLowerCase()
            const hasNvidia = raw.indexOf("0x10de") !== -1
            const hasAmd    = raw.indexOf("0x1002") !== -1
            const hasIntel  = raw.indexOf("0x8086") !== -1
            if (hasNvidia) {
                root.gpuType  = "nvidia"
                root.gpuLabel = hasIntel ? "dGPU · NVIDIA" : "GPU · NVIDIA"
                root.hasIgpu  = hasIntel
            } else if (hasAmd) {
                root.gpuType  = "amd"
                root.gpuLabel = hasIntel ? "dGPU · AMD" : "GPU · AMD"
                root.hasIgpu  = hasIntel
            } else if (hasIntel) {
                root.gpuType  = "intel"
                root.gpuLabel = "iGPU · Intel"
                root.hasIgpu  = true
            } else {
                root.gpuType  = "none"
                gpuGauge.text = "N/A"
            }
            buf = ""
            triggerGpuPoll()
            triggerGpuTempPoll()
        }
    }

    function triggerGpuPoll() {
        if      (root.gpuType === "nvidia") nvidiaProcess.running   = true
        else if (root.gpuType === "amd")    amdProcess.running      = true
        else if (root.gpuType === "intel") {
            if (root.igpuFreqFallback) igpuFreqProcess.running = true
            else                       intelProcess.running    = true
        }
    }

    function triggerGpuTempPoll() {
        if      (root.gpuType === "nvidia") nvidiaTempProcess.running = true
        else if (root.gpuType === "amd")    amdTempProcess.running    = true
        // Intel iGPU temp comes from the general tempProcess hwmon scan
    }

    // ── GPU: NVIDIA USAGE ─────────────────────────────────────────────────────
    Process {
        id: nvidiaProcess
        command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => nvidiaProcess.buf += data + "\n" }
        onExited: (code) => {
            if (code === 0) {
                const pct = parseInt(buf.trim())
                if (!isNaN(pct)) { gpuGauge.value = pct / 100; gpuGauge.text = pct + "%" }
            }
            buf = ""
        }
    }

    // ── GPU: AMD USAGE (sysfs → rocm-smi fallback) ────────────────────────────
    Process {
        id: amdProcess
        command: ["bash", "-c",
            "for f in /sys/class/drm/card*/device/gpu_busy_percent; do " +
            "  v=$(cat \"$f\" 2>/dev/null); [ -n \"$v\" ] && echo \"$v\" && exit 0; " +
            "done; echo ''"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => amdProcess.buf += data + "\n" }
        onExited: {
            const val = parseInt(buf.trim())
            if (!isNaN(val) && val >= 0 && val <= 100) {
                gpuGauge.value = val / 100; gpuGauge.text = val + "%"
            } else {
                amdRocmProcess.running = true
            }
            buf = ""
        }
    }

    Process {
        id: amdRocmProcess
        command: ["rocm-smi", "--showuse"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => amdRocmProcess.buf += data + "\n" }
        onExited: (code) => {
            if (code === 0) {
                const lines = buf.split('\n')
                for (var i = 0; i < lines.length; i++) {
                    const cols = lines[i].trim().split(/\s+/)
                    const pct  = parseInt(cols[cols.length - 1])
                    if (!isNaN(pct) && pct >= 0 && pct <= 100) {
                        gpuGauge.value = pct / 100; gpuGauge.text = pct + "%"; break
                    }
                }
            } else { gpuGauge.text = "N/A" }
            buf = ""
        }
    }

    // ── GPU: INTEL USAGE ──────────────────────────────────────────────────────
    Process {
        id: intelProcess
        command: ["intel_gpu_top", "-J", "-s", "500"]
        running: false
        property string buf: ""
        property bool   captured: false
        stdout: SplitParser {
            onRead: data => {
                if (!intelProcess.captured && data.trim().startsWith("{")) {
                    intelProcess.buf = data.trim()
                    intelProcess.captured = true
                    intelProcess.running  = false
                }
            }
        }
        onExited: (code) => {
            if (buf !== "") {
                try {
                    const engines = JSON.parse(buf).engines || {}
                    const key = Object.keys(engines).find(k => k.startsWith("Render"))
                    if (key) {
                        const busy = parseFloat(engines[key].busy)
                        if (!isNaN(busy)) { gpuGauge.value = busy / 100; gpuGauge.text = Math.round(busy) + "%" }
                    }
                } catch(e) { root.igpuFreqFallback = true; igpuFreqProcess.running = true }
            } else if (code !== 0) { root.igpuFreqFallback = true; igpuFreqProcess.running = true }
            buf = ""; captured = false
        }
    }

    Process {
        id: igpuFreqProcess
        command: ["bash", "-c",
            "cur=$(cat /sys/class/drm/card0/gt_cur_freq_mhz 2>/dev/null || echo 0);" +
            "max=$(cat /sys/class/drm/card0/gt_max_freq_mhz 2>/dev/null || echo 1);" +
            "echo $cur $max"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => igpuFreqProcess.buf += data }
        onExited: {
            const p = buf.trim().split(/\s+/)
            const cur = parseInt(p[0]) || 0; const max = parseInt(p[1]) || 1
            gpuGauge.value = Math.min(cur / max, 1.0); gpuGauge.text = cur + " MHz"
            gpuGaugeNote.text = "freq · install intel-gpu-tools"; buf = ""
        }
    }

    // ── GPU TEMPS ─────────────────────────────────────────────────────────────
    Process {
        id: nvidiaTempProcess
        command: ["nvidia-smi", "--query-gpu=temperature.gpu", "--format=csv,noheader,nounits"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => nvidiaTempProcess.buf += data + "\n" }
        onExited: (code) => {
            if (code === 0) {
                const t = parseInt(buf.trim())
                if (!isNaN(t)) { root.gpuTemp = t; root.hasGpuTemp = true }
            }
            buf = ""
        }
    }

    Process {
        id: amdTempProcess
        command: ["bash", "-c",
            "for d in /sys/class/hwmon/hwmon*; do " +
            "  n=$(cat \"$d/name\" 2>/dev/null); " +
            "  if [ \"$n\" = \"amdgpu\" ]; then " +
            "    t=$(cat \"$d/temp1_input\" 2>/dev/null); echo $((t/1000)); exit 0; " +
            "  fi; done; echo ''"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => amdTempProcess.buf += data + "\n" }
        onExited: {
            const t = parseInt(buf.trim())
            if (!isNaN(t) && t > 0) { root.gpuTemp = t; root.hasGpuTemp = true }
            buf = ""
        }
    }

    // ── CPU TEMP (hwmon: k10temp for AMD, coretemp for Intel) ─────────────────
    Process {
        id: tempProcess
        command: ["bash", "-c",
            "for d in /sys/class/hwmon/hwmon*; do " +
            "  n=$(cat \"$d/name\" 2>/dev/null); " +
            "  if [ \"$n\" = \"k10temp\" ] || [ \"$n\" = \"coretemp\" ]; then " +
            "    t=$(cat \"$d/temp1_input\" 2>/dev/null); " +
            "    [ -n \"$t\" ] && echo $((t/1000)) && exit 0; " +
            "  fi; done; echo ''"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => tempProcess.buf += data + "\n" }
        onExited: {
            const t = parseInt(buf.trim())
            if (!isNaN(t) && t > 0) { root.cpuTemp = t; root.hasCpuTemp = true }
            buf = ""
        }
    }

    // ── RAM + SWAP ────────────────────────────────────────────────────────────
    Process {
        id: ramProcess
        command: ["cat", "/proc/meminfo"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => ramProcess.buf += data + "\n" }
        onExited: {
            const lines = buf.split('\n')
            let memTotal = 0, memFree = 0, buffers = 0, cached = 0, sReclaimable = 0
            let swapTotal = 0, swapFree = 0
            for (var i = 0; i < lines.length; i++) {
                const p = lines[i].split(/\s+/)
                if      (p[0] === "MemTotal:")     memTotal     = parseInt(p[1])
                else if (p[0] === "MemFree:")      memFree      = parseInt(p[1])
                else if (p[0] === "Buffers:")      buffers      = parseInt(p[1])
                else if (p[0] === "Cached:")       cached       = parseInt(p[1])
                else if (p[0] === "SReclaimable:") sReclaimable = parseInt(p[1])
                else if (p[0] === "SwapTotal:")    swapTotal    = parseInt(p[1])
                else if (p[0] === "SwapFree:")     swapFree     = parseInt(p[1])
            }
            const used  = memTotal - memFree - buffers - cached - sReclaimable
            const ratio = used / memTotal
            ramGauge.value = ratio
            ramGauge.text  = Math.round(ratio * 100) + "%"
            root.swapTotal = swapTotal
            root.swapUsed  = swapTotal - swapFree
            if (swapTotal > 0) {
                swapGauge.value = root.swapUsed / swapTotal
                swapGauge.text  = Math.round((root.swapUsed / swapTotal) * 100) + "%"
            }
            buf = ""
        }
    }

    // ── CPU TOTAL ─────────────────────────────────────────────────────────────
    Process {
        id: cpuProcess
        command: ["cat", "/proc/stat"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => cpuProcess.buf += data + "\n" }
        onExited: {
            const p = buf.split('\n')[0].split(/\s+/)
            const user=parseInt(p[1]), nice=parseInt(p[2]), system=parseInt(p[3])
            const idle=parseInt(p[4]), iowait=parseInt(p[5]), irq=parseInt(p[6])
            const softirq=parseInt(p[7]), steal=parseInt(p[8])
            const total = user+nice+system+idle+iowait+irq+softirq+steal
            if (root.prevCpuStats.total !== undefined) {
                const dTotal = total - root.prevCpuStats.total
                const dIdle  = idle  - root.prevCpuStats.idle
                const usage  = dTotal > 0 ? (dTotal - dIdle) / dTotal : 0
                cpuGauge.value = usage
                cpuGauge.text  = Math.round(usage * 100) + "%"
            }
            root.prevCpuStats = { total: total, idle: idle }
            buf = ""
        }
    }

    // ── CPU PER-CORE ──────────────────────────────────────────────────────────
    Process {
        id: cpuCoreProcess
        command: ["cat", "/proc/stat"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => cpuCoreProcess.buf += data + "\n" }
        onExited: {
            const lines    = buf.split('\n')
            const newStats = []
            const usages   = []
            for (var i = 0; i < lines.length; i++) {
                const p = lines[i].split(/\s+/)
                if (!p[0].match(/^cpu\d+$/)) continue
                const user=parseInt(p[1]), nice=parseInt(p[2]), system=parseInt(p[3])
                const idle=parseInt(p[4]), iowait=parseInt(p[5]), irq=parseInt(p[6])
                const softirq=parseInt(p[7]), steal=parseInt(p[8])
                const total = user+nice+system+idle+iowait+irq+softirq+steal
                const prev  = root.prevCoreStats[newStats.length]
                var usage   = 0
                if (prev) {
                    const dTotal = total - prev.total
                    const dIdle  = idle  - prev.idle
                    usage = dTotal > 0 ? (dTotal - dIdle) / dTotal : 0
                }
                newStats.push({ total: total, idle: idle })
                usages.push(usage)
            }
            root.prevCoreStats = newStats
            // Sync ListModel — append missing slots, update existing
            while (coreModel.count < usages.length)
                coreModel.append({ usage: 0, coreIdx: coreModel.count })
            for (var j = 0; j < usages.length; j++)
                coreModel.setProperty(j, "usage", usages[j])
            buf = ""
        }
    }

    // ── NETWORK ───────────────────────────────────────────────────────────────
    // /proc/net/dev columns (after header lines):
    //   iface: rx_bytes rx_pkts rx_err rx_drop ... tx_bytes ...
    //   col idx: 0=iface 1=rx_bytes 9=tx_bytes
    Process {
        id: netProcess
        command: ["cat", "/proc/net/dev"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => netProcess.buf += data + "\n" }
        onExited: {
            const lines = buf.split('\n')
            const now   = {}
            for (var i = 2; i < lines.length; i++) {
                const line = lines[i].trim()
                if (!line) continue
                const cols  = line.split(/\s+/)
                const iface = cols[0].replace(':', '')
                if (iface === "lo") continue
                now[iface] = { rx: parseInt(cols[1]), tx: parseInt(cols[9]) }
            }
            netModel.clear()
            for (var iface in now) {
                const prev   = root.prevNetStats[iface]
                // divide by 2 because interval is 2s
                const rxRate = prev ? Math.max(0, now[iface].rx - prev.rx) / 2 : 0
                const txRate = prev ? Math.max(0, now[iface].tx - prev.tx) / 2 : 0
                netModel.append({
                    iface:   iface,
                    rxRate:  formatRate(rxRate),
                    txRate:  formatRate(txRate),
                    rxTotal: formatBytes(now[iface].rx),
                    txTotal: formatBytes(now[iface].tx)
                })
            }
            root.prevNetStats = now
            buf = ""
        }
    }

    function formatRate(bps) {
        if (bps < 1024)           return Math.round(bps)           + " B/s"
        if (bps < 1048576)        return (bps / 1024).toFixed(1)   + " KB/s"
        return (bps / 1048576).toFixed(1) + " MB/s"
    }
    function formatBytes(b) {
        if (b < 1024)             return b                           + " B"
        if (b < 1048576)          return (b / 1024).toFixed(1)      + " KB"
        if (b < 1073741824)       return (b / 1048576).toFixed(1)   + " MB"
        return (b / 1073741824).toFixed(2) + " GB"
    }

    // ── BATTERY ───────────────────────────────────────────────────────────────
    Process {
        id: batteryProcess
        command: ["bash", "-c",
            "bat=$(ls /sys/class/power_supply/ 2>/dev/null | grep -iE '^BAT' | head -1);" +
            "[ -z \"$bat\" ] && echo none && exit 0;" +
            "cap=$(cat /sys/class/power_supply/$bat/capacity 2>/dev/null || echo 0);" +
            "stat=$(cat /sys/class/power_supply/$bat/status  2>/dev/null || echo Unknown);" +
            "echo $cap $stat"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => batteryProcess.buf += data + "\n" }
        onExited: {
            const line = buf.trim()
            if (line !== "none" && line !== "") {
                const parts = line.split(/\s+/)
                const cap   = parseInt(parts[0])
                if (!isNaN(cap)) {
                    root.hasBattery    = true
                    root.batteryLevel  = cap / 100
                    root.batteryStatus = parts[1] || ""
                }
            }
            buf = ""
        }
    }

    // ── KERNEL + UPTIME ───────────────────────────────────────────────────────
    Process {
        id: kernelProcess
        command: ["uname", "-r"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => kernelProcess.buf += data + "\n" }
        onExited: { kernelInfo.text = buf.trim(); buf = ""; uptimeProcess.running = true }
    }

    Process {
        id: uptimeProcess
        command: ["cat", "/proc/uptime"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => uptimeProcess.buf += data + "\n" }
        onExited: {
            const secs = parseFloat(buf.split(' ')[0])
            const d = Math.floor(secs / 86400)
            const h = Math.floor(secs % 86400 / 3600)
            const m = Math.floor(secs % 3600 / 60)
            uptimeInfo.text = d + "d " + h + "h " + m + "m"
            buf = ""
        }
    }

    // ── DISK ──────────────────────────────────────────────────────────────────
    Process {
        id: diskProcess
        command: ["lsblk", "-b", "-J", "-o", "NAME,SIZE,TYPE,MOUNTPOINTS"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => diskProcess.buf += data + "\n" }
        onExited: (code) => {
            if (code !== 0) { diskFallbackProcess.running = true; buf = ""; return }
            parseDiskJson(buf); buf = ""
        }
    }

    Process {
        id: diskFallbackProcess
        command: ["lsblk", "-b", "-J", "-o", "NAME,SIZE,TYPE,MOUNTPOINT"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => diskFallbackProcess.buf += data + "\n" }
        onExited: { parseDiskJson(buf); buf = "" }
    }

    function parseDiskJson(raw) {
        try {
            const data = JSON.parse(raw)
            diskListModel.clear()
            function walk(dev) {
                if (!dev) return
                var mps   = dev.mountpoints || (dev.mountpoint ? [dev.mountpoint] : [])
                var mount = ""
                for (var m = 0; m < mps.length; m++)
                    if (mps[m] && mps[m] !== "") mount += (mount ? ", " : "") + mps[m]
                if (dev.type === "disk" || dev.type === "part")
                    diskListModel.append({ name: dev.name || "", size: bytesToSize(parseInt(dev.size)||0), mountpoint: mount })
                if (dev.children)
                    for (var c = 0; c < dev.children.length; c++) walk(dev.children[c])
            }
            for (var i = 0; i < data.blockdevices.length; i++) walk(data.blockdevices[i])
        } catch(e) { console.warn("lsblk parse:", e) }
    }

    // ── TOP PROCESSES ─────────────────────────────────────────────────────────
    // ps aux sorted by %CPU, top 8, awk extracts user|pid|%cpu|%mem|cmd
    Process {
        id: topProcess
        command: ["bash", "-c",
            "ps aux --no-headers --sort=-%cpu | head -8 | " +
            "awk '{cmd=$11; for(i=12;i<=NF;i++) cmd=cmd\" \"$i; print $1\"|\"$2\"|\"$3\"|\"$4\"|\"cmd}'"
        ]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => topProcess.buf += data + "\n" }
        onExited: {
            const lines = buf.split('\n')
            topModel.clear()
            for (var i = 0; i < lines.length; i++) {
                const cols = lines[i].trim().split('|')
                if (cols.length < 5) continue
                // Show just the binary name, not the full path
                const cmdParts = cols[4].trim().split(' ')
                const bin      = cmdParts[0].split('/').pop()
                topModel.append({ user: cols[0], pid: cols[1], cpu: cols[2], mem: cols[3], cmd: bin })
            }
            buf = ""
        }
    }

    // ── PACMAN UPDATES ────────────────────────────────────────────────────────
    // checkupdates is from pacman-contrib. exits 2 = no updates, 0 = updates found.
    Process {
        id: updatesProcess
        command: ["bash", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: false
        property string buf: ""
        stdout: SplitParser { onRead: data => updatesProcess.buf += data + "\n" }
        onExited: {
            const n = parseInt(buf.trim())
            root.pendingUpdates = isNaN(n) ? 0 : n
            buf = ""
        }
    }

    // ── POWER (shared process, fired by buttons) ──────────────────────────────
    Process {
        id: powerProcess
        running: false
    }

    // ── HELPERS ───────────────────────────────────────────────────────────────
    function bytesToSize(bytes) {
        if (!bytes || bytes === 0) return '0 B'
        const units = ['B', 'KB', 'MB', 'GB', 'TB']
        const i = Math.min(Math.floor(Math.log(bytes) / Math.log(1024)), units.length - 1)
        return Math.round(bytes / Math.pow(1024, i)) + ' ' + units[i]
    }

    // ══════════════════════════════════════════════════════════════════════════
    // UI
    // ══════════════════════════════════════════════════════════════════════════
    ScrollView {
        anchors.fill: parent
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 16

            // ── GAUGES ROW ───────────────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                spacing: 20
                Layout.alignment: Qt.AlignHCenter

                // CPU
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    // will be adding optional gauges in the future withen the PersonalizationTab.qml and it will also have order stuff.
                    visible: isCPU_Open

                    Text {
                        text: "CPU"
                        font.bold: true; font.pixelSize: 13
                        color: Dat.Colors.color.on_surface
                        Layout.alignment: Qt.AlignHCenter
                    }
                    CircularProgress {
                        id: cpuGauge
                        Layout.alignment: Qt.AlignHCenter
                        value: 0; text: "0%"
                        progressColor: Dat.Colors.color.primary
                        width: 90; height: 90
                    }
                    Text {
                        visible: root.hasCpuTemp
                        text: root.cpuTemp + "°C"
                        font.pixelSize: 11
                        color: root.cpuTemp > 85 ? "#ef4444"
                             : root.cpuTemp > 70 ? "#f59e0b"
                             : Dat.Colors.color.on_surface
                        opacity: root.cpuTemp > 70 ? 1.0 : 0.65
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // GPU
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    visible: isGPU_Open
                    Text {
                        text: root.gpuLabel
                        font.bold: true
                        font.pixelSize: root.gpuLabel.length > 12 ? 11 : 13
                        color: Dat.Colors.color.on_surface
                        Layout.alignment: Qt.AlignHCenter
                        horizontalAlignment: Text.AlignHCenter
                    }
                    CircularProgress {
                        id: gpuGauge
                        Layout.alignment: Qt.AlignHCenter
                        value: 0; text: "..."
                        progressColor: Dat.Colors.color.secondary
                        width: 110; height: 110
                    }
                    Text {
                        id: gpuGaugeNote
                        text: ""
                        visible: text !== ""
                        font.pixelSize: 9; opacity: 0.55
                        color: Dat.Colors.color.on_surface
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        visible: root.hasGpuTemp
                        text: root.gpuTemp + "°C"
                        font.pixelSize: 11
                        color: root.gpuTemp > 85 ? "#ef4444"
                             : root.gpuTemp > 70 ? "#f59e0b"
                             : Dat.Colors.color.on_surface
                        opacity: root.gpuTemp > 70 ? 1.0 : 0.65
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // RAM
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    visible: isRAM_Open
                    Text {
                        text: "RAM"
                        font.bold: true; font.pixelSize: 13
                        color: Dat.Colors.color.on_surface
                        Layout.alignment: Qt.AlignHCenter
                    }
                    CircularProgress {
                        id: ramGauge
                        Layout.alignment: Qt.AlignHCenter
                        value: 0; text: "0%"
                        progressColor: Dat.Colors.color.tertiary
                        width: 130; height: 130
                    }
                    Text {
                        visible: root.swapTotal > 0
                        text: "swap " + Math.round((root.swapUsed / root.swapTotal) * 100) + "%"
                        font.pixelSize: 11; color: Dat.Colors.color.on_surface; opacity: 0.65
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Swap gauge (only if swap exists)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    visible: isSwap_Open

                    Text {
                        text: "Swap"
                        font.bold: true; font.pixelSize: 13
                        color: Dat.Colors.color.on_surface
                        Layout.alignment: Qt.AlignHCenter
                    }

                    CircularProgress {
                        id: swapGauge
                        Layout.alignment: Qt.AlignHCenter
                        value: 0; text: "0%"
                        progressColor: "#a78bfa"
                        width: 110; height: 110
                    }

                    Text {
                        text: "idk.."
                        font.pixelSize: 11
                        color: Dat.Colors.color.on_surface
                        opacity: 0.65
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Battery (only if detected)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 4
                    visible: isBattery_Open
                    Text {
                        text: "Battery"
                        font.bold: true; font.pixelSize: 13
                        color: Dat.Colors.color.on_surface
                        Layout.alignment: Qt.AlignHCenter
                    }
                    CircularProgress {
                        id: batteryGauge
                        Layout.alignment: Qt.AlignHCenter
                        value: root.batteryLevel
                        text: Math.round(root.batteryLevel * 100) + "%"
                        progressColor: root.batteryLevel < 0.2 ? "#ef4444"
                                     : root.batteryLevel < 0.5 ? "#f59e0b"
                                     : "#22c55e"
                        width: 90; height: 90
                    }
                    Text {
                        text: root.batteryStatus
                        font.pixelSize: 11; color: Dat.Colors.color.on_surface; opacity: 0.65
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
            
            Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

            Text {
                    text: "CPU Cores"
                    font.bold: true; font.pixelSize: 14
                    color: Dat.Colors.color.on_surface
                    leftPadding: 2
                }

            // ── PER-CORE CPU BARS ─────────────────────────────────────────────
            RowLayout { 
                Layout.fillWidth: true
                spacing: 20

                Rectangle { width: 140; height: 1; color: "transparent" }
                
                Flow {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6

                    Repeater {
                        model: ListModel { id: coreModel }
                        delegate: ColumnLayout {
                            spacing: 2
                            width: 36

                            Rectangle {
                                width: 36; height: 56
                                radius: 4
                                color: Qt.rgba(1,1,1,0.06)
                                clip: true

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    width: parent.width
                                    height: parent.height * model.usage
                                    radius: 4
                                    color: model.usage > 0.85 ? "#ef4444"
                                         : model.usage > 0.60 ? "#f59e0b"
                                         : Dat.Colors.color.primary

                                    Behavior on height { NumberAnimation { duration: 350; easing.type: Easing.OutCubic } }
                                    Behavior on color  { ColorAnimation  { duration: 250 } }
                                }
                            }

                            Text {
                                text: index
                                font.pixelSize: 9
                                color: Dat.Colors.color.on_surface; opacity: 0.5
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                    }
                }
            
          }
            

            // ── NETWORK ───────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "Network"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2 }
                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    Layout.rightMargin: 4

                    Text { text: "Interface"; font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }
                    Text { text: "↓ Rate";    font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                    Text { text: "↑ Rate";    font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                    Text { text: "↓ Total";   font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 75; horizontalAlignment: Text.AlignRight }
                    Text { text: "↑ Total";   font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 75; horizontalAlignment: Text.AlignRight }
                }

                Repeater {
                    model: ListModel { id: netModel }
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 34
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.03)
                        radius: 3

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4

                            Text { text: model.iface;   font.family: "monospace"; font.pixelSize: 12; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }
                            Text { text: model.rxRate;  font.pixelSize: 12; color: "#4ade80"; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                            Text { text: model.txRate;  font.pixelSize: 12; color: "#60a5fa"; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                            Text { text: model.rxTotal; font.pixelSize: 11; color: Dat.Colors.color.on_surface; opacity: 0.5; Layout.preferredWidth: 75; horizontalAlignment: Text.AlignRight }
                            Text { text: model.txTotal; font.pixelSize: 11; color: Dat.Colors.color.on_surface; opacity: 0.5; Layout.preferredWidth: 75; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }

            // ── TOP PROCESSES ─────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "Top Processes"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2 }
                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    Layout.rightMargin: 4

                    Text { text: "Command"; font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }
                    Text { text: "PID";     font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 55; horizontalAlignment: Text.AlignRight }
                    Text { text: "%CPU";    font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignRight }
                    Text { text: "%MEM";    font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignRight }
                }

                Repeater {
                    model: ListModel { id: topModel }
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 30
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.03)
                        radius: 3

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4

                            Text {
                                text: model.cmd
                                font.family: "monospace"; font.pixelSize: 12
                                color: Dat.Colors.color.on_surface
                                elide: Text.ElideRight; Layout.fillWidth: true
                            }
                            Text { text: model.pid; font.pixelSize: 11; color: Dat.Colors.color.on_surface; opacity: 0.55; Layout.preferredWidth: 55; horizontalAlignment: Text.AlignRight }
                            Text {
                                text: model.cpu; font.pixelSize: 12
                                color: parseFloat(model.cpu) > 50 ? "#ef4444"
                                     : parseFloat(model.cpu) > 20 ? "#f59e0b"
                                     : Dat.Colors.color.on_surface
                                Layout.preferredWidth: 50; horizontalAlignment: Text.AlignRight
                            }
                            Text { text: model.mem; font.pixelSize: 12; color: Dat.Colors.color.on_surface; opacity: 0.8; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignRight }
                        }
                    }
                }
            }

            // ── DISK LIST ─────────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "Disk Usage"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2 }
                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    Layout.rightMargin: 4

                    Text { text: "Device"; font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }
                    Text { text: "Size";   font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                    Text { text: "Mount";  font.pixelSize: 11; opacity: 0.5; color: Dat.Colors.color.on_surface; Layout.preferredWidth: 160; horizontalAlignment: Text.AlignRight }
                }

                Repeater {
                    model: ListModel { id: diskListModel }
                    delegate: Rectangle {
                        Layout.fillWidth: true; height: 34
                        color: index % 2 === 0 ? "transparent" : Qt.rgba(1,1,1,0.03)
                        radius: 3

                        RowLayout {
                            anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4

                            Text { text: model.name; font.family: "monospace"; font.pixelSize: 12; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }
                            Text { text: model.size; font.pixelSize: 12; color: Dat.Colors.color.on_surface; opacity: 0.75; Layout.preferredWidth: 80; horizontalAlignment: Text.AlignRight }
                            Text {
                                text: model.mountpoint !== "" ? model.mountpoint : "—"
                                color: model.mountpoint !== "" ? Dat.Colors.color.primary : Dat.Colors.color.on_surface
                                opacity: model.mountpoint !== "" ? 1.0 : 0.3
                                font.pixelSize: 12; elide: Text.ElideMiddle
                                Layout.preferredWidth: 160; horizontalAlignment: Text.AlignRight
                            }
                        }
                    }
                }
            }

            // ── SYSTEM INFORMATION ────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "System Information"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2 }
                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2; rowSpacing: 4; columnSpacing: 12

                    Text { text: "Kernel"; font.pixelSize: 12; opacity: 0.55; color: Dat.Colors.color.on_surface }
                    Text { id: kernelInfo; text: "…"; font.family: "monospace"; font.pixelSize: 12; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }

                    Text { text: "Uptime"; font.pixelSize: 12; opacity: 0.55; color: Dat.Colors.color.on_surface }
                    Text { id: uptimeInfo; text: "…"; font.pixelSize: 12; color: Dat.Colors.color.on_surface; Layout.fillWidth: true }

                    Text { text: "GPU"; font.pixelSize: 12; opacity: 0.55; color: Dat.Colors.color.on_surface; visible: root.gpuType !== "none" }
                    Text {
                        text: root.gpuLabel + (root.hasIgpu && root.gpuType !== "intel" ? "  +  iGPU" : "")
                        font.pixelSize: 12; color: Dat.Colors.color.on_surface; Layout.fillWidth: true
                        visible: root.gpuType !== "none"
                    }

                    Text { text: "Updates"; font.pixelSize: 12; opacity: 0.55; color: Dat.Colors.color.on_surface; visible: root.pendingUpdates >= 0 }
                    Text {
                        text: root.pendingUpdates === 0 ? "Up to date" : root.pendingUpdates + " pending"
                        font.pixelSize: 12
                        color: root.pendingUpdates > 0 ? "#f59e0b" : "#22c55e"
                        Layout.fillWidth: true
                        visible: root.pendingUpdates >= 0
                    }
                }
            }

            // ── POWER ACTIONS ─────────────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6

                Text { text: "Power"; font.bold: true; font.pixelSize: 14; color: Dat.Colors.color.on_surface; leftPadding: 2 }
                Rectangle { Layout.fillWidth: true; height: 1; color: Dat.Colors.color.on_surface; opacity: 0.12 }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Repeater {
                        model: [
                            { label: "Shutdown",  icon: "⏻", cmd: ["systemctl", "poweroff"]  },
                            { label: "Reboot",    icon: "↺", cmd: ["systemctl", "reboot"]    },
                            { label: "Hibernate", icon: "⏾", cmd: ["systemctl", "hibernate"] },
                            { label: "Suspend",   icon: "⏸", cmd: ["systemctl", "suspend"]   }
                        ]
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            height: 58
                            radius: 8
                            color: btnHover.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.05)
                            border.color: "#ef4444"
                            border.width: confirmTimer.running ? 1 : 0

                            Behavior on color       { ColorAnimation { duration: 120 } }
                            Behavior on border.width { NumberAnimation { duration: 120 } }

                            // Two-tap confirm: first tap arms a 2.5s window, second tap fires
                            Timer {
                                id: confirmTimer
                                interval: 2500
                                repeat: false
                            }

                            HoverHandler { id: btnHover }

                            TapHandler {
                                onTapped: {
                                    if (confirmTimer.running) {
                                        confirmTimer.stop()
                                        powerProcess.command = modelData.cmd
                                        powerProcess.running = true
                                    } else {
                                        confirmTimer.start()
                                    }
                                }
                            }

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 3

                                Text {
                                    text: confirmTimer.running ? "?" : modelData.icon
                                    font.pixelSize: 20
                                    color: confirmTimer.running ? "#ef4444" : Dat.Colors.color.on_surface
                                    Layout.alignment: Qt.AlignHCenter
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }
                                Text {
                                    text: confirmTimer.running ? "confirm" : modelData.label
                                    font.pixelSize: 10
                                    color: confirmTimer.running ? "#ef4444" : Dat.Colors.color.on_surface
                                    opacity: confirmTimer.running ? 1.0 : 0.7
                                    Layout.alignment: Qt.AlignHCenter
                                    Behavior on color { ColorAnimation { duration: 120 } }
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 16 }
        }
    }
}