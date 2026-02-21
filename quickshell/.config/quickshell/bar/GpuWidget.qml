import QtQuick
import Quickshell
import Quickshell.Io

Text {
    id: root

    property int utilization: -1
    property int temperature: -1

    visible: utilization >= 0 && temperature >= 0
    text: Config.iconGpu + " " + utilization + "%|" + temperature + "°C"
    color: (utilization >= 80 || temperature >= 80) ? Config.colorUrgent : (utilization >= 65 || temperature >= 65) ? Config.colorWarning : Config.colorFg
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    leftPadding: Config.margin
    rightPadding: Config.margin

    Process {
        id: gpuProc

        command: ["sh", "-c", "nvidia-smi --query-gpu=utilization.gpu,temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo '-1,-1'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(',');
                if (parts.length === 2) {
                    root.utilization = parseInt(parts[0].trim());
                    root.temperature = parseInt(parts[1].trim());
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
