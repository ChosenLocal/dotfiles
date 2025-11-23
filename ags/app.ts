import app from "ags/gtk4/app"
import Adw from "gi://Adw"
import style from "./style.scss"
import Palette from "./widget/Palette"
import PowerMenu from "./widget/PowerMenu"
import QuickSettings from "./widget/QuickSettings"
import AppLauncher from "./widget/AppLauncher"

// Force dark mode to avoid libadwaita warning about gtk-application-prefer-dark-theme
Adw.StyleManager.get_default()?.set_color_scheme(Adw.ColorScheme.FORCE_DARK)

app.start({
  css: style,
  main() {
    Palette()
    PowerMenu()
    QuickSettings()
    AppLauncher()
  },
})
