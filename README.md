# Dotfiles

Personal terminal configuration optimized for Hyprland + Kitty + Zellij workflow.

## Structure

```
dotfiles/
├── zsh/           # Zsh configuration, plugins, aliases
├── kitty/         # Kitty terminal config
├── zellij/        # Zellij config and session layouts
│   └── layouts/   # Session layouts (chosen-local, clients, infra, scratch)
├── starship/      # Starship prompt config
├── git/           # Git config, delta, lazygit
├── btop/          # btop monitoring config
├── hypr/          # Hyprland keybindings and integration
├── bin/           # Custom scripts and tools
└── install.sh     # Bootstrap script
```

## Installation

```bash
cd ~/dotfiles
./install.sh
```

## Philosophy

**Kitty tabs** = "Which world am I in?" (big contexts: company, clients, infra, scratch)
**Zellij sessions** = "How is this world laid out?" (panes for editor, dev server, lazygit)

## Tools Included

- **Shell**: zsh with starship prompt
- **Navigation**: zoxide, atuin, fzf
- **CLI tools**: eza, bat, fd, ripgrep, sd, gdu, jq, yq
- **Multiplexing**: zellij (inside Kitty tabs)
- **Git**: lazygit, delta, gh
- **Dev**: mise, direnv, just
- **Monitoring**: btop, nvtop, duf
- **File manager**: yazi
- **Networking**: httpie, mtr, nmap, dog
