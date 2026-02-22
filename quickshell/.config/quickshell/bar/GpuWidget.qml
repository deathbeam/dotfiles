import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int utilization: -1
    property int temperature: -1

    visible: utilization >= 0 && temperature >= 0
    implicitWidth: barWidget.implicitWidth
    implicitHeight: barWidget.implicitHeight

    BarWidget {
        id: barWidget
        icon: Config.iconGpu
        text: utilization + "%|" + temperature + "°C"
        status: (utilization >= 80 || temperature >= 80) ? BarWidget.Danger : (utilization >= 65 || temperature >= 65) ? BarWidget.Warning : BarWidget.Normal
    }

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
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: gpuProc.running = true
    }
}
