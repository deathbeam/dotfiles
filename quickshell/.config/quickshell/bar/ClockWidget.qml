import Quickshell
import QtQuick

Text {
    property string dateStr: ""
    property string timeStr: ""
    
    text: Config.iconClock + " " + dateStr + " " + timeStr
    color: Config.colorFg
    font.family: Config.fontFamily
    font.pixelSize: Config.fontSize
    leftPadding: Config.margin
    rightPadding: Config.margin
    
    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        
        onTriggered: {
            var now = new Date();
            parent.dateStr = Qt.formatDate(now, "yyyy-MM-dd");
            parent.timeStr = Qt.formatTime(now, "HH:mm");
        }
    }
}
