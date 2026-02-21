import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Text {
    text: {
        if (Hyprland.focusedWorkspace === null) return "";
        let ws = Hyprland.focusedWorkspace;
        // Use name if it's a named workspace, otherwise use id with icon
        if (ws.name !== "") {
            return ws.name;
        } else {
            return " " + ws.id.toString();
        }
    }
    color: Config.colorFg
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    leftPadding: Config.margin
    rightPadding: Config.margin
}
