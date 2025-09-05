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
    exit 1
fi

print_header "DOTFILES SETUP - MODULAR CONFIGURATION"

# ------------------------------
# ZSH & TERMINAL SETUP
# ------------------------------
print_header "ZSH & TERMINAL CONFIGURATION"

print_step "Setting up Oh-My-Zsh"
if [ ! -d "$ZSH" ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
    print_success "Oh-My-Zsh installed"
else
    print_success "Oh-My-Zsh already exists"
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
        print_warning "NVM not available. Please restart terminal and run: nvm install --lts"
    fi
else
    print_success "Node.js already installed ($(node --version))"
fi

if ! command -v pnpm &> /dev/null; then
    if command -v npm &> /dev/null; then
        npm install -g pnpm
        print_success "pnpm installed"
    fi
else
    print_success "pnpm already installed ($(pnpm --version))"
fi

print_step "Setting up Homebrew"
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_success "Homebrew installed"
    
    if [[ -d "/opt/homebrew/bin" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    elif [[ -d "/usr/local/bin" ]]; then
        export PATH="/usr/local/bin:$PATH"
    fi
else
    print_success "Homebrew already installed"
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
                fi
            else
                print_warning "Failed to download font. Please install manually"
            fi
            
            cd "$ORIGINAL_DIR"
            rm -rf "$TEMP_DIR"
        fi
    fi
fi

# ------------------------------
# VS CODE SETUP (MODULAR)
# ------------------------------
print_header "VS CODE CONFIGURATION"

if [ -f "$DOTFILES/vscode/setup.sh" ]; then
    print_step "Running VS Code modular setup..."
    chmod +x "$DOTFILES/vscode/setup.sh"
    "$DOTFILES/vscode/setup.sh"
else
    print_warning "VS Code setup script not found at $DOTFILES/vscode/setup.sh"
    print_warning "Please create the modular VS Code setup"
fi

# ------------------------------
# FINAL SUMMARY
# ------------------------------
print_header "SETUP COMPLETE!"

echo -e "${GREEN}🎉 Dotfiles setup completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Configuration Summary:${NC}"
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ 🐚 Zsh: $ZSHRC_FILE → ~/.zshrc"
echo "│ 🎨 Theme: Powerlevel10k with plugins"
echo "│ 🔧 Tools: NVM, Node.js, pnpm, Homebrew"
echo "│ 🔤 Font: Fira Code Nerd Font"
echo "│ 💻 VS Code: Dracula theme + extensions"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""
echo -e "${BLUE}📁 Dotfiles Structure:${NC}"
echo "📁 $DOTFILES/"
echo "├── 📄 .zshrc (or zshrc)"
echo "├── 📄 p10k.zsh"
echo "├── 📁 vscode/"
echo "│   ├── 📄 settings.json"
echo "│   ├── 📄 extensions.txt"
echo "│   └── 📄 setup.sh"
echo "├── 📄 setup.sh (this script)"
echo "└── 📁 oh-my-zsh/"
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo "1. Close and reopen your terminal (or run 'source ~/.zshrc')"
if [ ! -f "$DOTFILES/p10k.zsh" ]; then
    echo "2. Run 'p10k configure' to set up your Powerlevel10k theme"
fi
echo "3. Your configuration is now consistent across all terminals!"
echo ""
echo -e "${GREEN}Happy coding! 🎯${NC}"