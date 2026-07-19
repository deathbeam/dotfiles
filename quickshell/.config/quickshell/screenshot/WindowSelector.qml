import QtQuick
import Quickshell.Hyprland

Item {
    id: root

    property var monitor: Hyprland.focusedMonitor
    property var workspace: monitor?.activeWorkspace
    // `toplevels` is an ObjectModel, not a JS array. Indexing it directly
    // (model.length, model[i]) returns undefined and silently breaks hit
    // testing. Use `.values` to read it as a real QML list.
    property var windows: workspace?.toplevels.values ?? []
    property var hoveredWindow: null

    signal windowSelected(string address)

    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0

    // Make sure window geometry is current before we try to read it.
    // `lastIpcObject` (which holds `at`/`size`) is not reactively updated
    // unless the toplevel list is refreshed.
    Component.onCompleted: Hyprland.refreshToplevels()

    function windowGeometry(toplevel) {
        const win = toplevel.lastIpcObject;
        const mon = root.monitor;
        return {
            "x": (win.at[0] ?? 0) - (mon.x ?? 0),
            "y": (win.at[1] ?? 0) - (mon.y ?? 0),
            "width": win.size[0] ?? 0,
            "height": win.size[1] ?? 0
        };
    }

    function highlightAt(mouseX, mouseY) {
        // Pick the smallest window containing the cursor: nested/overlapping
        // windows resolve to the innermost one.
        let best = null;
        let bestArea = Infinity;
        for (let i = 0; i < root.windows.length; i++) {
            const g = windowGeometry(root.windows[i]);
            if (mouseX >= g.x && mouseX <= g.x + g.width && mouseY >= g.y && mouseY <= g.y + g.height) {
                const area = g.width * g.height;
                if (area < bestArea) {
                    bestArea = area;
                    best = root.windows[i];
                }
            }
        }
        root.hoveredWindow = best;
        if (best) {
            const g = windowGeometry(best);
            root.selectionX = g.x;
            root.selectionY = g.y;
            root.selectionWidth = g.width;
            root.selectionHeight = g.height;
        } else {
            root.selectionWidth = 0;
            root.selectionHeight = 0;
        }
    }

    function selectHovered() {
        if (root.hoveredWindow && root.hoveredWindow.address.length > 0)
            root.windowSelected(root.hoveredWindow.address);
    }

    // Cycle keyboard focus through windows (Tab / Shift-Tab), Enter to select.
    function cycle(direction) {
        if (root.windows.length === 0)
            return;
        let idx = root.windows.indexOf(root.hoveredWindow);
        if (idx === -1)
            idx = direction > 0 ? -1 : 0;
        idx = (idx + direction + root.windows.length) % root.windows.length;
        root.hoveredWindow = root.windows[idx];
        const g = windowGeometry(root.hoveredWindow);
        root.selectionX = g.x;
        root.selectionY = g.y;
        root.selectionWidth = g.width;
        root.selectionHeight = g.height;
    }

    // Selection rectangle outline
    Rectangle {
        x: root.selectionX
        y: root.selectionY
        width: root.selectionWidth
        height: root.selectionHeight
        color: Qt.rgba(0.3, 0.5, 0.9, 0.15)
        border.color: "#4aa3ff"
        border.width: 2
        visible: root.selectionWidth > 0 && root.selectionHeight > 0

        Behavior on x {
            NumberAnimation {
                duration: 60
            }
        }
        Behavior on y {
            NumberAnimation {
                duration: 60
            }
        }
        Behavior on width {
            NumberAnimation {
                duration: 60
            }
        }
        Behavior on height {
            NumberAnimation {
                duration: 60
            }
        }
    }

    // Window title label floating above the highlighted window.
    Rectangle {
        visible: root.hoveredWindow !== null && root.selectionWidth > 0
        x: root.selectionX
        y: Math.max(0, root.selectionY - 28)
        width: Math.min(titleLabel.implicitWidth + 16, root.width - root.selectionX)
        height: titleLabel.implicitHeight + 8
        color: Qt.rgba(0.1, 0.1, 0.1, 0.85)
        radius: 6
        border.color: "#4aa3ff"
        border.width: 1

        Text {
            id: titleLabel

            anchors.centerIn: parent
            text: root.hoveredWindow ? root.hoveredWindow.title : ""
            color: "white"
            font.pixelSize: 13
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent
        z: 3
        hoverEnabled: true

        onPositionChanged: mouse => {
            root.highlightAt(mouse.x, mouse.y);
        }
        onReleased: mouse => {
            root.selectHovered();
        }
    }
}
