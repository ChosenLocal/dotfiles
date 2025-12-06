#!/usr/bin/env bash
# Launch clipse TUI in floating kitty window

kitty --class clipboard-tui \
  --title "Clipboard Manager" \
  -o font_size=11 \
  -o window_padding_width=12 \
  clipse
