#!/usr/bin/env bash
# Setup systemd service for post-upgrade validation
# This service runs after system upgrades to validate critical components

set -euo pipefail

echo "Setting up post-upgrade validation service..."

# Create systemd service file
sudo tee /etc/systemd/system/post-upgrade-validation.service > /dev/null << 'EOF'
[Unit]
Description=Post-Upgrade System Validation
After=multi-user.target graphical.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/home/jack/dotfiles/bin/post-upgrade-validation
StandardOutput=journal
StandardError=journal
RemainAfterExit=yes

[Install]
WantedBy=default.target
EOF

# Create pacman hook to trigger the service
sudo tee /etc/pacman.d/hooks/99-post-upgrade-validation.hook > /dev/null << 'EOF'
[Trigger]
Operation = Upgrade
Type = Package
Target = *

[Action]
Description = Scheduling post-upgrade validation...
When = PostTransaction
Exec = /usr/bin/bash -c 'touch /var/lib/pacman/post-upgrade-pending'
EOF

# Create a timer to run validation after reboot if upgrade included kernel
sudo tee /etc/systemd/system/post-upgrade-validation.timer > /dev/null << 'EOF'
[Unit]
Description=Run post-upgrade validation after boot
ConditionPathExists=/var/lib/pacman/post-upgrade-pending

[Timer]
OnBootSec=30s
Unit=post-upgrade-validation.service

[Install]
WantedBy=timers.target
EOF

# Enable the timer (service runs on-demand)
sudo systemctl daemon-reload
sudo systemctl enable post-upgrade-validation.timer

echo "Post-upgrade validation service installed!"
echo ""
echo "Components installed:"
echo "  • Service: /etc/systemd/system/post-upgrade-validation.service"
echo "  • Timer: /etc/systemd/system/post-upgrade-validation.timer"
echo "  • Hook: /etc/pacman.d/hooks/99-post-upgrade-validation.hook"
echo ""
echo "The validation will run automatically after system upgrades."
echo "To test manually: sudo systemctl start post-upgrade-validation.service"
echo "To view logs: journalctl -u post-upgrade-validation.service"