#!/usr/bin/env bash
set -euo pipefail

# Pick from cliphist via rofi, copy to clipboard, paste immediately
selection=$(cliphist list | rofi -dmenu -p "Quick paste" -theme ~/.config/rofi/clipboard.rasi)
[ -z "$selection" ] && exit 0

# Decode and copy
cliphist decode <<<"$selection" | wl-copy

# Smart paste based on focused window
sleep 0.05  # Give clipboard time to update
win_class="$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')"

if [ "$win_class" = "kitty" ] && command -v kitty >/dev/null; then
  kitty @ paste-from-clipboard 2>/dev/null || wtype -M ctrl -P v -m ctrl -p v
else
  wtype -M ctrl -P v -m ctrl -p v
fi
