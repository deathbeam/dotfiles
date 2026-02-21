import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

Rectangle {
    property string currentSubmap: "default"

    Layout.preferredWidth: submapText.visible ? submapText.implicitWidth + Config.margin * 2 : 0
    Layout.fillHeight: true
    visible: submapText.text !== ""
    color: Config.colorInactive

    Process {
        id: submapProcess

        command: ["sh", "-c", "hyprctl -j submap | sed 's/[{}\"]//g'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                let trimmed = data.trim();
                if (trimmed !== "")
                    currentSubmap = trimmed;
            }
        }
    }

    Timer {
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: submapProcess.running = true
    }

    Text {
        id: submapText

        anchors.centerIn: parent
        text: currentSubmap !== "default" ? "-- " + currentSubmap.toUpperCase() + " --" : ""
        color: Config.colorSuccess
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
        font.bold: true
    }
}
