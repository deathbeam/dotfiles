import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 0

    // Available width for the title section (calculated dynamically)
    property real availableWidth: 500

    // Use Wayland toplevel for standard properties (title, appId, etc)
    property var activeWindow: ToplevelManager.activeToplevel
    // Use Hyprland toplevel for Hyprland-specific properties (xwayland, etc)
    property var hyprlandToplevel: Hyprland.activeToplevel
    property bool isXWayland: hyprlandToplevel?.lastIpcObject?.xwayland ?? false
    property bool isFloating: hyprlandToplevel?.lastIpcObject?.floating ?? false

    // Refresh Hyprland toplevels to update lastIpcObject
    Timer {
        interval: 100
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: Hyprland.refreshToplevels()
    }

    Rectangle {
        Layout.preferredWidth: modeText.visible ? modeText.implicitWidth + Config.margin * 2 : 0
        Layout.fillHeight: true
        visible: activeWindow
        color: Config.colorActive

        Text {
            id: modeText
            anchors.centerIn: parent
            text: isFloating ? Config.iconFloating : activeWindow.fullScreen ? Config.iconFullscreen : activeWindow.minimized ? Config.iconMinimized : activeWindow.maximized ? Config.iconMaximized : Config.iconTiled
            color: Config.colorFgInv
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
        }
    }

    Rectangle {
        Layout.preferredWidth: classText.visible ? classText.implicitWidth + Config.margin * 2 : 0
        Layout.fillHeight: true
        visible: (activeWindow?.appId ?? "") !== ""
        color: isXWayland ? Config.colorWarning : Config.colorInactive

        Text {
            id: classText
            anchors.centerIn: parent
            text: {
                let id = activeWindow.appId;
                let idx = id.lastIndexOf(".");
                return idx !== -1 ? id.substring(idx + 1) : id;
            }
            color: isXWayland ? Config.colorFgInv : Config.colorFg
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
        }
    }

    Rectangle {
        Layout.preferredWidth: {
            let textWidth = titleText.implicitWidth + Config.margin * 2;
            let modeWidth = modeText.visible ? modeText.implicitWidth + Config.margin * 2 : 0;
            let classWidth = classText.visible ? classText.implicitWidth + Config.margin * 2 : 0;
            let usedWidth = modeWidth + classWidth;
            let maxWidth = Math.max(availableWidth - usedWidth - Config.margin * 4, 100);
            return Math.min(textWidth, maxWidth);
        }
        Layout.fillHeight: true
        visible: (activeWindow?.title ?? "") !== ""
        color: "transparent"

        Text {
            id: titleText
            anchors.fill: parent
            anchors.leftMargin: Config.margin
            anchors.rightMargin: Config.margin
            verticalAlignment: Text.AlignVCenter
            text: activeWindow.title
            color: Config.colorFg
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
            elide: Text.ElideRight
        }
    }
}
