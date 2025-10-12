import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property int brightness: 0
    
    text: Theme.iconBrightness + " " + brightness + "%"
    color: Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.margin
    rightPadding: Theme.margin
    
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
