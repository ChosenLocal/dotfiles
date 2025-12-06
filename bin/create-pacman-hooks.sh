#!/usr/bin/env bash
# Create pacman hooks for smart upgrade system
# Requires sudo to install system-wide hooks

set -euo pipefail

echo "Creating pacman hooks for smart upgrade system..."

# Create hooks directory if it doesn't exist
sudo mkdir -p /etc/pacman.d/hooks/

# Hook 1: Pre-transaction warning for critical packages
sudo tee /etc/pacman.d/hooks/00-critical-package-warning.hook > /dev/null << 'EOF'
[Trigger]
Operation = Upgrade
Type = Package
Target = linux
Target = linux-headers
Target = nvidia-open
Target = nvidia-utils
Target = cuda
Target = hyprland

[Action]
Description = Warning about critical package updates...
When = PreTransaction
Exec = /usr/bin/bash -c 'echo -e "\033[1;33m[WARNING] Upgrading critical system packages. Ensure you have a backup!\033[0m"'
EOF

# Hook 2: Kernel backup before upgrade
sudo tee /etc/pacman.d/hooks/50-kernel-backup.hook > /dev/null << 'EOF'
[Trigger]
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Backing up current kernel...
When = PreTransaction
Exec = /usr/bin/bash -c 'if [[ -f /boot/vmlinuz-linux ]]; then sudo mkdir -p /boot/backup && sudo cp /boot/vmlinuz-linux /boot/backup/vmlinuz-linux.bak && sudo cp /boot/initramfs-linux.img /boot/backup/initramfs-linux.img.bak && echo "Kernel backed up to /boot/backup/"; fi'
EOF

# Hook 3: NVIDIA module rebuild after kernel upgrade
sudo tee /etc/pacman.d/hooks/60-nvidia-rebuild.hook > /dev/null << 'EOF'
[Trigger]
Operation = Upgrade
Type = Package
Target = linux

[Action]
Description = Rebuilding NVIDIA modules for new kernel...
When = PostTransaction
Exec = /usr/bin/bash -c 'if pacman -Qq nvidia-open &>/dev/null; then echo "Rebuilding NVIDIA modules..." && mkinitcpio -P; fi'
EOF

# Hook 4: Clean old packages (keep last 3 versions)
sudo tee /etc/pacman.d/hooks/90-package-cleanup.hook > /dev/null << 'EOF'
[Trigger]
Operation = Upgrade
Operation = Remove
Type = Package
Target = *

[Action]
Description = Cleaning old package cache (keeping last 3 versions)...
When = PostTransaction
Exec = /usr/bin/paccache -rk3
EOF

echo "Pacman hooks created successfully!"
echo ""
echo "Hooks installed:"
echo "  • 00-critical-package-warning.hook - Warns about critical upgrades"
echo "  • 50-kernel-backup.hook - Backs up kernel before upgrade"
echo "  • 60-nvidia-rebuild.hook - Rebuilds NVIDIA modules after kernel upgrade"
echo "  • 90-package-cleanup.hook - Cleans old packages automatically"
echo ""
echo "To remove hooks, delete files from /etc/pacman.d/hooks/"