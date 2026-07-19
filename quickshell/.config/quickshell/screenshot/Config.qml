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
    // Kept low: under *sustained* GPU load retries just stall, so fail fast.
    readonly property int maxGrimRetries: 2

    // Seconds before a single grim capture is killed as hung. Short, so a
    // stalled compositor fails fast instead of looking frozen.
    readonly property int grimTimeoutSec: 3

    // Hard upper bound on the whole capture phase. If exceeded (trigger never
    // fired, grim hung, retry logic wedged) the watchdog force-kills grim and
    // quits, so the -n (--no-duplicate) instance can never get stuck and block
    // the next screenshot.
    readonly property int watchdogSec: 15
}
