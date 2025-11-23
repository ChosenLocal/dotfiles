import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { commandPaletteActions, runAction } from "../lib/actions"

export default function Palette() {
  const Pango = imports.gi.Pango

  const listbox = new Gtk.ListBox({
    selection_mode: Gtk.SelectionMode.NONE,
    activate_on_single_click: true,
    hexpand: true,
  })

  const buildRows = (query: string) => {
    const filter = query.toLowerCase().trim()
    let row = listbox.get_row_at_index(0)
    while (row) {
      listbox.remove(row)
      row = listbox.get_row_at_index(0)
    }

    commandPaletteActions
      .filter((action) => {
        if (!filter) return true
        return (
          action.label.toLowerCase().includes(filter) ||
          (action.description?.toLowerCase().includes(filter) ?? false)
        )
      })
      .forEach((action) => {
        const label = new Gtk.Label({
          label: action.label,
          halign: Gtk.Align.START,
          hexpand: true,
          ellipsize: Pango.EllipsizeMode.END,
        })

        const description = new Gtk.Label({
          label: action.description ?? "",
          css_classes: ["muted"],
          halign: Gtk.Align.END,
          hexpand: true,
          ellipsize: Pango.EllipsizeMode.END,
        })

        const rowContent = new Gtk.Box({
          spacing: 8,
          hexpand: true,
          css_classes: ["palette-row"],
        })
        rowContent.append(label)
        rowContent.append(description)

        const row = new Gtk.ListBoxRow({ child: rowContent })
        row.set_activatable(true)
        row.connect("activate", () => runAction(action))
        listbox.append(row)
      })
  }

  const entry = new Gtk.Entry({
    placeholder_text: "Run command or workflow…",
    hexpand: true,
  })
  entry.connect("changed", () => buildRows(entry.text ?? ""))

  const searchRow = new Gtk.Box({
    spacing: 8,
    hexpand: true,
    css_classes: ["search-row"],
  })
  searchRow.append(entry)

  buildRows("")

  const scroller = new Gtk.ScrolledWindow({
    child: listbox,
    hexpand: true,
    vexpand: true,
    css_classes: ["palette-scroll"],
  })

  const container = new Gtk.Box({
    orientation: Gtk.Orientation.VERTICAL,
    spacing: 10,
    css_classes: ["palette-container"],
  })

  const title = new Gtk.Label({
    label: "Command Palette",
    halign: Gtk.Align.START,
    css_classes: ["title"],
  })

  container.append(title)
  container.append(searchRow)
  container.append(scroller)

  return new Astal.Window({
    name: "palette",
    css_classes: ["Palette"],
    application: app,
    visible: false,
    layer: Astal.Layer.OVERLAY,
    anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT,
    exclusivity: Astal.Exclusivity.IGNORE,
    child: container,
  })
}
