#!/usr/bin/env bash
# ============================================
# HYPRLAND MONITOR DETECTION & CONFIGURATION
# Run this script after logging into Hyprland for the first time
# ============================================

set -euo pipefail

CONFIG_FILE="$HOME/.config/hypr/hyprland.conf"
BACKUP_FILE="$HOME/.config/hypr/hyprland.conf.backup"

echo "============================================"
echo "Hyprland Monitor Detection Tool"
echo "============================================"
echo

# Check if Hyprland is running
if ! pgrep -x Hyprland > /dev/null; then
    echo "ERROR: Hyprland is not running!"
    echo "Please run this script from within a Hyprland session."
    exit 1
fi

# Backup existing config
echo "[1/4] Backing up current config..."
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "      Backup saved to: $BACKUP_FILE"
echo

# Detect monitors
echo "[2/4] Detecting monitors..."
monitors=$(hyprctl monitors -j | jq -r '.[] | "\(.id):\(.name):\(.width):\(.height):\(.refreshRate):\(.x):\(.y)"')

if [ -z "$monitors" ]; then
    echo "ERROR: No monitors detected!"
    exit 1
fi

echo "      Found monitors:"
declare -a monitor_names=()
declare -a monitor_configs=()

while IFS=: read -r id name width height refresh x y; do
    refresh_int=$(printf "%.0f" "$refresh")
    echo "        [$id] $name - ${width}x${height}@${refresh_int}Hz at position ${x},${y}"
    monitor_names+=("$name")
    monitor_configs+=("monitor=$name,${width}x${height}@${refresh_int},${x}x${y},1")
done <<< "$monitors"

num_monitors=${#monitor_names[@]}
echo "      Total monitors: $num_monitors"
echo

# Ask user to identify monitors
echo "[3/4] Monitor identification:"
echo "      You have 4 monitors. Let's identify them:"
echo

read -p "Which monitor is your LEFT FRONT display? [${monitor_names[0]}]: " left_mon
left_mon=${left_mon:-${monitor_names[0]}}

read -p "Which monitor is your CENTER FRONT display? [${monitor_names[1]}]: " center_mon
center_mon=${center_mon:-${monitor_names[1]}}

read -p "Which monitor is your RIGHT FRONT display? [${monitor_names[2]}]: " right_mon
right_mon=${right_mon:-${monitor_names[2]}}

read -p "Which monitor is your TV ABOVE? [${monitor_names[3]}]: " tv_mon
tv_mon=${tv_mon:-${monitor_names[3]}}

echo
echo "      Configuration:"
echo "        Left Front:   $left_mon   (WS 1-3)"
echo "        Center Front: $center_mon (WS 4-6)"
echo "        Right Front:  $right_mon  (WS 7-9)"
echo "        TV Above:     $tv_mon     (WS 10)"
echo

# Update config file
echo "[4/4] Updating Hyprland config..."

# Create monitor section
monitor_section=""
for config in "${monitor_configs[@]}"; do
    monitor_section+="$config\n"
done

# Create workspace section
workspace_section="# ============================================\n"
workspace_section+="# WORKSPACE → MONITOR MAPPING\n"
workspace_section+="# ============================================\n"
workspace_section+="# Front monitors (3): WS 1-9 (3 workspaces each)\n"
workspace_section+="# TV above (1): WS 10\n\n"
workspace_section+="workspace = 1, monitor:$left_mon\n"
workspace_section+="workspace = 2, monitor:$left_mon\n"
workspace_section+="workspace = 3, monitor:$left_mon\n"
workspace_section+="workspace = 4, monitor:$center_mon\n"
workspace_section+="workspace = 5, monitor:$center_mon\n"
workspace_section+="workspace = 6, monitor:$center_mon\n"
workspace_section+="workspace = 7, monitor:$right_mon\n"
workspace_section+="workspace = 8, monitor:$right_mon\n"
workspace_section+="workspace = 9, monitor:$right_mon\n"
workspace_section+="workspace = 10, monitor:$tv_mon\n"

# Replace the placeholder monitor config
sed -i '/^# Auto-detect all monitors with preferred settings for now/,/^monitor=,preferred,auto,1/d' "$CONFIG_FILE"

# Insert the new monitor configs after the MONITORS section header
sed -i "/# ============================================/,/# MONITORS/a\\
$monitor_section" "$CONFIG_FILE"

# Replace the workspace comment section with the actual config
sed -i '/^# Uncomment and adjust after running detect-monitors.sh/,/^# workspace = 10, monitor:HDMI-A-1/d' "$CONFIG_FILE"
sed -i "/# TV above (1): WS 10/a\\
$workspace_section" "$CONFIG_FILE"

echo "      Config updated successfully!"
echo

echo "============================================"
echo "Configuration Complete!"
echo "============================================"
echo
echo "Next steps:"
echo "  1. Review the updated config: $CONFIG_FILE"
echo "  2. Reload Hyprland: Super+Shift+R or logout/login"
echo "  3. Test workspace switching: Super+[1-9,0]"
echo "  4. Optional: Add custom wallpapers per monitor in:"
echo "     ~/.config/hypr/hyprpaper.conf"
echo
echo "Backup available at: $BACKUP_FILE"
echo
