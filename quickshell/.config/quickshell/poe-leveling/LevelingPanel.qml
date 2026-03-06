import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    color: Qt.rgba(0, 0.17, 0.21, Config.opacity)
    border.color: Qt.rgba(0.16, 0.63, 0.60, 0.3)
    border.width: 1

    property var currentState: null

    function updateState(state) {
        currentState = state;
        guideDisplay.currentPage = 0;
    }

    function nextPage() {
        guideDisplay.nextPage();
    }

    function prevPage() {
        guideDisplay.prevPage();
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Config.margin
        spacing: Config.spacing

        ZoneInfo {
            Layout.preferredWidth: implicitWidth + 20
            Layout.fillHeight: true

            zoneName: currentState?.zone_name || "Waiting for game..."
            level: currentState?.level || 0
            act: currentState?.act || 0
        }

        Rectangle {
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Layout.topMargin: 4
            Layout.bottomMargin: 4
            color: Config.colorFgDim
            opacity: 0.3
        }

        GuideDisplay {
            id: guideDisplay

            Layout.fillWidth: true
            Layout.fillHeight: true

            guideLines: currentState?.guide || []
        }
    }
}
