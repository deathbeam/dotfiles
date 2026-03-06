import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string zoneName: "Waiting for game..."
    property int level: 0
    property int act: 0
    property string recommendation: ""

    implicitWidth: layout.implicitWidth

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: 2

        Text {
            text: zoneName
            color: Config.colorHighlight
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize + 3
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: 6
            visible: act > 0 || level > 0

            Text {
                text: act > 0 ? "Act " + act : ""
                color: Config.colorFgDim
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize - 1
                visible: act > 0
            }

            Text {
                text: "•"
                color: Config.colorFgDim
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize - 1
                visible: act > 0 && level > 0
            }

            Text {
                text: "Lv " + level
                color: Config.colorFg
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize - 1
                visible: level > 0
            }
        }
    }
}
