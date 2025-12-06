# =============================================================================
# Terminal Configuration - Optimized for Hyprland + Kitty + Zellij
# =============================================================================

# -----------------------------------------------------------------------------
# Core Shell Configuration
# -----------------------------------------------------------------------------
HISTFILE=~/.histfile
HISTSIZE=20000
SAVEHIST=20000
setopt extended_history       # record timestamps
setopt inc_append_history     # write incrementally
bindkey -e  # Emacs keybindings

# Share history across sessions
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_verify

# -----------------------------------------------------------------------------
# Completion System
# -----------------------------------------------------------------------------
zstyle :compinstall filename '/home/jack/.zshrc'
autoload -Uz compinit
# cache compinit to speed startup
if [[ ! -d ~/.cache/zsh ]]; then
    mkdir -p ~/.cache/zsh
fi
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
compinit -C -d "$ZSH_COMPDUMP"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZSH_COMPDUMP}"

# Load additional completions
fpath=(/usr/share/zsh/site-functions $fpath)

# -----------------------------------------------------------------------------
# Path Configuration
# -----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# -----------------------------------------------------------------------------
# API Keys & Secrets
# -----------------------------------------------------------------------------
# Load secrets from external file (not tracked in git)
# Create ~/.secrets with your API keys:
#   export ANTHROPIC_API_KEY="your-key-here"
# Or use 1Password CLI: eval $(op signin) && export ANTHROPIC_API_KEY=$(op read "op://Private/Anthropic API/credential")
if [ -f ~/.secrets ]; then
    source ~/.secrets
fi

# -----------------------------------------------------------------------------
# Plugin Loading
# -----------------------------------------------------------------------------
# zsh-syntax-highlighting (must be loaded last)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# zsh-autosuggestions
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh

# -----------------------------------------------------------------------------
# Modern CLI Aliases
# -----------------------------------------------------------------------------
# File operations
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first'
alias la='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --group-directories-first'
alias tree='eza --tree --icons'

# File viewing
alias cat='bat --style=auto'
alias less='bat --style=auto --paging=always'

# File searching
alias find='fd'
alias grep='rg'

# Disk usage
alias df='duf'
alias du='gdu'

# Git shortcuts
alias g='git'
alias lg='lazygit'
alias gst='git status'
alias gco='git checkout'
alias gcm='git commit -m'
alias gp='git push'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate'

# System monitoring
alias top='btop'
alias htop='btop'
alias gpu='nvtop'

# Network tools
alias http='httpie'
alias ping='ping -c 5'

# Misc
alias c='clear'
alias q='exit'
alias reload='source ~/.zshrc'

# System upgrade (smart-upgrade wrapper)
alias upgrade='smart-upgrade'
alias upgrade-dry='smart-upgrade --dry-run'

# -----------------------------------------------------------------------------
# Navigation Tools
# -----------------------------------------------------------------------------
# Zoxide (better cd)
eval "$(zoxide init zsh)"
alias cd='z'

# fzf integration
eval "$(fzf --zsh)"
# default fzf look/feel
export FZF_DEFAULT_OPTS='--layout=reverse --border --height=60%'

# Custom fzf bindings
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# fzf preview with bat
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Atuin (shell history)
eval "$(atuin init zsh)"

# -----------------------------------------------------------------------------
# Custom j Function (directory shortcuts)
# -----------------------------------------------------------------------------
j() {
    case "$1" in
        main)
            cd ~/Desktop/main
            ;;
        script|scripts)
            cd ~/Desktop/main/scripts
            ;;
        dot|dotfiles)
            cd ~/dotfiles
            ;;
        chosen|local|chosen-local)
            cd ~/chosen-local  # Update path as needed
            ;;
        clsoftware)
            cd ~/Desktop/main/ChosenLocal/mySoftware
            ;;
        codex)
            cd ~/codex-sys
            ;;
        ai)
            cd /srv/ai
            ;;
        aim|ai-models)
            cd /srv/ai/models
            ;;
        aid|ai-datasets)
            cd /srv/ai/datasets
            ;;
        aic|ai-cache)
            cd /srv/ai/cache
            ;;
        aiw|ai-workspaces)
            cd /srv/ai/workspaces
            ;;
        *)
            # Fall back to zoxide
            z "$@"
            ;;
    esac
}

# AI Scratch Drive Shortcuts
alias ai='cd /srv/ai'
alias aim='cd /srv/ai/models'
alias aid='cd /srv/ai/datasets'
alias aic='cd /srv/ai/cache'
alias aiw='cd /srv/ai/workspaces'

