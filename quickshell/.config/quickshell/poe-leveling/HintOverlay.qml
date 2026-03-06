import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property var hints: []

    color: Qt.rgba(0, 0.17, 0.21, 0.4)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Config.margin
        spacing: 16

        Text {
            text: "Layout Hints"
            color: Config.colorHighlight
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize + 2
            font.bold: true
            Layout.fillWidth: true
        }

        Repeater {
            model: hints

            delegate: Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 400

                Image {
                    anchors.centerIn: parent
                    source: Config.hintsDir + "/" + modelData
                    fillMode: Image.PreserveAspectFit
                    width: Math.min(parent.width - 20, 600)
                    height: Math.min(parent.height - 20, 400)
                    asynchronous: true

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        border.color: Config.colorFgDim
                        border.width: 1
                        opacity: 0.5
                    }
                }
            }
        }

        Text {
            text: "No hints for this zone"
            color: Config.colorFgDim
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
            font.italic: true
            horizontalAlignment: Text.AlignHCenter
            visible: hints.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
