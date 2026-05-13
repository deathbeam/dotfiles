import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property var targetScreen: Quickshell.screens[0]
    property string sourcePath: ""
    property alias contentItem: root.contentItem

    screen: targetScreen
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        left: true
        right: true
        top: true
        bottom: true
    }
    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    Image {
        id: frozenImage
        source: root.sourcePath
        anchors.fill: parent
        fillMode: Image.Stretch
        visible: root.sourcePath !== ""
    }
}
