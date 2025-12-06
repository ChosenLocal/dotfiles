# Smart Upgrade System for Arch Linux

## Overview

The Smart Upgrade System is a comprehensive safety wrapper around `paru` that prevents common upgrade disasters on Arch Linux systems with complex hardware dependencies (NVIDIA, CUDA, multi-monitor setups).

## Features

### 1. Pre-Upgrade Safety Checks
- **Arch News Monitoring**: Checks for manual intervention requirements
- **Critical Package Detection**: Identifies updates to kernel, NVIDIA, CUDA, Hyprland
- **Dependency Analysis**: Warns about kernel/driver mismatches
- **Disk Space Validation**: Ensures sufficient space before upgrading
- **Configuration Backup**: Automatically backs up critical configs

### 2. Intelligent Hooks System
- **Critical Package Warnings**: Pre-transaction alerts for important updates
- **Kernel Backup**: Preserves working kernel before updates
- **NVIDIA Module Rebuild**: Automatically rebuilds modules after kernel changes
- **Cache Cleanup**: Maintains last 3 package versions automatically

### 3. Post-Upgrade Validation
- **GPU Stack Verification**: Validates NVIDIA drivers and CUDA functionality
- **Monitor Configuration**: Ensures all 4 monitors are detected and configured
- **Service Health Checks**: Verifies critical services are running
- **Automatic Recovery**: Attempts to fix common issues automatically
- **Issue Tracking Integration**: Creates tickets for unresolved problems

### 4. Changelog & Audit Trail
- **Automatic Documentation**: Every upgrade logged to ~/codex-sys/changelog/
- **Rollback Instructions**: Each log includes recovery steps
- **Issue Correlation**: Links problems to specific upgrades

## Installation

### Quick Setup (Recommended)
```bash
# The smart-upgrade script is already installed in dotfiles
# Just run these commands to activate all features:

# 1. Install pacman hooks (requires sudo)
~/dotfiles/bin/create-pacman-hooks.sh

# 2. Setup post-upgrade validation service (optional but recommended)
~/dotfiles/bin/setup-validation-service.sh

# 3. Reload shell to get new aliases
source ~/.zshrc
```

### Manual Installation
All scripts are already in `~/dotfiles/bin/`:
- `smart-upgrade` - Main upgrade wrapper
- `post-upgrade-validation` - Validation script
- `create-pacman-hooks.sh` - Hook installer
- `setup-validation-service.sh` - Service installer

## Usage

### Basic Upgrade
```bash
# Run smart system upgrade (replaces 'paru')
upgrade

# Dry-run to see what would be upgraded
upgrade-dry
```

### Advanced Options
```bash
# Skip all safety checks (dangerous!)
smart-upgrade --skip-checks

# Test mode - see what would happen without changes
smart-upgrade --dry-run

# View help
smart-upgrade --help
```

## Workflow Integration

### With Existing Tools
- **Kitty + Zellij**: Run upgrades in dedicated Zellij pane for easy monitoring
- **Issue Tracking**: Automatically creates issues in ~/codex-sys/issues/
- **Changelog**: Logs all upgrades to ~/codex-sys/changelog/YYYY/
- **Monitor Setup**: Validates ~/Desktop/main/scripts/set_hyprland_monitors.sh

### Rollback Procedures

#### If System Won't Boot
1. Select previous kernel from rEFInd boot menu
2. Kernels are backed up to `/boot/backup/`

#### If Graphics Broken
```bash
# Downgrade NVIDIA drivers
sudo pacman -U /var/cache/pacman/pkg/nvidia-open-*.pkg.tar.zst

# Rebuild initramfs
sudo mkinitcpio -P
```

#### If Hyprland Broken
```bash
# Restore config from backup
cp -r ~/.config/upgrade-backups/[latest]/hypr ~/.config/

# Downgrade Hyprland
sudo pacman -U /var/cache/pacman/pkg/hyprland-*.pkg.tar.zst
```

## Configuration Files

### Pacman Hooks Location
- `/etc/pacman.d/hooks/00-critical-package-warning.hook`
- `/etc/pacman.d/hooks/50-kernel-backup.hook`
- `/etc/pacman.d/hooks/60-nvidia-rebuild.hook`
- `/etc/pacman.d/hooks/90-package-cleanup.hook`
- `/etc/pacman.d/hooks/99-post-upgrade-validation.hook`

### Backup Locations
- Configs: `~/.config/upgrade-backups/[timestamp]/`
- Kernels: `/boot/backup/`
- Package lists: In each backup directory

### Log Files
- Upgrade logs: `/tmp/smart-upgrade-[timestamp].log`
- Validation logs: `/var/log/post-upgrade-validation.log`
- Changelogs: `~/codex-sys/changelog/YYYY/`

## Monitoring & Maintenance

### Check Validation Status
```bash
# View last validation run
journalctl -u post-upgrade-validation.service

# Run validation manually
sudo systemctl start post-upgrade-validation.service
```

### Clean Old Backups
```bash
# Remove config backups older than 30 days
find ~/.config/upgrade-backups -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;

# Clean package cache (keeps last 3 versions)
sudo paccache -rk3
```

### View Upgrade History
```bash
# List all upgrades
ls -la ~/codex-sys/changelog/2025/

# Search for specific package upgrades
grep -r "nvidia" ~/codex-sys/changelog/
```

## Troubleshooting

### Smart-upgrade command not found
```bash
# Ensure dotfiles/bin is in PATH
echo $PATH | grep dotfiles

# Reload shell config
source ~/.zshrc
```

### Validation service not running
```bash
# Check service status
systemctl status post-upgrade-validation.timer

# Enable if needed
sudo systemctl enable --now post-upgrade-validation.timer
```

### Hooks not triggering
```bash
# Verify hooks are installed
ls -la /etc/pacman.d/hooks/

# Reinstall hooks
~/dotfiles/bin/create-pacman-hooks.sh
```

## Risk Assessment

### What This System Protects Against
- ✅ Kernel updates breaking NVIDIA drivers
- ✅ Hyprland compositor failures
- ✅ Multi-monitor configuration loss
- ✅ CUDA stack incompatibilities
- ✅ Insufficient disk space during upgrade
- ✅ Critical service failures

### What It Doesn't Protect Against
- ❌ Hardware failures
- ❌ Filesystem corruption
- ❌ Manual package removals
- ❌ AUR package build failures
- ❌ Network interruptions during download

## Future Enhancements

### Planned Features
1. **Snapshot Integration**: BTRFS/ZFS snapshot support when available
2. **Remote Monitoring**: Send upgrade status to phone/email
3. **AI Analysis**: Use LLM to analyze failure patterns
4. **Automatic Rollback**: Full system state recovery
5. **Package Pinning**: Prevent specific packages from upgrading

### Integration Opportunities
- **n8n Workflows**: Trigger upgrade notifications
- **Grafana Metrics**: Track upgrade success rates
- **Ansible Playbooks**: Multi-machine upgrade orchestration

## Contributing

This system is maintained as part of the Codex ecosystem. To suggest improvements:

1. Document issues in `~/codex-sys/issues/`
2. Test changes in `scratch` Zellij context
3. Update this documentation when modifying scripts
4. Keep changelog entries for all modifications

## Support

For issues or questions:
- Check `~/codex-sys/issues/` for known problems
- Review logs in `/tmp/smart-upgrade-*.log`
- Consult the Arch Wiki for package-specific issues

---

*Smart Upgrade System v1.0.0 - Designed for Jack's Arch Linux workstation*
*Part of the Codex System Assistant ecosystem*