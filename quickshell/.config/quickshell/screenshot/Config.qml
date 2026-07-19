pragma Singleton
import QtQuick
import Quickshell

QtObject {
    // Screenshot output directory
    readonly property string screenshotDir: Quickshell.env("HOME") + "/Pictures/Screenshots"

    // Font Awesome icons
    readonly property string iconRegion: "󰩬" // Region/area selection
    readonly property string iconWindow: "" // Window
    readonly property string iconScreen: "󰍹" // Monitor/screen
    readonly property string fontFamily: "monospace"
    readonly property int iconSize: 24

    // Max retries for a transient grim failure (GPU/compositor busy).
    readonly property int maxGrimRetries: 3

    // Seconds before a grim capture is killed as hung.
    readonly property int grimTimeoutSec: 10
}
