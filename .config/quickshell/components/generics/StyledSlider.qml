// Drop in the same generics/ folder as CircularProgress.qml
import QtQuick
import QtQuick.Controls
import "../../core" as Dat

Slider {
    id: sl

    background: Rectangle {
        x: sl.leftPadding
        y: sl.topPadding + sl.availableHeight / 2 - height / 2
        implicitWidth: 200
        implicitHeight: 4
        width: sl.availableWidth
        height: implicitHeight
        radius: 2
        color: Dat.Colors.color.surface

        Rectangle {
            width: sl.visualPosition * parent.width
            height: parent.height
            color: Dat.Colors.color.primary
            radius: 2
        }
    }

    handle: Rectangle {
        x: sl.leftPadding + sl.visualPosition * (sl.availableWidth - width)
        y: sl.topPadding + sl.availableHeight / 2 - height / 2
        implicitWidth: 16
        implicitHeight: 16
        radius: 8
        color: Dat.Colors.color.primary
        border.color: Dat.Colors.color.on_primary
        border.width: 2
    }
}
