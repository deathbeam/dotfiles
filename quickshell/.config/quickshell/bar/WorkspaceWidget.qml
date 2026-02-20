import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Rectangle {
    Layout.preferredWidth: workspaceText.visible ? workspaceText.implicitWidth + Config.margin * 2 : 0
    Layout.fillHeight: true
    visible: Hyprland.focusedWorkspace !== null
    color: Config.colorInactive

    Text {
        id: workspaceText
        anchors.centerIn: parent
        text: {
            if (Hyprland.focusedWorkspace === null) return "";
            let ws = Hyprland.focusedWorkspace;
            // Use name if it's a named workspace, otherwise use id
            return ws.name !== "" ? ws.name : ws.id.toString();
        }
        color: Config.colorFg
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
    }
}
