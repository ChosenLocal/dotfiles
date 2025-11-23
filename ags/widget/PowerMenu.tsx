import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { powerActions, runAction } from "../lib/actions"

export default function PowerMenu() {
  return (
    <window
      name="powermenu"
      class="PowerMenu"
      application={app}
      visible={false}
      layer={Astal.Layer.OVERLAY}
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
    >
      <box class="powermenu-container" orientation={Gtk.Orientation.VERTICAL} spacing={12}>
        <label class="title" xalign={0} label="Power Menu" />
        <box class="powermenu-actions" orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          {powerActions.map((action) => (
            <button class="action" hexpand onClicked={() => runAction(action)}>
              <box hexpand spacing={8}>
                <label label={action.label} xalign={0} hexpand />
                {action.description && <label class="muted" label={action.description} xalign={1} />}
              </box>
            </button>
          ))}
        </box>
      </box>
    </window>
  )
}
