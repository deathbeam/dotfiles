import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property int utilization: 0
    property int temperature: 0
    
    text: Theme.iconCpu + " " + utilization + "%|" + temperature + "°C"
    color: (utilization >= 80 || temperature >= 80) ? Theme.colorUrgent : 
           (utilization >= 65 || temperature >= 65) ? Theme.colorWarning : Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.margin
    rightPadding: Theme.margin
    
    Process {
        id: cpuProc
        command: ["sh", "-c", "top -bn2 | grep 'Cpu(s)' | tail -n1 | awk '{print 100 - $8}' | cut -d. -f1"]
        running: false
        stdout: SplitParser {
            onRead: data => root.utilization = parseInt(data.trim())
        }
    }
    
    Process {
        id: tempProc
        command: ["sh", "-c", "sensors | awk '/Package id 0:/ {print int($4)}' | tr -d '+°C'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.temperature = parseInt(data.trim())
        }
    }
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true
            tempProc.running = true
        }
    }
}
