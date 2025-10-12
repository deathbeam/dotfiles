import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property string mixer: "Master"
    property bool isMic: false
    property int percent: 0
    property bool muted: false
    
    text: muted ? (isMic ? Theme.iconMicMuted : Theme.iconVolumeMuted) : (isMic ? Theme.iconMic + " " + percent + "%" : Theme.iconVolume + " " + percent + "%")
    color: muted ? Theme.colorUrgent : Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.margin
    rightPadding: Theme.margin
    
    Process {
        id: volProc
        command: ["sh", "-c", "amixer -c PCH get " + root.mixer + " | grep -oP '\\[\\d+%\\]' | head -n1 | tr -d '[]%'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.percent = parseInt(data.trim())
        }
    }
    
    Process {
        id: muteProc
        command: ["sh", "-c", "amixer -c PCH get " + root.mixer + " | grep -oP '\\[(on|off)\\]' | head -n1"]
        running: false
        stdout: SplitParser {
            onRead: data => root.muted = data.trim() === "[off]"
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            volProc.running = true
            muteProc.running = true
        }
    }
}
