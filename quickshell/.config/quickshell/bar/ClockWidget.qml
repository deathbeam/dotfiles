import Quickshell
import QtQuick

Text {
    property string dateStr: ""
    property string timeStr: ""
    
    text: Theme.iconClock + " " + dateStr + " " + timeStr
    color: Theme.colorFg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.margin
    rightPadding: Theme.margin
    
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
