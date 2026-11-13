import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: root

    property var state: ({})
    property string timerText: ""
    property string actTimerText: ""
    property bool panelVisible: true
    property bool hintsVisible: false

    readonly property real sideMargin: Config.anchorX === "left" || Config.anchorX === "right" ? Config.margin : Math.max(0, Math.round(((Config.targetScreen ? Config.targetScreen.width : 0) - Config.width) / 2))

    function send(command) {
        if (parser.running)
            parser.write(command + "\n");
    }

    function applyState(data) {
        try {
            const message = JSON.parse(data);
            if (message.tick) {
                root.timerText = message.timer;
                root.actTimerText = message.act_timer;
                return;
            }
            root.state = message;
            root.timerText = message.timer ?? "";
            root.actTimerText = message.act_timer ?? "";
        } catch (error) {
            console.error("poe-leveling: bad state line", data, error);
        }
    }

    WlrLayershell {
        id: panelLayer

        visible: root.panelVisible
        layer: WlrLayer.Overlay
        screen: Config.targetScreen
        exclusiveZone: 0
        keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        mask: Region {} // click-through

        anchors.top: Config.anchorY !== "bottom"
        anchors.bottom: Config.anchorY === "bottom"
        anchors.left: Config.anchorX !== "right"
        anchors.right: Config.anchorX !== "left"

        margins {
            top: Config.anchorY === "bottom" ? 0 : Config.margin
            bottom: Config.anchorY === "bottom" ? Config.margin : 0
            left: root.sideMargin
            right: root.sideMargin
        }

        implicitWidth: Config.width
        implicitHeight: panel.implicitHeight

        Panel {
            id: panel

            anchors.top: parent.top
            width: parent.width
            state: root.state
            timerText: root.timerText
            actTimerText: root.actTimerText
        }
    }

    WlrLayershell {
        id: hintLayer

        visible: root.hintsVisible && (root.state.hints ?? []).length > 0
        layer: WlrLayer.Overlay
        screen: Config.targetScreen
        exclusiveZone: 0
        keyboardFocus: WlrKeyboardFocus.None
        color: "transparent"
        mask: Region {} // click-through

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        HintOverlay {
            anchors.fill: parent
            hints: root.state.hints ?? []
        }
    }

    Process {
        id: parser

        command: ["python3", Config.scriptsDir + "/poe_parser.py", "--log", Config.logPath, "--data", Config.dataDir, "--state", Config.statePath, "--league-start", Config.leagueStart ? "yes" : "no", "--bandit", Config.bandit, "--character", Config.characterName]
        stdinEnabled: true
        running: true

        stdout: SplitParser {
            onRead: data => root.applyState(data)
        }

        stderr: SplitParser {
            onRead: data => console.warn("poe-leveling:", data)
        }

        onExited: (code, status) => {
            console.warn("poe-leveling: parser exited with", code, "- restarting");
            restartTimer.start();
        }
    }

    Timer {
        id: restartTimer

        interval: 3000
        onTriggered: parser.running = true
    }

    IpcHandler {
        target: "leveling"

        function next() {
            root.send("next");
        }

        function prev() {
            root.send("prev");
        }

        function reset() {
            root.send("reset");
        }

        function toggle() {
            root.panelVisible = !root.panelVisible;
        }

        function hints() {
            root.hintsVisible = !root.hintsVisible;
        }
    }
}
