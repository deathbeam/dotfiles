import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Io
import QtCore

FreezeScreen {
    id: root
    visible: false

    property var activeScreen: null
    property var hyprlandMonitor: Hyprland.focusedMonitor
    property string mode: "region"

    Connections {
        target: Hyprland
        enabled: activeScreen === null

        function onFocusedMonitorChanged() {
            const monitor = Hyprland.focusedMonitor
            if(!monitor) return

            for (const screen of Quickshell.screens) {
                if (screen.name === monitor.name) {
                    activeScreen = screen
                    showTimer.start()
                }
            }
        }
    }

    targetScreen: activeScreen

    Shortcut {
        sequence: "Escape"
        onActivated: () => Qt.quit()
    }

    Timer {
        id: showTimer
        interval: 50
        running: false
        repeat: false
        onTriggered: root.visible = true
    }

    Process {
        id: screenshotProcess
        running: false

        onExited: () => Qt.quit()

        stdout: StdioCollector {
            onStreamFinished: console.log(this.text)
        }
        stderr: StdioCollector {
            onStreamFinished: console.log(this.text)
        }
    }

    function processScreenshot(x, y, width, height) {
        const scale = hyprlandMonitor.scale
        const scaledX = Math.round(x * scale)
        const scaledY = Math.round(y * scale)
        const scaledWidth = Math.round(width * scale)
        const scaledHeight = Math.round(height * scale)

        // Ensure screenshot directory exists
        const mkdirCmd = `mkdir -p "${Config.screenshotDir}"`

        const now = new Date()
        const timestamp = Qt.formatDateTime(now, "yyyy-MM-dd_hh-mm-ss")
        const outputPath = `${Config.screenshotDir}/screenshot-${timestamp}.png`

        // Get monitor geometry
        const monX = root.activeScreen.x
        const monY = root.activeScreen.y

        screenshotProcess.command = ["sh", "-c",
            `${mkdirCmd} && ` +
            `grim -g "${monX + scaledX},${monY + scaledY} ${scaledWidth}x${scaledHeight}" "${outputPath}" && ` +
            `wl-copy < "${outputPath}" && ` +
            `notify-send "Screenshot saved" "${outputPath}" -i "${outputPath}" -a "Hyprquickshot"`
        ]

        screenshotProcess.running = true
        root.visible = false
    }

    RegionSelector {
        visible: mode === "region"
        id: regionSelector
        anchors.fill: parent

        onRegionSelected: (x, y, width, height) => {
            processScreenshot(x, y, width, height)
        }
    }

    WindowSelector {
        visible: mode === "window"
        id: windowSelector
        anchors.fill: parent

        monitor: root.hyprlandMonitor

        onRegionSelected: (x, y, width, height) => {
            processScreenshot(x, y, width, height)
        }
    }

    WrapperRectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 40

        color: Qt.rgba(0.1, 0.1, 0.1, 0.8)
        radius: 12
        margin: 8

        Row {
            id: buttonRow
            spacing: 8

            Repeater {
                model: [
                    { mode: "region", icon: "Region" },
                    { mode: "window", icon: "Window" },
                    { mode: "screen", icon: "Screen" }
                ]

                Button {
                    id: modeButton
                    implicitWidth: 48
                    implicitHeight: 48

                    background: Rectangle {
                        radius: 8
                        color: {
                            if(mode === modelData.mode) return Qt.rgba(0.3, 0.4, 0.7, 0.5)
                            if (modeButton.hovered) return Qt.rgba(0.4, 0.4, 0.4, 0.5)

                            return Qt.rgba(0.3, 0.3, 0.35, 0.5)
                        }

                        Behavior on color { ColorAnimation { duration: 100 } }
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

                    onClicked: {
                        root.mode = modelData.mode
                        if (modelData.mode === "screen") {
                            processScreenshot(0, 0, root.targetScreen.width, root.targetScreen.height)
                        }
                    }
                }
            }
        }
    }
}
