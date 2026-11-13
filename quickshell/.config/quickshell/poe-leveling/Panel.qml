import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property var state: ({})
    property string timerText: ""
    property string actTimerText: ""

    readonly property var steps: state.lines ?? []
    readonly property var nextSteps: state.next_lines ?? []
    readonly property bool hasHints: (state.hints ?? []).length > 0
    readonly property bool ready: (state.zone_name ?? "") !== ""

    readonly property string headerText: {
        if (!root.ready)
            return "PoE leveling · waiting for the game log";
        const parts = [];
        if (root.state.act)
            parts.push("Act " + root.state.act);
        parts.push(root.state.zone_name);
        if (root.state.area_level)
            parts.push("lvl " + root.state.area_level);
        if (root.state.char_level)
            parts.push("char " + root.state.char_level);
        return parts.join(" · ");
    }

    readonly property string pageText: root.ready ? (root.state.page + 1) + "/" + root.state.pages : ""

    implicitHeight: card.height

    Rectangle {
        id: card

        width: root.width
        height: content.implicitHeight + Config.padding * 2
        radius: Config.radius
        color: Qt.rgba(Config.background.r, Config.background.g, Config.background.b, Config.opacity)
        border.width: 1
        border.color: Config.border

        ColumnLayout {
            id: content

            x: Config.padding
            y: Config.padding
            width: parent.width - Config.padding * 2
            spacing: Config.spacing

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: root.headerText
                    color: Config.accent
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    text: root.state.xp ?? ""
                    color: root.state.xp_color ?? Config.foregroundDim
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                }

                Text {
                    text: root.timerText
                    color: Config.foregroundDim
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                }

                Text {
                    text: root.actTimerText
                    color: Config.foregroundDim
                    opacity: 0.7
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize - 2
                }

                Text {
                    text: root.pageText
                    color: Config.foregroundDim
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize - 2
                }

                Text {
                    visible: root.hasHints
                    text: "◧"
                    color: Config.accent
                    font.family: Config.fontFamily
                    font.pixelSize: Config.fontSize
                }
            }

            Repeater {
                model: root.steps

                delegate: Text {
                    required property var modelData

                    Layout.fillWidth: true
                    text: modelData.html
                    textFormat: Text.RichText
                    wrapMode: Text.Wrap
                    color: Config.foreground
                    font.family: Config.fontFamily
                    font.pixelSize: modelData.hint ? Config.fontSize - 2 : Config.fontSize
                    leftPadding: modelData.hint ? Config.fontSize : 0
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.ready && root.steps.length === 0
                text: "no steps on this page"
                color: Config.foregroundDim
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize
                font.italic: true
            }

            Text {
                Layout.fillWidth: true
                visible: (root.state.recipe ?? "") !== ""
                text: "craft: " + (root.state.recipe ?? "")
                color: Config.accent
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize - 2
            }

            Text {
                Layout.fillWidth: true
                visible: root.nextSteps.length > 0
                text: "next: " + (root.nextSteps[0] ?? "")
                textFormat: Text.RichText
                color: Config.foregroundDim
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize - 3
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }
    }
}
