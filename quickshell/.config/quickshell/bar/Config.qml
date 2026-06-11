pragma Singleton
import QtQuick
import Quickshell

QtObject {
    // Colors from yambar config
    readonly property string colorBg: "#002B36"
    readonly property string colorFg: "#93A1A1"
    readonly property string colorFgInv: "#002B36"
    readonly property string colorSuccess: "#859900"
    readonly property string colorActive: "#268BD2"
    readonly property string colorInactive: "#073642"
    readonly property string colorUrgent: "#CB4B16"
    readonly property string colorWarning: "#B58900"
    // Spacing
    readonly property int margin: 8
    // Font and bar settings
    readonly property string fontFamily: "monospace"
    readonly property int fontSize: Number(Quickshell.env("BAR_FONT_SIZE") || 12)
    readonly property int barHeight: Number(Quickshell.env("BAR_HEIGHT") || 30)
    // Icons
    readonly property string iconNetwork: " "
    readonly property string iconNetworkWired: " "
    readonly property string iconMemory: " "
    readonly property string iconCpu: " "
    readonly property string iconGpu: " "
    readonly property string iconVolume: " "
    readonly property string iconVolumeMuted: ""
    readonly property string iconMic: ""
    readonly property string iconMicMuted: " "
    readonly property string iconCameraActive: " "
    readonly property string iconCameraMuted: " "
    readonly property string iconBrightness: ""
    readonly property string iconBattery: " "
    readonly property string iconClock: " "
    readonly property string iconPackages: " "
    readonly property string iconGithub: " "
    readonly property string iconFullscreen: " "
    readonly property string iconMinimized: " "
    readonly property string iconMaximized: " "
    readonly property string iconFloating: " "
    readonly property string iconTiled: " "
}
