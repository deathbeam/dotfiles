import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray

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

            implicitHeight: Theme.barHeight

            color: Theme.colorBg

            // Left side
            RowLayout {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: 0

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
                BrightnessWidget {}
                BatteryWidget {}
                ClockWidget {}
                NotificationsWidget {}

                Repeater {
                    model: SystemTray.items
                    delegate: Item {
                        Image {
                            source: modelData.icon
                            width: Theme.fontSize
                            height: Theme.fontSize
                            fillMode: Image.PreserveAspectFit
                        }
                    }
                }
            }
        }
    }
}
