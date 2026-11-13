import QtQuick

Item {
    id: root

    property var hints: []

    readonly property int maxWidth: Math.round(width * 0.55)
    readonly property int maxHeight: Math.round(height * 0.3)

    Column {
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: root.hints.slice(0, 3)

            delegate: Image {
                required property var modelData

                source: modelData
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                sourceSize.width: root.maxWidth
                width: Math.min(implicitWidth, root.maxWidth)
                height: Math.min(implicitHeight, root.maxHeight)
            }
        }
    }
}
