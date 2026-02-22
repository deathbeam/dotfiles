import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property int brightness: 0

    implicitWidth: barWidget.implicitWidth
    implicitHeight: barWidget.implicitHeight

    BarWidget {
        id: barWidget
        icon: Config.iconBrightness
        text: brightness + "%"
        status: brightness < 30 ? BarWidget.Warning : BarWidget.Normal
    }

    Process {
        id: brightProc

        command: ["sh", "-c", "brightnessctl -m | awk -F, '{print $4}' | tr -d '%'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                return root.brightness = parseInt(data.trim());
            }
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
