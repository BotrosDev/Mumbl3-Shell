import QtQuick
import QtQuick.Effects

import "../generics" as Gen
import "../../core" as Dat

Rectangle {
  id: root
  required property real iconOpacity
  required property string icon
  function onClick() {}

  color: Dat.Colors.color.primary
  height: this.width
  radius: this.width

  layer.enabled: true
  layer.effect: MultiEffect {
    shadowEnabled: true
    shadowOpacity: root.iconOpacity
    shadowScale: 1
    shadowBlur: 0.8
  }

  Gen.MouseArea {
    id: mArea
    layerColor: sesIcon.color
    onClicked: root.onClick()
  }

  Gen.MatIcon {
    fill: mArea.containsMouse
    id: sesIcon
    anchors.centerIn: parent
    color: Dat.Colors.color.on_primary
    font.pointSize: 17
    icon: root.icon
    opacity: root.iconOpacity
  }
}
