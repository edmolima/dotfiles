#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}🔧 [VS Code] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ [VS Code] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  [VS Code] $1${NC}"
}

print_error() {
    echo -e "${RED}❌ [VS Code] $1${NC}"
}

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
VSCODE_USER_DIR="$HOME/Library/Application Support/Code/User"

print_step "Setting up VS Code configuration"

# ------------------------------
# Install VS Code if not present
# ------------------------------
if ! command -v code &> /dev/null; then
    print_warning "VS Code not found. Installing..."
    if command -v brew &> /dev/null; then
        brew install --cask visual-studio-code
        print_success "VS Code installed"
        print_warning "Please run 'Shell Command: Install code command in PATH' in VS Code, then re-run this script"
        exit 0
    else
        print_error "Homebrew not available. Please install VS Code manually"
        exit 1
    fi
fi

# ------------------------------
# Backup existing settings
# ------------------------------
mkdir -p "$VSCODE_USER_DIR"

if [ -f "$VSCODE_USER_DIR/settings.json" ] && [ ! -L "$VSCODE_USER_DIR/settings.json" ]; then
    backup_file="$VSCODE_USER_DIR/settings.json.backup.$(date +%Y%m%d_%H%M%S)"
    mv "$VSCODE_USER_DIR/settings.json" "$backup_file"
    print_warning "Backed up existing settings to $backup_file"
fi

# ------------------------------
# Link settings.json
# ------------------------------
if [ -f "$SCRIPT_DIR/settings.json" ]; then
    ln -sf "$SCRIPT_DIR/settings.json" "$VSCODE_USER_DIR/settings.json"
    print_success "Settings linked from $SCRIPT_DIR/settings.json"
else
    print_error "settings.json not found in $SCRIPT_DIR"
    exit 1
fi

# ------------------------------
# Install extensions
# ------------------------------
print_step "Installing VS Code extensions"

# Check for YAML file first, then fallback to TXT
if [ -f "$SCRIPT_DIR/extensions.yml" ]; then
    print_step "Reading extensions from extensions.yml"
    
    # Extract extension IDs from YAML using grep and awk
    # Look for lines with "- id:" and extract the ID
    grep -E "^\s*-\s*id:\s*" "$SCRIPT_DIR/extensions.yml" | awk '{print $3}' | while read -r ext; do
        if [[ -n "$ext" ]]; then
            if code --list-extensions | grep -q "^$ext$"; then
                print_success "Extension $ext already installed"
            else
                print_step "Installing $ext..."
                if code --install-extension "$ext" --force >/dev/null 2>&1; then
                    print_success "Installed $ext"
                else
                    print_warning "Failed to install $ext"
                fi
            fi
        fi
    done
    
elif [ -f "$SCRIPT_DIR/extensions.txt" ]; then
    print_step "Reading extensions from extensions.txt"
    
    while IFS= read -r line; do
        # Skip empty lines and comments
        if [[ -n "$line" && ! "$line" =~ ^[[:space:]]*# ]]; then
            ext=$(echo "$line" | xargs)  # Trim whitespace
            
            if code --list-extensions | grep -q "^$ext$"; then
                print_success "Extension $ext already installed"
            else
                print_step "Installing $ext..."
                if code --install-extension "$ext" --force >/dev/null 2>&1; then
                    print_success "Installed $ext"
                else
                    print_warning "Failed to install $ext"
                fi
            fi
        fi
    done < "$SCRIPT_DIR/extensions.txt"
    
else
    print_warning "No extensions file found in $SCRIPT_DIR"
    print_warning "Please create either extensions.yml or extensions.txt"
fi

print_success "VS Code setup complete!"
echo ""
echo -e "${BLUE}VS Code Configuration:${NC}"
echo "📄 Settings: $SCRIPT_DIR/settings.json → VS Code"
if [ -f "$SCRIPT_DIR/extensions.yml" ]; then
    echo "🧩 Extensions: Installed from $SCRIPT_DIR/extensions.yml"
elif [ -f "$SCRIPT_DIR/extensions.txt" ]; then
    echo "🧩 Extensions: Installed from $SCRIPT_DIR/extensions.txt"
fi