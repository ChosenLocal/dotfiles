#!/usr/bin/env bash
set -euo pipefail

# Pure rofi mode (fallback if clipse crashes or for quick one-liner access)
selection=$(cliphist list | rofi -dmenu -p "Clipboard" -theme ~/.config/rofi/clipboard.rasi)
[ -z "$selection" ] && exit 0

cliphist decode <<<"$selection" | wl-copy
notify-send "Clipboard" "Copied to clipboard"
