import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData
            screen: modelData
            anchors {
                top: true
                left: true
                right: true
            }

            implicitHeight: Config.barHeight

            color: Config.colorBg

            // Left side
            RowLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

                SubmapWidget {}
                WorkspaceWidget {}
                TopLevelWidget {}
            }

            // Right side
            RowLayout {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

                NetworkWidget {}
                MemoryWidget {}
                CpuWidget {}
                GpuWidget {}
                VolumeWidget { mixer: "Master" }
                VolumeWidget { mixer: "Capture"; isMic: true }
                CameraWidget {}
                BrightnessWidget {}
                BatteryWidget {}
                ClockWidget {}
                NotificationsWidget {}
                TrayWidget {}
            }
        }
    }
}
