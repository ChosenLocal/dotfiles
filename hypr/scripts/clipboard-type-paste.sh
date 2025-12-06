#!/usr/bin/env bash
set -euo pipefail

# Pick from cliphist via rofi, then type the content (for apps that don't accept paste)
selection=$(cliphist list | rofi -dmenu -p "Type paste" -theme ~/.config/rofi/clipboard.rasi)
[ -z "$selection" ] && exit 0

tmp="$(mktemp -t clipboard-type.XXXXXX)"
trap "rm -f $tmp" EXIT

cliphist decode <<<"$selection" > "$tmp"

# Type with optimized speed (3ms delay between keys, 8ms between modifiers)
content="$(cat "$tmp")"
[ -n "$content" ] && wtype -s 3 -m 8 -- "$content"
