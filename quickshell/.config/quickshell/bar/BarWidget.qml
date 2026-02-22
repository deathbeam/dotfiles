import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // Public properties
    property string icon: ""
    property string text: ""
    property int status: BarWidget.Normal

    // Status enum
    enum Status {
        Normal,
        Warning,
        Danger
    }

    implicitWidth: mouseArea.containsMouse ? textLabel.width + iconLabel.width + Config.margin : iconLabel.width
    implicitHeight: Config.barHeight

    // Color mapping based on status
    readonly property color statusColor: {
        switch (status) {
        case BarWidget.Warning:
            return Config.colorWarning;
        case BarWidget.Danger:
            return Config.colorUrgent;
        default:
            return Config.colorFg;
        }
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

            // Icon (always visible)
            Text {
                id: iconLabel
                anchors.verticalCenter: parent.verticalCenter
                text: root.icon
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize
                color: root.statusColor
                leftPadding: Config.margin
                rightPadding: Config.margin
            }

            // Text (visible on hover)
            Text {
                id: textLabel
                anchors.verticalCenter: parent.verticalCenter
                text: root.text
                font.family: Config.fontFamily
                font.pixelSize: Config.fontSize
                color: root.statusColor
                visible: mouseArea.containsMouse
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
        }
    }
}
