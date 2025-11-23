import { execAsync } from "ags/process"

export type Action = {
  id: string
  label: string
  description?: string
  command: string
}

export const commandPaletteActions: Action[] = [
  { id: "terminal", label: "Terminal", description: "Kitty + Zellij", command: "kitty" },
  { id: "files", label: "Files", description: "Thunar file manager", command: "thunar" },
  { id: "browser", label: "Browser", description: "Chromium", command: "chromium" },
  { id: "dev-code", label: "Editor: Cursor", description: "GUI editor", command: "cursor" },
  { id: "editor-cli", label: "Editor: Neovim", description: "Terminal editor", command: "kitty -e nvim" },
  {
    id: "reset-monitors",
    label: "Monitors: reset layout",
    description: "~/Desktop/main/scripts/set_hyprland_monitors.sh",
    command: "~/Desktop/main/scripts/set_hyprland_monitors.sh",
  },
  { id: "hypr-reload", label: "Hyprland: reload config", description: "hyprctl reload", command: "hyprctl reload" },
  { id: "clipboard", label: "Clipboard picker", description: "rofi clipboard menu", command: "~/.config/hypr/scripts/cliphist-type.sh" },
  { id: "obsidian", label: "Notes: Obsidian", description: "Open vault", command: "obsidian" },
  { id: "llm-claude", label: "AI: Claude Desktop", description: "claude-desktop-native", command: "claude-desktop-native" },
  { id: "llm-assistant", label: "AI: Assistant", description: "assistant", command: "assistant" },
  { id: "agent-crm", label: "BizOps / CRM", description: "Close + Notion", command: "vivaldi-stable --new-window \"https://app.close.com\" \"https://www.notion.so\"" },
  { id: "calendar", label: "Calendar / Todos", description: "Sunsama + Todoist + Calendar", command: "vivaldi --new-window https://app.sunsama.com https://todoist.com https://calendar.google.com" },
]

export const powerActions: Action[] = [
  { id: "lock", label: "Lock", description: "lock-session", command: "loginctl lock-session" },
  { id: "logout", label: "Logout", description: "hyprctl exit", command: "hyprctl dispatch exit" },
  { id: "reboot", label: "Reboot", description: "systemctl reboot", command: "systemctl reboot" },
  { id: "shutdown", label: "Shutdown", description: "systemctl poweroff", command: "systemctl poweroff" },
]

export const quickSettingActions: Action[] = [
  { id: "wifi", label: "Network Manager", description: "nm-connection-editor", command: "nm-connection-editor" },
  { id: "bluetooth", label: "Bluetooth", description: "blueman-manager", command: "blueman-manager" },
  { id: "nightlight", label: "Night light toggle", description: "pkill -f wlsunset || wlsunset -l 37.8 -L -122.4", command: "pkill -f wlsunset || wlsunset -l 37.8 -L -122.4" },
  { id: "notifications", label: "Mako DND toggle", description: "toggle Do Not Disturb", command: "makoctl mode -t do-not-disturb" },
  { id: "agents", label: "Agent Center", description: "LLM tools hub", command: "ags toggle palette" },
]

export const runAction = (action: Action) =>
  execAsync(action.command).catch((err) => console.error(`Action failed (${action.id}):`, err))
