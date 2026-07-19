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

    function notifyError(title, body) {
        Quickshell.execDetached(["notify-send", title, body, "-u", "critical", "-a", "Hyprquickshot"]);
    }

    function runFreezeCapture() {
        const screen = activeScreen;
        if (!screen)
            return;
        // `timeout` guards against grim hanging on a stalled compositor.
        grimProcess.command = ["sh", "-c", `timeout ${Config.grimTimeoutSec} grim -g "${screen.x},${screen.y} ${screen.width}x${screen.height}" "${tempPath}"`];
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
        // background, works across workspaces, avoids scale/crop math. Retries
        // since it hits the GPU too.
        const out = outputPath();
        runProcessing([`mkdir -p "${Config.screenshotDir}" || exit 11`, `s=0; for _i in 1 2 3 4; do timeout 8 grim -w "${address}" "${out}" && s=1 && break; sleep 0.25; done; [ "$s" = 1 ] || exit 12`, `wl-copy < "${out}" || true`, `notify-send "Screenshot saved" "${out}" -i "${out}" -a "Hyprquickshot" || true`]);
    }

    function outputPath() {
        return `${Config.screenshotDir}/screenshot-${Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss")}.png`;
    }

    function runProcessing(steps) {
        screenshotProcess.command = ["sh", "-c", steps.join("\n")];
        screenshotProcess.running = true;
        root.visible = false;
    }

    visible: false
    targetScreen: activeScreen

    // Wait for the focused monitor, then resolve it to a Quickshell screen
    // and kick off the freeze capture. Disabled once a screen is bound so
    // we don't re-trigger on every focus change.
    Connections {
        target: Hyprland
        enabled: activeScreen === null

        function onFocusedMonitorChanged() {
            const monitor = Hyprland.focusedMonitor;
            if (!monitor)
                return;

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
                return;
            }

            activeScreen = screen;
            grimRetries = 0;
            tempPath = `/tmp/screenshot-${Date.now()}.png`;
            runFreezeCapture();
        }
    }

    Shortcut {
        sequence: "Escape"
        onActivated: () => {
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
        onTriggered: runFreezeCapture()
    }

    Process {
        id: grimProcess

        running: false
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
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
            if (exitCode !== 0) {
                // 11 = mkdir failed, 12 = capture/crop failed.
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
