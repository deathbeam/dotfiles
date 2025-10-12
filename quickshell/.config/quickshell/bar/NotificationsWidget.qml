import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 0

    property int officialUpdates: 0
    property int aurUpdates: 0
    property int github: 0

    Text {
        visible: (root.officialUpdates + root.aurUpdates) > 0
        text: Theme.iconPackages + " " + (root.officialUpdates + root.aurUpdates)
        color: Theme.colorUrgent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        leftPadding: Theme.margin
        rightPadding: Theme.margin
    }

    Text {
        visible: root.github > 0
        text: Theme.iconGithub + " " + root.github
        color: Theme.colorActive
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        leftPadding: Theme.margin
        rightPadding: Theme.margin
    }

    Process {
        id: officialProc
        command: ["sh", "-c", "checkupdates 2>/dev/null | wc -l"]
        running: false
        stdout: SplitParser {
            onRead: data => root.officialUpdates = parseInt(data.trim())
        }
    }

    Process {
        id: aurProc
        command: ["sh", "-c", "yay -Qum 2>/dev/null | wc -l"]
        running: false
        stdout: SplitParser {
            onRead: data => root.aurUpdates = parseInt(data.trim())
        }
    }

    Process {
        id: ghProc
        command: ["gh", "api", "notifications", "--jq", "length"]
        running: false
        stdout: SplitParser {
            onRead: data => root.github = parseInt(data.trim())
        }
    }

    Timer {
        interval: 600000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            officialProc.running = true
            aurProc.running = true
            ghProc.running = true
        }
    }
}
