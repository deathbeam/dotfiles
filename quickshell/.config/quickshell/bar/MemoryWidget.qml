import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property real percentUsed: 0
    
    text: Theme.iconMemory + " " + Math.round(percentUsed) + "%"
    color: percentUsed >= 80 ? Theme.colorUrgent : percentUsed >= 65 ? Theme.colorWarning : Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.margin
    rightPadding: Theme.margin
    
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem | awk '{print ($3/$2) * 100.0}'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.percentUsed = parseFloat(data.trim())
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memProc.running = true
    }
}
