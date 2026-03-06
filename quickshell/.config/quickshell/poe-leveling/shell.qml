import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

ShellRoot {
    id: root

    property var currentHints: []

    WlrLayershell {
        id: overlay

        layer: WlrLayer.Overlay
        anchors {
            top: true
            left: true
            right: true
            bottom: false
        }

        margins {
            top: -20
            left: (screen.width - Config.panelWidth) / 2
            right: (screen.width - Config.panelWidth) / 2
        }

        exclusiveZone: 0
        keyboardFocus: WlrKeyboardFocus.None
        screen: Quickshell.screens[0]

        implicitWidth: Config.panelWidth
        implicitHeight: Config.panelHeight
        color: "transparent"

        LevelingPanel {
            id: panel
            anchors.fill: parent
        }

        visible: true
    }

    WlrLayershell {
        id: hintOverlay

        layer: WlrLayer.Overlay
        anchors {
            top: true
            bottom: true
            right: true
        }

        exclusiveZone: 0
        keyboardFocus: WlrKeyboardFocus.None
        screen: Quickshell.screens[0]

        implicitWidth: 700
        implicitHeight: screen.height
        color: "transparent"

        HintOverlay {
            anchors.fill: parent
            hints: currentHints
        }

        visible: false
    }

    Process {
        id: parser

        command: ["python3", Config.scriptsDir + "/poe_parser.py", Config.logPath || "/tmp/poe_test_client.txt", Config.dataDir + "/guide.json", Config.dataDir + "/areas.json", Config.dataDir + "/gems.json"]

        running: true

        stdout: SplitParser {
            splitMarker: "\n"

            onRead: data => {
                try {
                    const state = JSON.parse(data);
                    console.log("Zone changed to:", state.zone_name);
                    panel.updateState(state);
                    currentHints = state.hints || [];
                } catch (e) {
                    console.error("Failed to parse JSON:", data, e);
                }
            }
        }

        stderr: SplitParser {
            splitMarker: "\n"
            onRead: data => console.error("Parser stderr:", data)
        }

        onExited: (code, status) => {
            console.error("Parser exited with code:", code);
        }
    }

    SocketServer {
        id: ipcServer

        path: "/tmp/poe-leveling.sock"
        active: true

        handler: Socket {
            parser: SplitParser {
                splitMarker: "\n"

                onRead: data => {
                    const cmd = data.trim();

                    if (cmd === "next") {
                        panel.nextPage();
                    } else if (cmd === "prev") {
                        panel.prevPage();
                    } else if (cmd === "hints") {
                        hintOverlay.visible = !hintOverlay.visible;
                    }

                    connected = false;
                }
            }
        }
    }
}
