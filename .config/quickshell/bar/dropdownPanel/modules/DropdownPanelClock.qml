// Original Author: Hornie [https://github.com/Rexcrazy804]

// Modified by: BotrosDev [https://github.com/BotrosDev]
//              EmiliaCatgirl [She has no GitHub, i have no idea how to credit her, but she did help a lot with the design and the code]
//              MumbleGameZ [https://github.com/MumbleGameZ]
import QtQuick
import QtQuick.Controls
import "../Data/" as Dat

Rectangle {
  id: clock
  color: "transparent"
  // Size is controlled by the layout in DropdownPanelWindow in /quickshell/bar/dropdownPanel/DropdownPanelWindow.qml

  Rectangle {
    id: clockFace
    anchors.fill: parent
    color: Dat.Colors.color.surface_container_high
    radius: 20
    clip: true

    Image {
      anchors.fill: parent
      source: "../../Assets/sleepOnHimmel.png"   
      fillMode: Image.PreserveAspectCrop
      opacity: 0.20
      mipmap: true
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 110
      color: Dat.Colors.color.secondary
      font.family: Dat.Fonts.glitch
      font.pointSize: 100
      text: "."
      opacity: 0.8
    }

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 10
      color: Dat.Colors.color.secondary
      font.family: Dat.Fonts.glitch
      font.pointSize: 32
      text: "12"
      opacity: 0.8
    }


    Text {
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 10
      anchors.horizontalCenter: parent.horizontalCenter
      color: Dat.Colors.color.secondary
      font.family: Dat.Fonts.glitch
      font.pointSize: 32
      text: "6"
      opacity: 0.8
    }

    Text {
      anchors.right: parent.right
      anchors.rightMargin: 3
      anchors.verticalCenter: parent.verticalCenter
      color: Dat.Colors.color.secondary
      font.family: Dat.Fonts.glitch
      font.pointSize: 32
      text: "3"
      opacity: 0.8
    }

    Text {
      anchors.left: parent.left
      anchors.leftMargin: 10
      anchors.verticalCenter: parent.verticalCenter
      color: Dat.Colors.color.secondary
      font.family: Dat.Fonts.glitch
      font.pointSize: 32
      text: "9"
      opacity: 0.8
    }

    Item {
      id: hoursHand

      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height
      rotation: (360 * parseInt(Qt.formatDateTime(Dat.Clock?.date, "hh")) / 12) + (30 * (minutesHand.rotation) / 360)
      width: 28

      Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2

        Image {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          anchors.topMargin: 70
          antialiasing: true
          fillMode: Image.PreserveAspectFit
          height: this.width * 2
          mipmap: true
          rotation: 180
          source: "../../Assets/frichibbi.png"
          opacity: 0.75
          width: 70
        }
      }
    }

    Item {
      id: minutesHand

      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height
      rotation: (360 * parseInt(Qt.formatDateTime(Dat.Clock?.date, "mm")) / 60) + (6 * (secondsHand.rotation / 360))
      width: 28

      Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height / 2

      Image {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          anchors.topMargin: 10
          antialiasing: true
          fillMode: Image.PreserveAspectFit
          height: this.width * 2
          mipmap: true
          rotation: 180
          source: "../../Assets/Starkchibi.png"
          width: 120
          opacity: 0.75
        }
      }
    }

    Item {
      id: secondsHand

      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      height: parent.height
      rotation: 360 * parseInt(Qt.formatDateTime(Dat.Clock?.date, "ss")) / 60
      width: 28

      Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 60
        height: parent.height / 2

        Image {
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          antialiasing: true
          fillMode: Image.PreserveAspectFit
          height: this.width * 2
          mipmap: true
          rotation: 180
          source: "../../Assets/himchibbi.png"
          width: 60
          opacity: 0.75
        }
      }
    }
  }
}