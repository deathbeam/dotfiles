import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int capacity: 100

    implicitWidth: barWidget.implicitWidth
    implicitHeight: barWidget.implicitHeight

    BarWidget {
        id: barWidget
        icon: Config.iconBattery
        text: capacity + "%"
        status: capacity <= 10 ? BarWidget.Danger : capacity <= 30 ? BarWidget.Warning : BarWidget.Normal
    }

    Process {
        id: batProc

        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 100"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                return root.capacity = parseInt(data.trim());
            }
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
