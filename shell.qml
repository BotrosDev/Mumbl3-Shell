//@ pragma UseQApplication

import QtQuick
import Quickshell
import "modules/bar"
import "modules/widgets"
import "dropdownPanel"

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

    Bar {
        id: bar
    }
}
