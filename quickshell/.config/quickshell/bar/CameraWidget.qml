import QtQuick
import Quickshell
import Quickshell.Io

Text {
    id: root

    property bool hidden: false
    property int brightness: 0
    property int brightnessPercent: Math.round(((brightness + 64) / 128) * 100)

    text: hidden ? Config.iconCameraMuted : Config.iconCameraActive + " " + brightnessPercent + "%"
    color: hidden ? Config.colorUrgent : Config.colorFg
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    leftPadding: Config.margin
    rightPadding: Config.margin

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
