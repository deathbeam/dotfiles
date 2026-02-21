import QtQuick
import Quickshell
import Quickshell.Io

Text {
    id: root

    property int utilization: 0
    property int temperature: 0

    text: Config.iconCpu + " " + utilization + "%|" + temperature + "°C"
    color: (utilization >= 80 || temperature >= 80) ? Config.colorUrgent : (utilization >= 65 || temperature >= 65) ? Config.colorWarning : Config.colorFg
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    leftPadding: Config.margin
    rightPadding: Config.margin

    Process {
        id: cpuProc

        command: ["sh", "-c", "top -bn2 | grep 'Cpu(s)' | tail -n1 | awk '{print 100 - $8}' | cut -d. -f1"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                return root.utilization = parseInt(data.trim());
            }
        }
    }

    Process {
        id: tempProc

        command: ["sh", "-c", "sensors | awk '/Package id 0:/ {print int($4)}' | tr -d '+°C'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                return root.temperature = parseInt(data.trim());
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true;
            tempProc.running = true;
        }
    }
}
