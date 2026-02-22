import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property real percentUsed: 0

    implicitWidth: barWidget.implicitWidth
    implicitHeight: barWidget.implicitHeight

    BarWidget {
        id: barWidget
        icon: Config.iconMemory
        text: Math.round(percentUsed) + "%"
        status: percentUsed >= 80 ? BarWidget.Danger : percentUsed >= 65 ? BarWidget.Warning : BarWidget.Normal
    }

    Process {
        id: memProc

        command: ["sh", "-c", "free | grep Mem | awk '{print ($3/$2) * 100.0}'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                return root.percentUsed = parseFloat(data.trim());
            }
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
