# ===================================================
# Zsh Configuration - Dotfiles (Universal Terminal Support)
# ===================================================

# -----------------------
# Dotfiles path detection
# -----------------------
DOTFILES_DIR="$HOME/dev/dotfiles"

# Ensure dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "⚠️  Dotfiles directory not found at $DOTFILES_DIR"
  echo "Please run the setup script first."
  return 1
fi

# -----------------------
# Oh-My-Zsh path (always use dotfiles version)
# -----------------------
export ZSH="$DOTFILES_DIR/oh-my-zsh"

# Verify Oh-My-Zsh installation
if [ ! -d "$ZSH" ]; then
  echo "⚠️  Oh-My-Zsh not found in dotfiles. Please run the setup script."
  return 1
fi

# -----------------------
# Powerlevel10k theme (versioned)
# -----------------------
ZSH_THEME="powerlevel10k/powerlevel10k"

# Load p10k config from dotfiles (this ensures consistency everywhere)
if [[ -f "$DOTFILES_DIR/p10k.zsh" ]]; then
  source "$DOTFILES_DIR/p10k.zsh"
else
  echo "⚠️  p10k.zsh not found. Run 'p10k configure' to create it."
fi

# -----------------------
# Plugins (from dotfiles)
# -----------------------
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  # Add any additional plugins you want here
)

# -----------------------
# Initialize Oh-My-Zsh
# -----------------------
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "⚠️  Oh-My-Zsh initialization script not found."
fi

# -----------------------
# PATH configuration
# -----------------------
# Homebrew (Apple Silicon and Intel)
if [[ -d "/opt/homebrew/bin" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
elif [[ -d "/usr/local/bin" ]]; then
  export PATH="/usr/local/bin:$PATH"
fi

# Add any other PATH modifications here
# export PATH="$HOME/.local/bin:$PATH"

# -----------------------
# NVM - Node Version Manager
# -----------------------
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  \. "$NVM_DIR/nvm.sh"  # Load nvm
fi
if [ -s "$NVM_DIR/bash_completion" ]; then
  \. "$NVM_DIR/bash_completion"  # Load nvm bash_completion
fi

# -----------------------
# Terminal configuration
# -----------------------
# Force 256/true colors for better theme support
export TERM="xterm-256color"

# Fix for some terminal color issues
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  export TERM_PROGRAM_VERSION=${TERM_PROGRAM_VERSION:-""}
fi

# -----------------------
# Aliases (add your custom aliases here)
# -----------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

# -----------------------
# Environment variables
# -----------------------

export EDITOR="code"
export BROWSER="open"

# -----------------------
# Completion system optimization
# -----------------------
# Enable completion caching for better performance
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zsh_cache"

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# -----------------------
# History configuration
# -----------------------
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# -----------------------
# Load local customizations (if any)
# -----------------------
# This allows for machine-specific configurations without modifying the main dotfiles
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi