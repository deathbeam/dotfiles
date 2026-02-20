import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property int brightness: 0
    
    text: Config.iconBrightness + " " + brightness + "%"
    color: Config.colorFg
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    leftPadding: Config.margin
    rightPadding: Config.margin
    
    Process {
        id: brightProc
        command: ["sh", "-c", "brightnessctl -m | awk -F, '{print $4}' | tr -d '%'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.brightness = parseInt(data.trim())
        }
    }
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: brightProc.running = true
    }
}
