//@ pragma UseQApplication

import QtQuick
import Quickshell
import "components/bar"
import "components/widgets"
import "components/dropdown"
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

    Bar {
        id: bar
    }

}
