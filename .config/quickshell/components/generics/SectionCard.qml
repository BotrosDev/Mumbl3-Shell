// Place this in the same generics/ folder as CircularProgress.qml
// A titled section container used by SystemTab sections.

import QtQuick
import QtQuick.Layouts
import "../../core" as Dat

ColumnLayout {
    id: sectionCard
    spacing: 6

    property string title: ""

    // Everything declared inside a SectionCard instance goes into contentArea
    default property alias data: contentArea.data

    Text {
        text: title
        font.bold: true
        font.pixelSize: 14
        color: Dat.Colors.color.on_surface
        leftPadding: 2
    }

    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Dat.Colors.color.on_surface
        opacity: 0.12
    }

    ColumnLayout {
        id: contentArea
        Layout.fillWidth: true
        spacing: 0
    }
}
