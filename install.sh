#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
DOTFILES="$HOME/dev/dotfiles"
ZSH="$DOTFILES/oh-my-zsh"

# Helper functions
print_header() {
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}🚀 $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}🔧 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the dotfiles directory
if [ "$PWD" != "$DOTFILES" ]; then
    print_error "Please run this script from the dotfiles directory: $DOTFILES"
    print_error "Current directory: $PWD"
    echo ""
    echo "To fix this:"
    echo "  cd $DOTFILES"
    echo "  ./setup.sh"
    exit 1
fi

print_header "DOTFILES SETUP - COMPLETE DEVELOPMENT ENVIRONMENT"

# ------------------------------
# ZSH & TERMINAL SETUP
# ------------------------------
print_header "ZSH & TERMINAL CONFIGURATION"

print_step "Setting up Oh-My-Zsh"
if [ ! -d "$ZSH" ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
    print_success "Oh-My-Zsh installed to $ZSH"
else
    print_success "Oh-My-Zsh already exists"
fi

# Verify the main file exists
if [ ! -f "$ZSH/oh-my-zsh.sh" ]; then
    print_error "Oh-My-Zsh main file not found, reinstalling..."
    rm -rf "$ZSH"
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
    print_success "Oh-My-Zsh reinstalled"
fi

print_step "Setting up Powerlevel10k theme"
if [ ! -d "$ZSH/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH/themes/powerlevel10k"
    print_success "Powerlevel10k theme installed"
else
    print_success "Powerlevel10k theme already exists"
fi

print_step "Setting up Zsh plugins"
for plugin in zsh-autosuggestions zsh-syntax-highlighting zsh-completions; do
    if [ ! -d "$ZSH/plugins/$plugin" ]; then
        git clone "https://github.com/zsh-users/$plugin.git" "$ZSH/plugins/$plugin"
        print_success "Plugin $plugin installed"
    else
        print_success "Plugin $plugin already exists"
    fi
done

# Backup and link zshrc
print_step "Configuring .zshrc"
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
    backup_file="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$HOME/.zshrc" "$backup_file"
    print_warning "Backed up existing .zshrc to $backup_file"
fi

ZSHRC_FILE=""
if [ -f "$DOTFILES/.zshrc" ]; then
    ZSHRC_FILE="$DOTFILES/.zshrc"
elif [ -f "$DOTFILES/zshrc" ]; then
    ZSHRC_FILE="$DOTFILES/zshrc"
else
    print_error "No zshrc file found in dotfiles"
    print_error "Please ensure you have either .zshrc or zshrc in $DOTFILES"
    exit 1
fi

ln -sf "$ZSHRC_FILE" "$HOME/.zshrc"
print_success "Symlinked $ZSHRC_FILE to ~/.zshrc"

# Handle p10k config
if [ -f "$HOME/.p10k.zsh" ] && [ ! -f "$DOTFILES/p10k.zsh" ]; then
    mv "$HOME/.p10k.zsh" "$DOTFILES/p10k.zsh"
    print_success "Moved existing p10k config to dotfiles"
fi

# ------------------------------
# DEVELOPMENT TOOLS
# ------------------------------
print_header "DEVELOPMENT TOOLS SETUP"

print_step "Setting up Homebrew"
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for current session
    if [[ -d "/opt/homebrew/bin" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    elif [[ -d "/usr/local/bin" ]]; then
        export PATH="/usr/local/bin:$PATH"
    fi
    
    print_success "Homebrew installed"
else
    print_success "Homebrew already installed"
fi

# Git Configuration
if [ -f "$DOTFILES/git/setup.sh" ]; then
    print_step "Running Git configuration setup..."
    chmod +x "$DOTFILES/git/setup.sh"
    "$DOTFILES/git/setup.sh"
else
    print_warning "Git setup script not found at $DOTFILES/git/setup.sh"
    print_warning "Git will use default configuration"
fi

print_step "Setting up Node.js environment"
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    print_success "NVM installed"
else
    print_success "NVM already installed"
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! command -v node &> /dev/null; then
    if command -v nvm &> /dev/null; then
        nvm install --lts
        nvm alias default lts/*
        print_success "Node.js LTS installed"
    else
        print_warning "NVM not available in current session"
        print_warning "Please restart terminal and run: nvm install --lts"
    fi
else
    print_success "Node.js already installed ($(node --version))"
fi

if ! command -v pnpm &> /dev/null; then
    if command -v npm &> /dev/null; then
        npm install -g pnpm
        print_success "pnpm installed"
    else
        print_warning "npm not available. Install pnpm manually after Node.js setup"
    fi
else
    print_success "pnpm already installed ($(pnpm --version))"
fi

# ------------------------------
# FONTS
# ------------------------------
print_header "FONT INSTALLATION"

print_step "Installing Fira Code Nerd Font"
is_fira_installed() {
    if ls ~/Library/Fonts/*Fira*Nerd* >/dev/null 2>&1; then
        return 0
    fi
    if command -v fc-list >/dev/null 2>&1; then
        if fc-list | grep -i "fira.*nerd" >/dev/null 2>&1; then
            return 0
        fi
    fi
    return 1
}

if is_fira_installed; then
    print_success "Fira Code Nerd Font already installed"
else
    if command -v brew >/dev/null 2>&1; then
        if brew install font-fira-code-nerd-font >/dev/null 2>&1; then
            print_success "Fira Code Nerd Font installed via Homebrew"
        else
            print_warning "Homebrew method failed. Installing manually..."
            
            FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
            TEMP_DIR=$(mktemp -d)
            ORIGINAL_DIR="$PWD"
            
            cd "$TEMP_DIR"
            if curl -L -f -o FiraCode.zip "$FONT_URL" >/dev/null 2>&1; then
                unzip -q FiraCode.zip
                mkdir -p ~/Library/Fonts
                if ls *.ttf >/dev/null 2>&1; then
                    cp *.ttf ~/Library/Fonts/
                    print_success "Fira Code Nerd Font installed manually"
                else
                    print_warning "No TTF files found in download"
                fi
            else
                print_warning "Failed to download font. Please install manually"
            fi
            
            cd "$ORIGINAL_DIR"
            rm -rf "$TEMP_DIR"
        fi
    else
        print_warning "Homebrew not available. Please install font manually"
    fi
fi

# ------------------------------
# PRODUCTIVITY APPS
# ------------------------------
print_header "PRODUCTIVITY APPLICATIONS"

# Raycast
if [ -f "$DOTFILES/raycast/setup.sh" ]; then
    print_step "Running Raycast setup..."
    chmod +x "$DOTFILES/raycast/setup.sh"
    "$DOTFILES/raycast/setup.sh"
else
    print_warning "Raycast setup script not found at $DOTFILES/raycast/setup.sh"
fi

# Obsidian
if [ -f "$DOTFILES/obsidian/setup.sh" ]; then
    print_step "Running Obsidian setup..."
    chmod +x "$DOTFILES/obsidian/setup.sh"
    "$DOTFILES/obsidian/setup.sh"
else
    print_warning "Obsidian setup script not found at $DOTFILES/obsidian/setup.sh"
fi

# Grammarly Desktop
print_step "Installing Grammarly Desktop..."
if ! ls /Applications/ | grep -q "Grammarly Desktop.app"; then
    if command -v brew &> /dev/null; then
        brew install --cask grammarly-desktop
        print_success "Grammarly Desktop installed"
    else
        print_warning "Homebrew not available. Please install Grammarly Desktop manually"
    fi
else
    print_success "Grammarly Desktop already installed"
fi

# -----------