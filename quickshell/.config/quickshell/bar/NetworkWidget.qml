import Quickshell
import Quickshell.Io
import QtQuick

Text {
    id: root
    property string netInterface: ""
    property string ssid: ""
    property string ipv4: ""
    property bool isWlan: false

    text: isWlan ? Theme.iconNetwork + " " + ssid : Theme.iconNetworkWired + " " + ipv4
    color: Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.margin
    rightPadding: Theme.margin

    Process {
        id: ifaceProc
        command: ["sh", "-c", "ip -j addr show | jq -r '.[] | select(.operstate == \"UP\" and .ifname != \"lo\") | .ifname' | head -n1"]
        running: false
        stdout: SplitParser {
            onRead: (data) => {
                var iface = data.trim()
                if (!iface) return

                root.netInterface = iface
                root.isWlan = iface.startsWith("wl")

                if (root.isWlan) {
                    ipProc.running = false
                    ssidProc.running = true
                } else {
                    ipProc.running = true
                    ssidProc.running = false
                }
            }
        }
    }

    Process {
        id: ssidProc
        command: ["sh", "-c", "iw dev " + root.netInterface + " link | grep 'SSID:' | awk '{print $2}'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.ssid = data.trim()
        }
    }

    Process {
        id: ipProc
        command: ["sh", "-c", "ip -4 addr show " + root.netInterface + " | grep -oP '(?<=inet\\s)\\d+(\\.\\d+){3}'"]
        running: false
        stdout: SplitParser {
            onRead: data => root.ipv4 = data.trim()
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: ifaceProc.running = true
    }
}
