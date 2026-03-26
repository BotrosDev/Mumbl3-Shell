import QtQuick 2.15
import QtQuick.Controls 2.15
import "../../core" as Dat

Item {
    id: circularProgress

    property real value: 0.0 // 0.0 to 1.0
    property string text: ""
    property color progressColor: Dat.Colors.color.primary
    property color backgroundColor: Dat.Colors.color.surface_variant
    property int circleWidth: 10

    onValueChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            var center = Qt.point(width / 2, height / 2);
            var radius = Math.min(width, height) / 2 - circleWidth / 2;
            var startAngle = -Math.PI / 2;
            var endAngle = startAngle + (2 * Math.PI * value);

            // Background circle
            ctx.beginPath();
            ctx.arc(center.x, center.y, radius, 0, 2 * Math.PI);
            ctx.lineWidth = circleWidth;
            ctx.strokeStyle = backgroundColor;
            ctx.stroke();

            // Progress circle
            ctx.beginPath();
            ctx.arc(center.x, center.y, radius, startAngle, endAngle);
            ctx.lineWidth = circleWidth;
            ctx.strokeStyle = progressColor;
            ctx.stroke();
        }
    }

    Text {
        id: progressText
        anchors.centerIn: parent
        text: circularProgress.text
        color: Dat.Colors.color.on_surface
        font.pixelSize: 24
        font.bold: true
    }
}
