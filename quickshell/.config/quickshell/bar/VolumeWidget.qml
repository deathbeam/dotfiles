import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string mixer: "Master"
    property bool isMic: false
    property int percent: 0
    property bool muted: false

    implicitWidth: barWidget.implicitWidth
    implicitHeight: barWidget.implicitHeight

    BarWidget {
        id: barWidget
        icon: muted ? (isMic ? Config.iconMicMuted : Config.iconVolumeMuted) : (isMic ? Config.iconMic : Config.iconVolume)
        text: percent + "%"
        status: muted ? BarWidget.Danger : percent < 30 ? BarWidget.Warning : BarWidget.Normal
    }

    Process {
        id: volProc

        command: ["sh", "-c", "amixer -c PCH get " + root.mixer + " | grep -oP '\\[\\d+%\\]' | head -n1 | tr -d '[]%'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                return root.percent = parseInt(data.trim());
            }
        }
    }

    Process {
        id: muteProc

        command: ["sh", "-c", "amixer -c PCH get " + root.mixer + " | grep -oP '\\[(on|off)\\]' | head -n1"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                return root.muted = data.trim() === "[off]";
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            volProc.running = true;
            muteProc.running = true;
        }
    }
}
