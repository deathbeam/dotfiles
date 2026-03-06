pragma Singleton
import QtQuick
import Quickshell

QtObject {
    readonly property string colorBg: "#002B36"
    readonly property string colorFg: "#EEE8D5"
    readonly property string colorFgDim: "#93A1A1"
    readonly property string colorHighlight: "#2AA198"
    readonly property string colorQuest: "#DC322F"
    readonly property string colorOptional: "#859900"
    readonly property string colorWarning: "#B58900"

    readonly property int panelHeight: 150
    readonly property int panelWidth: 1000
    readonly property real opacity: 0.85
    readonly property int fontSize: 13
    readonly property string fontFamily: "monospace"
    readonly property int margin: 16
    readonly property int spacing: 20

    readonly property string configDir: Quickshell.env("HOME") + "/.config/quickshell/poe-leveling"
    readonly property string logPath: Quickshell.env("HOME") + "/.local/share/Steam/steamapps/common/Path of Exile/logs/LatestClient.txt"
    readonly property string dataDir: configDir + "/data"
    readonly property string scriptsDir: configDir + "/scripts"
    readonly property string hintsDir: dataDir + "/hints"

    readonly property int linesPerPage: 5
}
