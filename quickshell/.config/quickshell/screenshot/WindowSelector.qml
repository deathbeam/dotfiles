import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    property var monitor: Hyprland.focusedMonitor
    property var workspace: monitor?.activeWorkspace
    property var windows: workspace?.toplevels ?? []

    signal checkHover(real mouseX, real mouseY)
    signal regionSelected(real x, real y, real width, real height)

    property point startPos
    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0

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

    Repeater {
        model: root.windows

        Item {
            required property var modelData

            Connections {
                target: root

                function onCheckHover(mouseX, mouseY) {
                    const monitorX = root.monitor.lastIpcObject.x;
                    const monitorY = root.monitor.lastIpcObject.y;

                    const windowX = modelData.lastIpcObject.at[0] - monitorX;
                    const windowY = modelData.lastIpcObject.at[1] - monitorY;

                    const width = modelData.lastIpcObject.size[0];
                    const height = modelData.lastIpcObject.size[1];

                    if (mouseX >= windowX && mouseX <= windowX + width && mouseY >= windowY && mouseY <= windowY + height) {
                        selectionX = windowX;
                        selectionY = windowY;
                        selectionWidth = width;
                        selectionHeight = height;
                    }
                }
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        z: 3
        hoverEnabled: true

        onPositionChanged: mouse => {
            root.checkHover(mouse.x, mouse.y);
        }

        onReleased: mouse => {
            if (mouse.x >= root.selectionX && mouse.x <= root.selectionX + root.selectionWidth && mouse.y >= root.selectionY && mouse.y <= root.selectionY + root.selectionHeight) {
                root.regionSelected(Math.round(root.selectionX), Math.round(root.selectionY), Math.round(root.selectionWidth), Math.round(root.selectionHeight));
            }
        }
    }
}
