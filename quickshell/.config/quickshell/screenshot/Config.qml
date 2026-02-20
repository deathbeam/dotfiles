pragma Singleton
import Quickshell
import QtQuick

QtObject {
    // Screenshot output directory
    readonly property string screenshotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"

    // Font Awesome icons
    readonly property string iconRegion: "󰩬"  // Region/area selection
    readonly property string iconWindow: ""  // Window
    readonly property string iconScreen: "󰍹"  // Monitor/screen
    readonly property string fontFamily: "monospace"
    readonly property int iconSize: 24
}
