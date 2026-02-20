import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: Config.margin

    Repeater {
        model: SystemTray.items.values

        delegate: Item {
            id: trayItem
            property var item: modelData

            implicitWidth: mouseArea.containsMouse ? nameText.width + iconRect.width + Config.margin : iconRect.width
            width: implicitWidth
            height: Config.barHeight

            // Icon source with proper path handling
            property string iconSource: {
                let icon = item?.icon;
                if (typeof icon === 'string' || icon instanceof String) {
                    if (icon === "")
                        return "";
                    // Handle special ?path= format
                    if (icon.includes("?path=")) {
                        const split = icon.split("?path=");
                        if (split.length === 2) {
                            const name = split[0];
                            const path = split[1];
                            let fileName = name.substring(name.lastIndexOf("/") + 1);
                            return `file://${path}/${fileName}`;
                        }
                    }
                    // Add file:// prefix if needed
                    if (icon.startsWith("/") && !icon.startsWith("file://"))
                        return `file://${icon}`;
                    return icon;
                }
                return "";
            }

            Rectangle {
                anchors.fill: parent
                color: mouseArea.containsMouse ? Config.colorInactive : "transparent"
                radius: 2

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: parent.height
                    spacing: Config.margin / 2
                    layoutDirection: Qt.RightToLeft

                    Rectangle {
                        id: iconRect
                        width: Config.fontSize + Config.margin
                        height: parent.height
                        color: "transparent"

                        Image {
                            id: iconImage
                            anchors.centerIn: parent
                            width: Config.fontSize
                            height: Config.fontSize
                            source: trayItem.iconSource
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            smooth: true
                            visible: status === Image.Ready
                        }

                        // Fallback text if icon fails to load
                        Text {
                            anchors.centerIn: parent
                            visible: !iconImage.visible
                            text: {
                                const itemId = item?.id || "";
                                if (!itemId)
                                    return "?";
                                return itemId.charAt(0).toUpperCase();
                            }
                            font.pixelSize: Config.fontSize - 2
                            font.family: Config.fontFamily
                            color: Config.colorFg
                        }
                    }

                    Text {
                        id: nameText
                        anchors.verticalCenter: parent.verticalCenter
                        text: item?.tooltipTitle || item?.id || ""
                        font.family: Config.fontFamily
                        font.pixelSize: Config.fontSize
                        color: Config.colorFg
                        visible: mouseArea.containsMouse
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton

                    onClicked: {
                        if (trayItem.item) {
                            trayItem.item.activate();
                        }
                    }
                }
            }
        }
    }
}
