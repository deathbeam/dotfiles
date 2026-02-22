import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool hidden: false
    property int brightness: 0
    property int brightnessPercent: Math.round(((brightness + 64) / 128) * 100)

    implicitWidth: barWidget.implicitWidth
    implicitHeight: barWidget.implicitHeight

    BarWidget {
        id: barWidget
        icon: hidden ? Config.iconCameraMuted : Config.iconCameraActive
        text: brightnessPercent + "%"
        status: hidden ? BarWidget.Danger : brightnessPercent < 30 ? BarWidget.Warning : BarWidget.Normal
    }

    Process {
        id: brightnessProc

        command: ["sh", "-c", "v4l2-ctl --get-ctrl=brightness | awk '{print $2}'"]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.brightness = parseInt(data.trim());
                root.hidden = root.brightness === -64;
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            brightnessProc.running = true;
        }
    }
}
