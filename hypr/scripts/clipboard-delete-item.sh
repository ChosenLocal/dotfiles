#!/usr/bin/env bash
set -euo pipefail

# Delete selected item from clipboard history
selection=$(cliphist list | rofi -dmenu -p "Delete item" -theme ~/.config/rofi/clipboard.rasi)
[ -z "$selection" ] && exit 0

# Delete from cliphist
cliphist delete-query "$selection"

notify-send "Clipboard" "Item deleted"
