#!/usr/bin/env bash

# =============================================================================
# Dotfiles Installation Script
# =============================================================================
# Installs and configures terminal environment optimized for Hyprland + Kitty + Zellij
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_DIR="$HOME/dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo -e "\n${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_info() {
    echo -e "${BLUE}  ->${NC} $1"
}

print_success() {
    echo -e "${GREEN}  ✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}  !${NC} $1"
}

print_error() {
    echo -e "${RED}  ✗${NC} $1"
}

backup_file() {
    local file=$1
    if [[ -f "$file" ]] || [[ -L "$file" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$file" "$BACKUP_DIR/"
        print_warning "Backed up existing: $(basename "$file")"
    fi
}

backup_dir() {
    local dir=$1
    if [[ -d "$dir" ]] && [[ ! -L "$dir" ]]; then
        mkdir -p "$BACKUP_DIR"
        mv "$dir" "$BACKUP_DIR/"
        print_warning "Backed up existing directory: $(basename "$dir")"
    fi
}

create_symlink() {
    local source=$1
    local target=$2

    # Backup existing file/link
    backup_file "$target"

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Create symlink
    ln -sf "$source" "$target"
    print_success "Linked: $(basename "$target")"
}

# =============================================================================
# Main Installation
# =============================================================================

echo -e "${GREEN}"
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║              Dotfiles Installation Script                     ║"
echo "║          Terminal Setup for Hyprland + Kitty + Zellij         ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Verify we're in the right directory
if [[ ! -d "$DOTFILES_DIR" ]]; then
    print_error "Dotfiles directory not found at $DOTFILES_DIR"
    exit 1
fi

cd "$DOTFILES_DIR"

# =============================================================================
# Zsh Configuration
# =============================================================================

print_header "Installing Zsh Configuration"
create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

# Set zsh as default shell if not already
if [[ "$SHELL" != */zsh ]]; then
    print_info "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    print_success "Default shell changed to zsh (restart required)"
fi

# =============================================================================
# Starship Prompt
# =============================================================================

print_header "Installing Starship Configuration"
mkdir -p "$HOME/.config"
create_symlink "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"

# =============================================================================
# Kitty Terminal
# =============================================================================

print_header "Installing Kitty Configuration"
mkdir -p "$HOME/.config/kitty"
create_symlink "$DOTFILES_DIR/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"

# =============================================================================
# Zellij
# =============================================================================

print_header "Installing Zellij Configuration"
mkdir -p "$HOME/.config/zellij"
create_symlink "$DOTFILES_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"

# Link layouts directory
backup_dir "$HOME/.config/zellij/layouts"
create_symlink "$DOTFILES_DIR/zellij/layouts" "$HOME/.config/zellij/layouts"

# =============================================================================
# Git Configuration
# =============================================================================

print_header "Installing Git Configuration"
create_symlink "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

# Lazygit
mkdir -p "$HOME/.config/lazygit"
create_symlink "$DOTFILES_DIR/git/lazygit-config.yml" "$HOME/.config/lazygit/config.yml"

# =============================================================================
# Initialize Tools
# =============================================================================

print_header "Initializing Tools"

# Initialize atuin
if command -v atuin &> /dev/null; then
    if [[ ! -f "$HOME/.local/share/atuin/history.db" ]]; then
        print_info "Initializing atuin..."
        atuin init zsh > /dev/null 2>&1 || true
        print_success "Atuin initialized"
    fi
fi

# Initialize zoxide
if command -v zoxide &> /dev/null; then
    print_info "Zoxide is ready (will build database as you navigate)"
    print_success "Zoxide initialized"
fi

# =============================================================================
# Hyprland Integration
# =============================================================================

print_header "Hyprland Integration"

if [[ -f "$HOME/.config/hypr/hyprland.conf" ]]; then
    print_info "Checking Hyprland configuration..."

    # Check if Kitty is set as default terminal
    if ! grep -q "bind.*kitty" "$HOME/.config/hypr/hyprland.conf"; then
        print_warning "Consider adding Kitty as default terminal in hyprland.conf:"
        echo "    bind = \$mod, Return, exec, kitty"
    else
        print_success "Kitty is configured in Hyprland"
    fi
else
    print_warning "Hyprland config not found at ~/.config/hypr/hyprland.conf"
fi

# =============================================================================
# Optional: Install Catppuccin theme for bat
# =============================================================================

print_header "Installing bat theme"
if command -v bat &> /dev/null; then
    mkdir -p "$(bat --config-dir)/themes"
    if [[ ! -f "$(bat --config-dir)/themes/Catppuccin-mocha.tmTheme" ]]; then
        print_info "Downloading Catppuccin theme for bat..."
        wget -q -P "$(bat --config-dir)/themes" \
            https://github.com/catppuccin/bat/raw/main/Catppuccin-mocha.tmTheme \
            2>/dev/null || true
        bat cache --build > /dev/null 2>&1
        print_success "bat theme installed"
    else
        print_success "bat theme already installed"
    fi
fi

# =============================================================================
# Summary
# =============================================================================

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Installation Complete!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

print_header "Next Steps"
echo ""
print_info "1. Restart your terminal or run: source ~/.zshrc"
print_info "2. Configure git user info (if not already done):"
echo "     git config --global user.name \"Your Name\""
echo "     git config --global user.email \"your.email@example.com\""
print_info "3. Start a zellij session:"
echo "     zellij attach -c chosen-local"
print_info "4. Open Kitty and use Ctrl+Shift+T for new tabs"
print_info "5. Use 'j script' to jump to common directories"
echo ""

if [[ -d "$BACKUP_DIR" ]]; then
    print_warning "Old configs backed up to: $BACKUP_DIR"
fi

echo ""
print_header "Workflow Cheatsheet"
echo ""
print_info "Kitty Tabs (big contexts):"
echo "  • Ctrl+Shift+T     - New tab"
echo "  • Ctrl+Shift+←/→   - Switch tabs"
echo "  • Ctrl+Shift+1-5   - Jump to tab"
echo ""
print_info "Zellij Sessions (layouts):"
echo "  • zellij attach -c chosen-local  (or: chosen)"
echo "  • zellij attach -c clients       (or: clients)"
echo "  • zellij attach -c infra         (or: infra)"
echo "  • zellij attach -c scratch       (or: scratch)"
echo ""
print_info "Quick Commands:"
echo "  • lg      - lazygit"
echo "  • cat     - bat (syntax highlighting)"
echo "  • ls      - eza (modern ls)"
echo "  • top     - btop (system monitor)"
echo "  • gpu     - nvtop (GPU monitor)"
echo "  • cc      - claude-code"
echo ""

echo -e "${BLUE}Happy hacking! 🚀${NC}"
echo ""
