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

    property int grimRetries: 0
    // "freeze" shows the overlay; "window" proceeds to copy+notify. Both go
    // through grimProcess so one retry/timeout/kill path covers them.
    property string grimMode: "freeze"
    property string windowAddress: ""
    property string windowOutput: ""

    function notifyError(title, body) {
        Quickshell.execDetached(["notify-send", title, body, "-u", "critical", "-a", "Hyprquickshot"]);
    }

    function runFreezeCapture() {
        const screen = activeScreen;
        if (!screen)
            return;
        grimMode = "freeze";
        grimProcess.command = ["sh", "-c", `timeout ${Config.grimTimeoutSec} grim -g "${screen.x},${screen.y} ${screen.width}x${screen.height}" "${tempPath}"`];
        grimProcess.running = true;
    }

    function runWindowCapture(address) {
        grimMode = "window";
        windowOutput = outputPath();
        // Restart the watchdog: window capture runs after the freeze watchdog
        // stopped, so without this a stall is only caught by grim's timeout,
        // never the hard kill.
        watchdog.start();
        grimProcess.command = ["sh", "-c", `mkdir -p "${Config.screenshotDir}" && timeout ${Config.grimTimeoutSec} grim -w "${address}" "${windowOutput}"`];
        grimProcess.running = true;
    }

    function processRegion(x, y, width, height) {
        // Guard against a zero-size selection (a click without a drag): magick
        // writes a corrupt 0x0 png with exit code 0.
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
        windowAddress = address;
        runWindowCapture(address);
    }

    function outputPath() {
        return `${Config.screenshotDir}/screenshot-${Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss")}.png`;
    }

    function runProcessing(steps) {
        // `timeout` bounds a wedged clipboard/notification daemon; the here-doc
        // keeps step contents from breaking shell quoting.
        const script = steps.join("\n");
        screenshotProcess.command = ["sh", "-c", `timeout ${Config.watchdogSec} sh <<'QS_EOF'
${script}
QS_EOF`];
        screenshotProcess.running = true;
        root.visible = false;
    }

    visible: false
    targetScreen: activeScreen

    // Resolve the focused monitor to a Quickshell screen and launch grim.
    // Returns false if the monitor isn't ready yet (caller retries on signal).
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

    // Start on launch rather than waiting for a focus-change signal, which
    // can arrive late under load and leave the process with no exit path.
    Component.onCompleted: beginCapture()

    // Fallback if focusedMonitor wasn't ready at completion.
    Connections {
        target: Hyprland
        enabled: activeScreen === null

        function onFocusedMonitorChanged() {
            beginCapture();
        }
    }

    // Hard safety net: if anything wedges, kill grim and quit so the -n
    // instance never blocks the next screenshot.
    Timer {
        id: watchdog
        interval: Config.watchdogSec * 1000
        repeat: false
        onTriggered: {
            console.warn("screenshot watchdog: capture exceeded " + Config.watchdogSec + "s, aborting");
            if (grimProcess.running) {
                grimProcess.signal(9);
                grimRetries = Config.maxGrimRetries + 1; // suppress retries
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
        onExited: exitCode => {
            if (exitCode === 0) {
                // Stop the watchdog so it can't fire during user selection.
                watchdog.stop();
                if (grimMode === "window") {
                    runProcessing([`rm -f "${tempPath}"`, `wl-copy < "${windowOutput}" || true`, `notify-send "Screenshot saved" "${windowOutput}" -i "${windowOutput}" -a "Hyprquickshot" || true`]);
                    grimRetries = 0;
                    return;
                }
                root.sourcePath = "file://" + tempPath;
                root.visible = true;
                grimRetries = 0;
                return;
            }
            if (grimRetries < Config.maxGrimRetries) {
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
        onExited: exitCode => {
            watchdog.stop();
            if (exitCode !== 0) {
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
