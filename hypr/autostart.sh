#!/usr/bin/env bash
# Launch core apps with explicit workspace assignments.
# Using hyprctl dispatch ensures apps open in their designated workspaces.

# Brief pause to let Hyprland fully initialize
sleep 1

# Terminals (Zellij inside Kitty) – workspace 3
hyprctl dispatch exec "[workspace 3 silent] kitty"

# Obsidian – workspace 1
hyprctl dispatch exec "[workspace 1 silent] obsidian"

# Column 2 browsing: Gmail on workspace 5
hyprctl dispatch exec "[workspace 5 silent] vivaldi-stable --new-window https://mail.google.com"

# Day command center: Sunsama / Todoist / Calendar on workspace 8
hyprctl dispatch exec "[workspace 8 silent] vivaldi-stable --new-window https://app.sunsama.com https://todoist.com https://calendar.google.com"

# BizOps: Close + Notion on workspace 11
hyprctl dispatch exec "[workspace 11 silent] vivaldi-stable --new-window https://app.close.com https://www.notion.so"

# Entertainment / reference: YouTube on workspace 12
hyprctl dispatch exec "[workspace 12 silent] vivaldi-stable --new-window https://www.youtube.com"