# -----------------------------------------------------------------------------
# AI Scratch Drive Configuration
# -----------------------------------------------------------------------------

# HuggingFace cache on scratch drive
export HF_HOME="/srv/ai/hf"

# XDG cache redirection to scratch drive
export XDG_CACHE_HOME="/srv/ai/xdg-cache"

# vLLM cache directory
export VLLM_CACHE_DIR="/srv/ai/vllm_cache"

# Ollama models (optional - system service uses /var/lib/ollama)
# export OLLAMA_MODELS="/srv/ai/ollama/models"

# -----------------------------------------------------------------------------
# Development Tools
# -----------------------------------------------------------------------------
# mise (runtime management)
eval "$(mise activate zsh)"

# direnv (per-project env vars)
eval "$(direnv hook zsh)"

# 1Password CLI helper
op_signin() {
    eval "$(op signin --account my.1password.com "$@")"
}
alias opsi='op_signin'

# -----------------------------------------------------------------------------
# Zellij Integration
# -----------------------------------------------------------------------------
# Auto-attach to zellij session based on context
# Disabled by default - uncomment to enable auto-attach
# if [[ -z "$ZELLIJ" ]]; then
#     if [[ "$PWD" == *"chosen-local"* ]]; then
#         zellij attach -c chosen-local
#     elif [[ "$PWD" == *"clients"* ]]; then
#         zellij attach -c clients
#     elif [[ "$PWD" == *"infra"* ]] || [[ "$PWD" == *"servers"* ]]; then
#         zellij attach -c infra
#     fi
# fi

# Zellij shortcuts
alias zj='zellij'
alias zjl='zellij list-sessions'
alias zja='zellij attach'
alias zjc='zellij attach -c'

# Quick session launchers
alias chosen='zellij attach -c chosen-local'
alias clients='zellij attach -c clients'
alias infra='zellij attach -c infra'
alias scratch='zellij attach -c scratch'

# -----------------------------------------------------------------------------
# Kitty Integration
# -----------------------------------------------------------------------------
# Rename current Kitty tab
alias ktab='kitty @ set-tab-title'

# -----------------------------------------------------------------------------
# AI/LLM Integration
# -----------------------------------------------------------------------------
alias cc='claude-code'
alias ollama='ollama'

# LLM Model Shortcuts
alias llm-qwen3='ollama run qwen3:32b-q4_K_M'
alias llm-qwen3code='ollama run qwen3-coder:30b-a3b-q4_K_M'
alias llm-deepseekr1='ollama run deepseek-r1:32b'

# Voxtral Audio Processing (vLLM)
alias voxtral-start='voxtral start'
alias voxtral-stop='voxtral stop'
alias voxtral-status='voxtral status'
alias transcribe='voxtral transcribe'

# Shortcut to launch Codex CLI in codex-sys with network sandbox enabled
codex-access() {
    codex --cd /home/jack/codex-sys -c 'sandbox_permissions=["network"]' --sandbox workspace-write "$@"
}

# Codex wrapper: fall back to OpenAI key from 1Password when plan/quota is hit
codex-flex() {
    local log status
    log="$(mktemp -t codex-flex.XXXXXX)"

    if codex "$@" 2>"$log"; then
        rm -f "$log"
        return 0
    fi

    if rg -qi 'plan|quota|usage' "$log"; then
        echo "Plan exhausted, retrying with OpenAI key via 1Password..." >&2
        op run --env "OPENAI_API_KEY=op://Private/OPENAI/credential" -- \
            codex --provider openai "$@" 2>>"$log"
        status=$?
    else
        status=1
    fi

    if (( status != 0 )); then
        cat "$log" >&2
    fi

    rm -f "$log"
    return $status
}
alias cflex='codex-flex'

# cht.sh (cheatsheets)
cht() {
    curl -s "cht.sh/$1"
}

# -----------------------------------------------------------------------------
# Yazi File Manager Integration
# -----------------------------------------------------------------------------
# Change directory on quit
function yy() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# -----------------------------------------------------------------------------
# Smart Upgrade System
# -----------------------------------------------------------------------------
alias upgrade='~/dotfiles/bin/smart-upgrade'
alias upgrade-dry='~/dotfiles/bin/smart-upgrade --dry-run'

# -----------------------------------------------------------------------------
# Starship Prompt (must be at end)
# -----------------------------------------------------------------------------
eval "$(starship init zsh)"

# -----------------------------------------------------------------------------
# Local Overrides
# -----------------------------------------------------------------------------
# Source local config if it exists (not tracked in dotfiles)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
