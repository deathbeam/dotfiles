import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property string mixer: "Master"
    property bool isMic: false
    property int percent: 0
    property bool muted: false
    
    text: muted ? (isMic ? Config.iconMicMuted : Config.iconVolumeMuted) : (isMic ? Config.iconMic + " " + percent + "%" : Config.iconVolume + " " + percent + "%")
    color: muted ? Config.colorUrgent : Config.colorFg
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    leftPadding: Config.margin
    rightPadding: Config.margin
    
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
