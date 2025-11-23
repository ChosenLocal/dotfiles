#!/usr/bin/env bash
# AGS-first power menu with rofi fallback
set -u -o pipefail

# Try to toggle the AGS powermenu window (it starts via Hyprland exec-once).
if command -v ags >/dev/null 2>&1; then
    if ! pgrep -x ags >/dev/null 2>&1; then
        ags run >/dev/null 2>&1 &
        sleep 0.4
    fi
    if ags toggle powermenu >/dev/null 2>&1; then
        exit 0
    fi
fi

# Fallback: lightweight rofi dmenu
options="Lock\nLogout\nReboot\nShutdown\nBack to Plasma"
chosen=$(printf "%s" "$options" | rofi -dmenu -p "Power Menu" -theme ~/.config/rofi/powermenu.rasi) || exit 0

case "$chosen" in
    "Lock") loginctl lock-session ;;
    "Logout") hyprctl dispatch exit ;;
    "Reboot") systemctl reboot ;;
    "Shutdown") systemctl poweroff ;;
    "Back to Plasma")
        hyprctl dispatch exit
        # User will select Plasma session at SDDM
        ;;
esac
