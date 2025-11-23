import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"
import Gio from "gi://Gio"

type DesktopApp = {
  name: string
  displayName: string
  description: string
  icon: string
  exec: string
  terminal: boolean
  path: string
}

// Parse .desktop files and extract app metadata
function parseDesktopFile(path: string): DesktopApp | null {
  try {
    const keyfile = new GLib.KeyFile()
    keyfile.load_from_file(path, GLib.KeyFileFlags.NONE)

    const group = "Desktop Entry"

    // Skip hidden/nodisplay apps
    let noDisplay = false
    try { noDisplay = keyfile.get_boolean(group, "NoDisplay") } catch (e) { }

    let hidden = false
    try { hidden = keyfile.get_boolean(group, "Hidden") } catch (e) { }

    if (noDisplay || hidden) return null

    const name = keyfile.get_string(group, "Name")
    const exec = keyfile.get_string(group, "Exec")

    let icon = "application-x-executable"
    try { icon = keyfile.get_string(group, "Icon") } catch (e) { }

    let description = ""
    try { description = keyfile.get_string(group, "Comment") } catch (e) { }

    let terminal = false
    try { terminal = keyfile.get_boolean(group, "Terminal") } catch (e) { }

    // Clean exec string (remove field codes like %U, %F)
    const cleanExec = exec.replace(/%[uUfFdDnNickvm]/g, "").trim()

    return {
      name: name.toLowerCase(),
      displayName: name,
      description,
      icon,
      exec: cleanExec,
      terminal,
      path,
    }
  } catch (e) {
    return null
  }
}

// Scan directories for .desktop files
function scanDesktopApps(): DesktopApp[] {
  const apps: DesktopApp[] = []
  const seen = new Set<string>()

  const directories = [
    "/usr/share/applications",
    "/usr/local/share/applications",
    `${GLib.get_home_dir()}/.local/share/applications`,
  ]

  for (const dir of directories) {
    try {
      const file = Gio.File.new_for_path(dir)
      const enumerator = file.enumerate_children(
        "standard::name",
        Gio.FileQueryInfoFlags.NONE,
        null
      )

      let info
      while ((info = enumerator.next_file(null))) {
        const name = info.get_name()
        if (!name.endsWith(".desktop")) continue
        if (seen.has(name)) continue // Skip duplicates (first found takes precedence)

        const path = `${dir}/${name}`
        const app = parseDesktopFile(path)

        if (app) {
          apps.push(app)
          seen.add(name)
        }
      }
    } catch (e) {
      // Directory doesn't exist or can't be read, skip silently
    }
  }

  return apps.sort((a, b) => a.displayName.localeCompare(b.displayName))
}

