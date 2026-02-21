import QtQuick

Item {
    id: root

    property point startPos
    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0

    signal regionSelected(real x, real y, real width, real height)

    // Selection rectangle outline
    Rectangle {
        x: root.selectionX
        y: root.selectionY
        width: root.selectionWidth
        height: root.selectionHeight
        color: "transparent"
        border.color: "white"
        border.width: 2
        visible: root.selectionWidth > 0 && root.selectionHeight > 0
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        z: 3
        onPressed: mouse => {
            root.startPos = Qt.point(mouse.x, mouse.y);
            root.selectionX = mouse.x;
            root.selectionY = mouse.y;
            root.selectionWidth = 0;
            root.selectionHeight = 0;
        }
        onPositionChanged: mouse => {
            if (pressed) {
                const x = Math.min(root.startPos.x, mouse.x);
                const y = Math.min(root.startPos.y, mouse.y);
                const width = Math.abs(mouse.x - root.startPos.x);
                const height = Math.abs(mouse.y - root.startPos.y);
                root.selectionX = x;
                root.selectionY = y;
                root.selectionWidth = width;
                root.selectionHeight = height;
            }
        }
        onReleased: {
            root.regionSelected(Math.round(root.selectionX), Math.round(root.selectionY), Math.round(root.selectionWidth), Math.round(root.selectionHeight));
        }
    }
}
