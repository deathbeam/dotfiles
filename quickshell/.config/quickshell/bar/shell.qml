import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            property var modelData

            screen: modelData
            implicitHeight: Config.barHeight
            color: Config.colorBg

            anchors {
                top: true
                left: true
                right: true
            }

            // Left side
            RowLayout {
                id: leftSide
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

                SubmapWidget {
                    id: submapWidget
                }

                WorkspaceWidget {
                    id: workspaceWidget
                }

                TopLevelWidget {
                    availableWidth: parent.parent.width - submapWidget.width - workspaceWidget.width - rightSide.width
                }
            }

            // Right side
            RowLayout {
                id: rightSide
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

                NetworkWidget {}

                MemoryWidget {}

                CpuWidget {}

                GpuWidget {}

                VolumeWidget {
                    mixer: "Master"
                }

                VolumeWidget {
                    mixer: "Capture"
                    isMic: true
                }

                CameraWidget {}

                BrightnessWidget {}

                BatteryWidget {}

                TrayWidget {}

                NotificationsWidget {}

                ClockWidget {}
            }
        }
    }
}
