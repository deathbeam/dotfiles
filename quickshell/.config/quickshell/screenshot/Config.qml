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

    // Low on purpose: under sustained GPU load retries just stall, so fail fast.
    readonly property int maxGrimRetries: 2
    readonly property int grimTimeoutSec: 3
    // Hard upper bound on the whole capture phase. The watchdog force-kills
    // grim and quits if exceeded, so the -n instance can never get stuck.
    readonly property int watchdogSec: 15
}
