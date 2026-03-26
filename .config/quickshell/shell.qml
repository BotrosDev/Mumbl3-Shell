import QtQuick
import Quickshell
import "components/bar"
import "components/widgets"
import "components/dropdown"
import "components/generics"


ShellRoot {
    id: root

    // Loader {
    //     active: true
    //     sourceComponent: DropdownPanelButton {}
    // }

    Loader {
        id: dropdownPanelLoader
        active: true
        sourceComponent: DropdownPanelWindow {}  
    }

    DropdownPanelButton {
        id: panelButton

        property bool isOpen: dropdownPanelLoader.item ? dropdownPanelLoader.item.isOpen : false

        onButtonClicked: {
            if (dropdownPanelLoader.item) {
                dropdownPanelLoader.item.isOpen = !dropdownPanelLoader.item.isOpen
            }
        }
    }

    NotificationPopups {}

    WiFiPopup      { id: wifiPopup  }
    BluetoothPopup { id: btPopup    }
    VolumePopup    { id: volumePopup  }
    BatteryPopup   { id: batteryPopup }

    Bar {
        id: bar
        wifiPopupRef: wifiPopup
        btPopupRef:   btPopup
        volPopupRef:  volumePopup
        batPopupRef:  batteryPopup
    }
}
