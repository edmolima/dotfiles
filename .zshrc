# ===================================================
# Zsh Configuration - Dotfiles (Universal Terminal Support)
# ===================================================

# -----------------------
# Dotfiles path detection
# -----------------------
DOTFILES_DIR="$HOME/dev/dotfiles"

# Ensure dotfiles directory exists
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Warning: Dotfiles directory not found at $DOTFILES_DIR"
  echo "Please run the setup script first."
  return 1
fi

# -----------------------
# Oh-My-Zsh path (always use dotfiles version)
# -----------------------
export ZSH="$DOTFILES_DIR/oh-my-zsh"

# Verify Oh-My-Zsh installation
if [ ! -d "$ZSH" ]; then
  echo "Warning: Oh-My-Zsh not found in dotfiles. Please run the setup script."
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
  echo "Info: p10k.zsh not found. Run 'p10k configure' to create it."
fi

# -----------------------
# Plugins (from dotfiles)
# -----------------------
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

# -----------------------
# Initialize Oh-My-Zsh
# -----------------------
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
  source "$ZSH/oh-my-zsh.sh"
else
  echo "Error: Oh-My-Zsh initialization script not found at $ZSH/oh-my-zsh.sh"
  echo "Please run: cd ~/dev/dotfiles && ./setup.sh"
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

# Add common development paths
export PATH="$HOME/.local/bin:$PATH"

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
# Aliases
# -----------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git aliases (complement the ones in git config)
alias gst='git status'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gaa='git add .'
alias gcm='git commit -m'
alias gps='git push'
alias gpl='git pull'

# Development aliases
alias code.='code .'
alias serve='python3 -m http.server 8000'
alias reload='source ~/.zshrc'

# -----------------------
# Environment variables
# -----------------------
export EDITOR="code"
export BROWSER="open"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# -----------------------
# Completion system optimization
# -----------------------
# Enable completion caching for better performance
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$HOME/.zsh_cache"

# Case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Better completion for kill command
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# -----------------------
# History configuration
# -----------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# History options
setopt SHARE_HISTORY          # Share history between sessions
setopt HIST_IGNORE_DUPS       # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS   # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS      # Do not display a line previously found
setopt HIST_IGNORE_SPACE      # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS      # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks before recording entry
setopt HIST_VERIFY            # Don't execute immediately upon history expansion

# -----------------------
# Additional Zsh options
# -----------------------
setopt AUTO_CD                # Change to directory without cd
setopt CORRECT                # Correct spelling of commands
setopt CORRECT_ALL            # Correct spelling of all arguments

# -----------------------
# Functions
# -----------------------
# Quick directory creation and navigation
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz) tar xzf "$1" ;;
      *.bz2) bunzip2 "$1" ;;
      *.rar) unrar x "$1" ;;
      *.gz) gunzip "$1" ;;
      *.tar) tar xf "$1" ;;
      *.tbz2) tar xjf "$1" ;;
      *.tgz) tar xzf "$1" ;;
      *.zip) unzip "$1" ;;
      *.Z) uncompress "$1" ;;
      *.7z) 7z x "$1" ;;
      *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Find process by name
findproc() {
  ps aux | grep -i "$1" | grep -v grep
}

# -----------------------
# Load local customizations (if any)
# -----------------------
# This allows for machine-specific configurations without modifying the main dotfiles
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi

# Load any additional custom configurations
if [[ -d "$DOTFILES_DIR/zsh" ]]; then
  for file in "$DOTFILES_DIR/zsh"/*.zsh; do
    [ -r "$file" ] && source "$file"
  done
fi