import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

RowLayout {
    spacing: 0

    property var activeWindow: ToplevelManager.activeToplevel

    Rectangle {
        Layout.preferredWidth: modeText.visible ? modeText.implicitWidth + Theme.margin * 2 : 0
        Layout.fillHeight: true
        visible: activeWindow
        color: Theme.colorActive

        Text {
            id: modeText
            anchors.centerIn: parent
            text: activeWindow.fullScreen ? Theme.iconFullscreen :
                  activeWindow.minimized ? Theme.iconMinimized :
                  activeWindow.maximized ? Theme.iconMaximized :
                  Theme.iconTiled
            color: Theme.colorFgInv
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    Rectangle {
        Layout.preferredWidth: classText.visible ? classText.implicitWidth + Theme.margin * 2 : 0
        Layout.fillHeight: true
        visible: (activeWindow?.appId ?? "") !== ""
        color: Theme.colorInactive

        Text {
            id: classText
            anchors.centerIn: parent
            text: {
                let id = activeWindow.appId;
                let idx = id.lastIndexOf(".");
                return idx !== -1 ? id.substring(idx + 1) : id;
            }
            color: Theme.colorFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    Rectangle {
        Layout.preferredWidth: Math.min(titleText.implicitWidth + Theme.margin * 2, 600)
        Layout.fillHeight: true
        visible: (activeWindow?.title ?? "") !== ""
        color: "transparent"

        Text {
            id: titleText
            anchors.fill: parent
            anchors.leftMargin: Theme.margin
            anchors.rightMargin: Theme.margin
            verticalAlignment: Text.AlignVCenter
            text: activeWindow.title
            color: Theme.colorFg
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            elide: Text.ElideRight
        }
    }
}
