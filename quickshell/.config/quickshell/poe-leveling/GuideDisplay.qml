import QtQuick
import QtQuick.Layouts

Column {
    id: root

    property var guideLines: []
    property int currentPage: 0

    spacing: 4

    Text {
        text: "Page " + (currentPage + 1) + "/" + Math.ceil(guideLines.length / Config.linesPerPage)
        color: Config.colorFgDim
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize - 3
        visible: guideLines.length > Config.linesPerPage
    }

    Repeater {
        model: {
            const start = currentPage * Config.linesPerPage;
            const end = Math.min(start + Config.linesPerPage, guideLines.length);
            return guideLines.slice(start, end);
        }

        delegate: Text {
            text: modelData
            color: Config.colorFg
            font.family: Config.fontFamily
            font.pixelSize: Config.fontSize
            wrapMode: Text.WordWrap
            width: root.width
            textFormat: Text.RichText
        }
    }

    Text {
        text: "↻ Waiting for zone change..."
        color: Config.colorFgDim
        font.family: Config.fontFamily
        font.pixelSize: Config.fontSize
        font.italic: true
        visible: guideLines.length === 0
    }

    function nextPage() {
        const maxPage = Math.ceil(guideLines.length / Config.linesPerPage) - 1;
        if (currentPage < maxPage) {
            currentPage++;
        }
    }

    function prevPage() {
        if (currentPage > 0) {
            currentPage--;
        }
    }
}