export default function AppLauncher() {
  const Pango = imports.gi.Pango
  const allApps = scanDesktopApps()
  let selectedIndex = 0

  const listbox = new Gtk.ListBox({
    selection_mode: Gtk.SelectionMode.SINGLE,
    activate_on_single_click: true,
    hexpand: true,
  })

  // Launch app and close window
  const launchApp = (app: DesktopApp) => {
    // Close window immediately for better UX
    window.visible = false

    // Use sh -c to properly execute commands with shell interpretation
    const cmd = app.terminal
      ? `kitty -e sh -c '${app.exec.replace(/'/g, "'\\''")}; exec $SHELL'`
      : `sh -c '${app.exec.replace(/'/g, "'\\''")}'`

    execAsync(cmd)
      .catch((err) => console.error(`Failed to launch ${app.displayName}:`, err))
  }

  // Build filtered app list
  const buildRows = (query: string) => {
    selectedIndex = 0

    // Clear existing rows
    let row = listbox.get_row_at_index(0)
    while (row) {
      listbox.remove(row)
      row = listbox.get_row_at_index(0)
    }

    const filter = query.toLowerCase().trim()
    const filtered = allApps.filter((app) => {
      if (!filter) return true
      return (
        app.name.includes(filter) ||
        app.displayName.toLowerCase().includes(filter) ||
        app.description.toLowerCase().includes(filter)
      )
    })

    // Limit to 8 results for performance and clean UI
    const displayApps = filtered.slice(0, 8)

    displayApps.forEach((app, index) => {
      // App icon
      const icon = new Gtk.Image({
        icon_name: app.icon,
        pixel_size: 32,
        css_classes: ["app-icon"],
      })

      // App name
      const nameLabel = new Gtk.Label({
        label: app.displayName,
        halign: Gtk.Align.START,
        hexpand: true,
        ellipsize: Pango.EllipsizeMode.END,
        css_classes: ["app-name"],
      })

      // App description
      const descLabel = new Gtk.Label({
        label: app.description || "Application",
        halign: Gtk.Align.START,
        hexpand: true,
        ellipsize: Pango.EllipsizeMode.END,
        css_classes: ["app-description"],
      })

      // Vertical box for name + description
      const textBox = new Gtk.Box({
        orientation: Gtk.Orientation.VERTICAL,
        spacing: 2,
        hexpand: true,
        valign: Gtk.Align.CENTER,
      })
      textBox.append(nameLabel)
      textBox.append(descLabel)

      // Row content
      const rowContent = new Gtk.Box({
        spacing: 12,
        hexpand: true,
        css_classes: ["app-row"],
      })
      rowContent.append(icon)
      rowContent.append(textBox)

      const row = new Gtk.ListBoxRow({
        child: rowContent,
        activatable: true,
      })

      row.connect("activate", () => launchApp(app))
      listbox.append(row)

      // Select first row by default
      if (index === 0) {
        listbox.select_row(row)
      }
    })

    // Show "no results" if empty
    if (displayApps.length === 0) {
      const emptyLabel = new Gtk.Label({
        label: filter ? "No applications found" : "No applications available",
        css_classes: ["app-empty"],
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
      })
      const emptyRow = new Gtk.ListBoxRow({
        child: emptyLabel,
        activatable: false,
        selectable: false,
      })
      listbox.append(emptyRow)
    }
  }

  // Search entry
  const entry = new Gtk.Entry({
    placeholder_text: "Search applications…",
    hexpand: true,
  })

  entry.connect("changed", () => {
    buildRows(entry.text ?? "")
  })

  // Keyboard navigation using GTK4 EventControllerKey
  const keyController = new Gtk.EventControllerKey()

  keyController.connect("key-pressed", (_: any, keyval: number, keycode: number, state: Gdk.ModifierType) => {
    const key = Gdk.keyval_name(keyval)

    if (key === "Down") {
      const nextRow = listbox.get_row_at_index(selectedIndex + 1)
      if (nextRow && nextRow.get_activatable()) {
        selectedIndex++
        listbox.select_row(nextRow)
        nextRow.grab_focus()
      }
      return true
    }

    if (key === "Up") {
      const prevRow = listbox.get_row_at_index(selectedIndex - 1)
      if (prevRow && prevRow.get_activatable()) {
        selectedIndex--
        listbox.select_row(prevRow)
        prevRow.grab_focus()
      }
      return true
    }

    if (key === "Return" || key === "KP_Enter") {
      const selectedRow = listbox.get_selected_row()
      if (selectedRow) {
        listbox.emit("row-activated", selectedRow)
      }
      return true
    }

    if (key === "Escape") {
      window.visible = false
      return true
    }

    return false
  })

  entry.add_controller(keyController)

  const searchRow = new Gtk.Box({
    spacing: 0,
    hexpand: true,
    css_classes: ["app-search-row"],
  })
  searchRow.append(entry)

  // Initial build
  buildRows("")

  // Scrolled window for app list
  const scroller = new Gtk.ScrolledWindow({
    child: listbox,
    hexpand: true,
    vexpand: true,
    css_classes: ["app-scroll"],
    propagate_natural_height: true,
    max_content_height: 480,
  })

  // Container
  const container = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 12,
    css_classes: ["applauncher-container"],
  })

  container.append(searchRow)
  container.append(scroller)

  // Window
  const window = new Astal.Window({
    name: "applauncher",
    css_classes: ["AppLauncher"],
    application: app,
    visible: false,
    layer: Astal.Layer.OVERLAY,
    anchor: 0, // No anchor = centered
    exclusivity: Astal.Exclusivity.IGNORE,
    keymode: Astal.Keymode.EXCLUSIVE,
    child: container,
  })

  // Focus entry when window becomes visible
  window.connect("notify::visible", () => {
    if (window.visible) {
      entry.text = ""
      buildRows("")
      entry.grab_focus()
    }
  })

  return window
}
