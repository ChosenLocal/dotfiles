# Hyprland Integration Guide

This guide shows how to integrate the terminal stack with Hyprland for optimal workflow.

## Workspace Layout Philosophy

**Workspace 1: Company Dev (chosen-local)**
- Primary development work
- Kitty → zellij session "chosen-local"
- Layout: Editor | Dev Server + lazygit

**Workspace 2: Client Projects**
- Client work (Olimpia's, Raylyn, etc.)
- Kitty → zellij session "clients"
- Layout: Editor | Dev Server + lazygit

**Workspace 3: Infrastructure**
- Servers, homelab, networking
- Kitty → zellij session "infra"
- Layout: Shell | btop + nvtop + logs

**Workspace 4: AI & Notes**
- Claude Code, experiments, documentation
- Kitty → zellij session "scratch"
- Layout: Main shell | Quick commands

## Recommended Hyprland Keybindings

Add these to your `~/.config/hypr/hyprland.conf`:

```conf
# =============================================================================
# Terminal & Workspace Configuration
# =============================================================================

# Set Kitty as default terminal
$terminal = kitty

# Mod key (Super/Windows key)
$mod = SUPER

# Basic terminal launch
bind = $mod, Return, exec, $terminal

# Context-aware terminal launch (with zellij sessions)
bind = $mod SHIFT, 1, exec, $terminal -e zellij attach -c chosen-local
bind = $mod SHIFT, 2, exec, $terminal -e zellij attach -c clients
bind = $mod SHIFT, 3, exec, $terminal -e zellij attach -c infra
bind = $mod SHIFT, 4, exec, $terminal -e zellij attach -c scratch

# Quick launch monitoring dashboard
bind = $mod SHIFT, M, exec, $terminal -e btop

# Quick launch file manager
bind = $mod SHIFT, F, exec, $terminal -e yazi

# Workspace switching (standard Hyprland)
bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod, 4, workspace, 4
bind = $mod, 5, workspace, 5

# Move window to workspace
bind = $mod ALT, 1, movetoworkspace, 1
bind = $mod ALT, 2, movetoworkspace, 2
bind = $mod ALT, 3, movetoworkspace, 3
bind = $mod ALT, 4, movetoworkspace, 4
bind = $mod ALT, 5, movetoworkspace, 5

# Scratchpad for quick terminal access
bind = $mod, grave, togglespecialworkspace, terminal
bind = $mod SHIFT, grave, movetoworkspace, special:terminal

# Window rules for Kitty
windowrulev2 = opacity 0.90 0.90,class:^(kitty)$
windowrulev2 = tile,class:^(kitty)$
```

## Workspace-Specific Startup

You can auto-start specific zellij sessions on workspace switch:

```conf
# Auto-launch contexts when switching to empty workspaces
workspace = 1, on-created-empty:kitty -e zellij attach -c chosen-local
workspace = 2, on-created-empty:kitty -e zellij attach -c clients
workspace = 3, on-created-empty:kitty -e zellij attach -c infra
workspace = 4, on-created-empty:kitty -e zellij attach -c scratch
```

## Waybar Integration (Optional)

If using Waybar, add workspace indicators:

```json
{
  "hyprland/workspaces": {
    "format": "{icon}",
    "format-icons": {
      "1": "󰨞",  // Company dev
      "2": "󰃖",  // Clients
      "3": "󰒋",  // Infrastructure
      "4": "󰧮",  // AI/Scratch
      "active": "",
      "default": ""
    }
  }
}
```

## Quick Reference Card

Create a cheatsheet widget or keep this reference handy:

### Terminal Workflow
| Action | Keybind |
|--------|---------|
| New terminal | `Super + Enter` |
| Launch chosen-local | `Super + Shift + 1` |
| Launch clients | `Super + Shift + 2` |
| Launch infra | `Super + Shift + 3` |
| Launch scratch | `Super + Shift + 4` |
| System monitor | `Super + Shift + M` |
| File manager | `Super + Shift + F` |
| Scratchpad terminal | `Super + ~` |

### Inside Kitty
| Action | Keybind |
|--------|---------|
| New tab | `Ctrl + Shift + T` |
| Next tab | `Ctrl + Shift + →` |
| Previous tab | `Ctrl + Shift + ←` |
| Go to tab 1-5 | `Ctrl + Shift + 1-5` |
| Close tab | `Ctrl + Shift + Q` |

### Inside Zellij
| Action | Keybind |
|--------|---------|
| Command mode | `Ctrl + Space` |
| New pane | `Alt + N` |
| Focus left | `Alt + H` or `Alt + ←` |
| Focus right | `Alt + L` or `Alt + →` |
| Focus up | `Alt + K` or `Alt + ↑` |
| Focus down | `Alt + J` or `Alt + ↓` |
| Quit | `Ctrl + Q` |

## Tips

1. **Name your Kitty tabs**: `Ctrl+Shift+Alt+T` lets you set custom tab names
2. **Persistent sessions**: Zellij sessions survive terminal restarts
3. **Quick directory jumps**: Use `j script`, `j dot`, `j chosen`
4. **File manager in split**: Open yazi in a zellij pane for quick file ops
5. **Monitoring dashboard**: Keep infra workspace with btop/nvtop always visible

## Customization

To customize workspace behavior, edit:
- Zellij layouts: `~/dotfiles/zellij/layouts/*.kdl`
- Kitty config: `~/dotfiles/kitty/kitty.conf`
- Shell aliases: `~/dotfiles/zsh/.zshrc`
