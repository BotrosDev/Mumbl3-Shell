pragma Singleton
import Quickshell

Singleton {
  id: fonts

  readonly property string caskaydia: "CaskaydiaMono Nerd"
  readonly property string dejavuSans: "Dejavu Sans"
  readonly property string glitch: "Rubik Glitch"
  readonly property string hurricane: "Hurricane"
  readonly property string jpKaisei: "Kaisei Decol"
  readonly property string monoton: "Monoton"
  readonly property string zilla: "Zilla Slab Highlight"
  readonly property string rye: "Rye"

  // For Font changer in PersonalizationsTab – single source of truth
  readonly property var fontDisplayNames: ["Caskaydia Mono", "DejaVu Sans", "Rubik Glitch", "Hurricane", "Kaisei Decol", "Monoton", "Zilla Slab Highlight", "Rye"]
  readonly property var fontFamilies: [fonts.caskaydia, fonts.dejavuSans, fonts.glitch, fonts.hurricane, fonts.jpKaisei, fonts.monoton, fonts.zilla, fonts.rye]
}
