pragma Singleton
import QtQuick
import Quickshell

QtObject {
    // Panel look
    readonly property color background: "#002B36"
    readonly property color foreground: "#EEE8D5"
    readonly property color foregroundDim: "#93A1A1"
    readonly property color accent: "#2AA198"
    readonly property color border: "#1F6F6B"
    readonly property real opacity: 0.78
    readonly property int width: 560
    readonly property int fontSize: 14
    readonly property string fontFamily: "sans-serif"
    readonly property int padding: 10
    readonly property int radius: 8
    readonly property int spacing: 3

    // Placement: "<top|bottom>-<left|center|right>" plus the distance to that screen edge
    readonly property string anchor: "top-center"
    readonly property int margin: 8
    readonly property string screenName: "" // "" = first screen

    // Guide
    readonly property bool leagueStart: false
    readonly property string bandit: "none" // none, alira, kraityn, oak
    readonly property string characterName: "" // "" = track every character

    readonly property string anchorY: anchor.split("-")[0]
    readonly property string anchorX: anchor.split("-")[1]

    // Paths
    readonly property string logPath: Quickshell.env("POE_LOG_PATH") || (Quickshell.env("HOME") + "/.local/share/Steam/steamapps/common/Path of Exile/logs/LatestClient.txt")
    readonly property string dataDir: Quickshell.shellDir + "/data"
    readonly property string scriptsDir: Quickshell.shellDir + "/scripts"
    readonly property string statePath: (Quickshell.env("XDG_STATE_HOME") || (Quickshell.env("HOME") + "/.local/state")) + "/poe-leveling/state.json"

    readonly property var targetScreen: {
        const screens = Quickshell.screens;
        for (let i = 0; i < screens.length; i++)
            if (screens[i].name === screenName)
                return screens[i];
        return screens.length > 0 ? screens[0] : null;
    }
}
