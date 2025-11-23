#!/usr/bin/env bash
set -euo pipefail

# Pick from cliphist, copy to clipboard, then type into focused window.
selection=$(cliphist list | rofi -dmenu -p "Type paste" -theme ~/.config/rofi/clipboard.rasi) || exit 1
[ -z "$selection" ] && exit 1

tmp="$(mktemp -t cliphist-type.XXXXXX)"
cliphist decode <<<"$selection" > "$tmp"
wl-copy < "$tmp"

# If focused window is kitty, use kitty remote to inject text directly
win_class="$(hyprctl activewindow -j 2>/dev/null | jq -r '.class // empty')"
if [ "$win_class" = "kitty" ] && command -v kitty >/dev/null; then
    if ! kitty @ send-text --stdin < "$tmp"; then
        content="$(cat "$tmp")"
        [ -n "$content" ] && wtype -s 5 -m 12 -- "$content"
    fi
else
    # Try Ctrl+Shift+V; if that fails, type the content
    if ! wtype -M ctrl_shift v; then
        content="$(cat "$tmp")"
        [ -n "$content" ] && wtype -s 5 -m 12 -- "$content"
    fi
fi
rm -f "$tmp"
