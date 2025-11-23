import app from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { quickSettingActions, runAction } from "../lib/actions"

export default function QuickSettings() {
  return (
    <window
      name="quicksettings"
      class="QuickSettings"
      application={app}
      visible={false}
      layer={Astal.Layer.OVERLAY}
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
      exclusivity={Astal.Exclusivity.IGNORE}
    >
      <box class="quicksettings-container" orientation={Gtk.Orientation.VERTICAL} spacing={10}>
        <label class="title" xalign={0} label="Quick Settings" />
        <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          {quickSettingActions.map((action) => (
            <button class="chip" onClicked={() => runAction(action)}>
              <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
                <label label={action.label} xalign={0} />
                {action.description && <label class="muted" label={action.description} xalign={0} />}
              </box>
            </button>
          ))}
        </box>
      </box>
    </window>
  )
}
