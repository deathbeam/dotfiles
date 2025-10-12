import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property int capacity: 100
    
    text: Theme.iconBattery + " " + capacity + "%"
    color: capacity <= 10 ? Theme.colorUrgent : capacity <= 30 ? Theme.colorWarning : Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.margin
    rightPadding: Theme.margin
    
    Process {
        id: batProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100"]
        running: false
        stdout: SplitParser {
            onRead: data => root.capacity = parseInt(data.trim())
        }
    }
    
    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batProc.running = true
    }
}
