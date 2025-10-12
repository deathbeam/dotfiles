import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property int utilization: -1
    property int temperature: -1

    text: Theme.iconGpu + " " + utilization + "%|" + temperature + "°C"
    color: (utilization >= 80 || temperature >= 80) ? Theme.colorUrgent :
           (utilization >= 65 || temperature >= 65) ? Theme.colorWarning : Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.margin
    rightPadding: Theme.margin

    Process {
        id: gpuProc
        command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo '-1,-1'"]
        running: false
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(',')
                if (parts.length === 2) {
                    root.utilization = parseInt(parts[0].trim())
                    root.temperature = parseInt(parts[1].trim())
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: gpuProc.running = true
    }
}
