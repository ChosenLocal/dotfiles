#!/usr/bin/env bash
set -euo pipefail

# Pin current clipboard item to favorites
# Note: clipse doesn't have a direct CLI pin command yet, so this copies to a persistent file
# You can manually pin within the clipse TUI instead

current=$(wl-paste)
if [ -z "$current" ]; then
  notify-send "Clipboard" "Nothing to pin"
  exit 1
fi

mkdir -p ~/.local/share/cliphist-pins
timestamp=$(date +%s)
echo "$current" > ~/.local/share/cliphist-pins/pin-$timestamp.txt

notify-send "Clipboard" "Item pinned (check ~/.local/share/cliphist-pins/)"
