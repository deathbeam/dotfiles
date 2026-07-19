import QtCore
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets

FreezeScreen {
    id: root

    property var activeScreen: null
    property var hyprlandMonitor: Hyprland.focusedMonitor
    property string mode: "region"
    property string tempPath

    // grim retry state. grim can fail transiently when the GPU / compositor is
    // busy (no frame ready yet); a few retries with a short backoff almost
    // always recovers. Previously a single grim failure left a dead black
    // overlay with no feedback, which is the "doesn't work" symptom.
    property int grimRetries: 0
    readonly property int maxGrimRetries: Config.maxGrimRetries

    // Which grim capture is in progress, so onExited/retry know what success
    // means: "freeze" shows the overlay, "window" proceeds to copy+notify.
    // Unifying both through grimProcess means one retry policy, one timeout,
    // and one kill target the watchdog can actually reach.
    property string grimMode: "freeze"
    // Remembered so the retry timer can re-issue a window capture without
    // re-running selection logic.
    property string windowAddress: ""
    property string windowOutput: ""

    function notifyError(title, body) {
        Quickshell.execDetached(["notify-send", title, body, "-u", "critical", "-a", "Hyprquickshot"]);
    }

    function runFreezeCapture() {
        const screen = activeScreen;
        if (!screen)
            return;
        // `timeout` guards against grim hanging on a stalled compositor.
        grimMode = "freeze";
        grimProcess.command = ["sh", "-c", `timeout ${Config.grimTimeoutSec} grim -g "${screen.x},${screen.y} ${screen.width}x${screen.height}" "${tempPath}"`];
        grimProcess.running = true;
    }

    // Capture a single toplevel via `grim -w`, routing through grimProcess so
    // the same watchdog / retry / kill path covers window mode — previously
    // this had its own inline shell loop in screenshotProcess, which the
    // watchdog could not reach and which could orphan grim after Qt.quit().
    function runWindowCapture(address) {
        grimMode = "window";
        windowOutput = outputPath();
        // Restart the watchdog so the post-selection grim is hard-bounded too —
        // otherwise window capture runs after the freeze watchdog stopped and
        // a stall could only be caught by grim's own timeout, never the kill.
        watchdog.start();
        grimProcess.command = ["sh", "-c", `mkdir -p "${Config.screenshotDir}" && timeout ${Config.grimTimeoutSec} grim -w "${address}" "${windowOutput}"`];
        grimProcess.running = true;
    }

    function processRegion(x, y, width, height) {
        // Crop the frozen screen image to the selected region. magick is
        // CPU-only, so this is reliable once the frozen frame exists. Guard
        // against a zero-size selection (e.g. a click without a drag) since
        // magick happily writes a corrupt 0x0 png with exit code 0.
        if (width <= 0 || height <= 0) {
            notifyError("Screenshot cancelled", "Selection was empty.");
            Quickshell.execDetached(["rm", "-f", tempPath]);
            Qt.quit();
            return;
        }
        const scale = hyprlandMonitor.scale || 1;
        const crop = `${Math.round(width * scale)}x${Math.round(height * scale)}+${Math.round(x * scale)}+${Math.round(y * scale)}`;
        const out = outputPath();
        runProcessing([`mkdir -p "${Config.screenshotDir}" || exit 11`, `magick "${tempPath}" -crop ${crop} "${out}" || exit 12`, `wl-copy < "${out}" || true`, `rm -f "${tempPath}"`, `notify-send "Screenshot saved" "${out}" -i "${out}" -a "Hyprquickshot" || true`]);
    }

    function processWindow(address) {
        // Grab the real toplevel via `grim -w`. Independent of the frozen
        // background, works across workspaces, avoids scale/crop math.
        windowAddress = address; // remembered so retries reuse the same target
        runWindowCapture(address);
    }

    function outputPath() {
        return `${Config.screenshotDir}/screenshot-${Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss")}.png`;
    }

    function runProcessing(steps) {
        // Wrap in `timeout` so a wedged clipboard/notification daemon can't
        // hang screenshotProcess forever and leave an immortal -n instance —
        // the same class of bug that grim had before the watchdog. The script
        // is passed via a here-doc so step contents (filenames with quotes,
        // apostrophes, etc.) can't break shell quoting.
        const script = steps.join("\n");
        screenshotProcess.command = ["sh", "-c", `timeout ${Config.watchdogSec} sh <<'QS_EOF'
${script}
QS_EOF`];
        screenshotProcess.running = true;
        root.visible = false;
    }

    visible: false
    targetScreen: activeScreen

    // Kick off the capture. Resolve the focused monitor to a Quickshell screen,
    // set up the temp path, and launch grim. Returns false if the monitor
    // isn't ready yet so the caller can retry on the change signal.
    function beginCapture(): bool {
        if (activeScreen !== null)
            return true;

        const monitor = Hyprland.focusedMonitor;
        if (!monitor)
            return false;

        let screen = null;
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === monitor.name) {
                screen = Quickshell.screens[i];
                break;
            }
        }
        if (!screen) {
            notifyError("Screenshot failed", "Could not find the active screen.");
            Qt.quit();
            return true;
        }

        activeScreen = screen;
        grimRetries = 0;
        tempPath = `/tmp/screenshot-${Date.now()}.png`;
        watchdog.start();
        runFreezeCapture();
        return true;
    }

    // Trigger directly on launch. Previously capture began on
    // Hyprland.onFocusedMonitorChanged, a *change* signal that under GPU/IPC
    // load can arrive late or never — leaving grim unstarted, Qt.quit() never
    // called, and an immortal invisible process that --no-duplicate then
    // blocks every later screenshot. Starting immediately guarantees the
    // exit path is always reachable; the Connections below is only a fallback
    // for the rare case the monitor isn't populated yet at launch.
    Component.onCompleted: beginCapture()

    // Fallback: if focusedMonitor wasn't ready at completion, start when it
    // arrives. Disabled once a screen is bound so we don't re-trigger.
    Connections {
        target: Hyprland
        enabled: activeScreen === null

        function onFocusedMonitorChanged() {
            beginCapture();
        }
    }

    // Hard safety net. No matter what wedges (trigger missed, grim hung past
    // its timeout, retry loop stuck), this fires and we kill grim + quit, so
    // the -n instance never stays alive and blocks the next screenshot.
    Timer {
        id: watchdog
        interval: Config.watchdogSec * 1000
        repeat: false
        onTriggered: {
            console.warn("screenshot watchdog: capture exceeded " + Config.watchdogSec + "s, aborting");
            if (grimProcess.running) {
                grimProcess.signal(9); // SIGKILL
                grimRetries = maxGrimRetries + 1; // suppress further retries
            }
            retryTimer.stop();
            notifyError("Screenshot failed", "Capture timed out. The GPU/compositor may be busy — try again.");
            Quickshell.execDetached(["rm", "-f", tempPath]);
            Qt.quit();
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: () => {
            watchdog.stop();
            retryTimer.stop();
            if (grimProcess.running)
                grimProcess.signal(9);
            Quickshell.execDetached(["rm", "-f", tempPath]);
            Qt.quit();
        }
    }

    Shortcut {
        sequence: "Tab"
        onActivated: if (mode === "window")
            windowSelector.cycle(1)
    }

    Shortcut {
        sequence: "Shift+Tab"
        onActivated: if (mode === "window")
            windowSelector.cycle(-1)
    }

    Shortcut {
        sequence: "Return"
        onActivated: if (mode === "window")
            windowSelector.selectHovered()
    }

    Timer {
        id: retryTimer

        // Escalating backoff: 200ms, 400ms, 800ms.
        interval: 200 * Math.pow(2, Math.max(0, grimRetries - 1))
        repeat: false
        // Retry whatever capture mode is active — the shell-loop duplication
        // that used to live in processWindow is gone, so one path covers both.
        onTriggered: {
            if (grimMode === "window")
                runWindowCapture(windowAddress);
            else
                runFreezeCapture();
        }
    }

    Process {
        id: grimProcess

        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                // Capture done — stop the watchdog so it can't fire during the
                // (unbounded) user selection phase and quit mid-pick.
                watchdog.stop();
                if (grimMode === "window") {
                    // Window capture writes straight to the final file; finish
                    // the copy+notify pipeline, then quit.
                    // Drop the freeze frame too: window mode never used it, and
                    // region/screen deletion lives in runProcessing steps.
                    runProcessing([`rm -f "${tempPath}"`, `wl-copy < "${windowOutput}" || true`, `notify-send "Screenshot saved" "${windowOutput}" -i "${windowOutput}" -a "Hyprquickshot" || true`]);
                    grimRetries = 0;
                    return;
                }
                root.sourcePath = "file://" + tempPath;
                root.visible = true;
                grimRetries = 0;
                return;
            }
            // Capture failed (GPU busy, compositor stall, or timeout). Retry a
            // few times before giving up with a clear error notification.
            if (grimRetries < maxGrimRetries) {
                grimRetries++;
                retryTimer.start();
            } else {
                watchdog.stop();
                notifyError("Screenshot failed", "Could not capture the screen. The GPU may be busy — try again.");
                Quickshell.execDetached(["rm", "-f", tempPath]);
                Qt.quit();
            }
        }

        stdout: StdioCollector {
            onStreamFinished: if (this.text.trim().length > 0)
                console.log(this.text)
        }

        stderr: StdioCollector {
            onStreamFinished: if (this.text.trim().length > 0)
                console.warn(this.text)
        }
    }

    Process {
        id: screenshotProcess

        running: false
        onExited: (exitCode, exitStatus) => {
            watchdog.stop();
            if (exitCode !== 0) {
                // 11 = mkdir failed, 12 = capture/crop failed, 124 = timeout.
                notifyError("Screenshot failed", `Processing failed (code ${exitCode}).`);
                Quickshell.execDetached(["rm", "-f", tempPath]);
            }
            Qt.quit();
        }

        stdout: StdioCollector {
            onStreamFinished: if (this.text.trim().length > 0)
                console.log(this.text)
        }

        stderr: StdioCollector {
            onStreamFinished: if (this.text.trim().length > 0)
                console.warn(this.text)
        }
    }

    RegionSelector {
        id: regionSelector

        visible: mode === "region"
        anchors.fill: parent
        onRegionSelected: (x, y, width, height) => processRegion(x, y, width, height)
    }

    WindowSelector {
        id: windowSelector

        visible: mode === "window"
        anchors.fill: parent
        monitor: root.hyprlandMonitor
        onWindowSelected: address => processWindow(address)
    }

    WrapperRectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 40
        color: Qt.rgba(0.1, 0.1, 0.1, 0.8)
        radius: 12
        margin: 8

        Row {
            id: buttonRow

            spacing: 8

            Repeater {
                model: [
                    {
                        "mode": "region",
                        "icon": "Region"
                    },
                    {
                        "mode": "window",
                        "icon": "Window"
                    },
                    {
                        "mode": "screen",
                        "icon": "Screen"
                    }
                ]

                Button {
                    id: modeButton

                    implicitWidth: 48
                    implicitHeight: 48
                    onClicked: {
                        root.mode = modelData.mode;
                        if (modelData.mode === "screen")
                            processRegion(0, 0, root.targetScreen.width, root.targetScreen.height);
                    }

                    background: Rectangle {
                        radius: 8
                        color: {
                            if (mode === modelData.mode)
                                return Qt.rgba(0.3, 0.4, 0.7, 0.5);

                            if (modeButton.hovered)
                                return Qt.rgba(0.4, 0.4, 0.4, 0.5);

                            return Qt.rgba(0.3, 0.3, 0.35, 0.5);
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 100
                            }
                        }
                    }

                    contentItem: Item {
                        anchors.fill: parent

                        Text {
                            anchors.centerIn: parent
                            text: Config["icon" + modelData.icon]
                            font.family: Config.fontFamily
                            font.pixelSize: Config.iconSize
                            color: "white"
                        }
                    }
                }
            }
        }
    }
}
