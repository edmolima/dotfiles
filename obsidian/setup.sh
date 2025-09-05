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
    echo -e "${BLUE}🔧 [Obsidian] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ [Obsidian] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  [Obsidian] $1${NC}"
}

print_error() {
    echo -e "${RED}❌ [Obsidian] $1${NC}"
}

print_step "Setting up Obsidian"

# ------------------------------
# Install Obsidian
# ------------------------------
print_step "Checking if Obsidian is installed..."

if [ ! -d "/Applications/Obsidian.app" ]; then
    print_step "Installing Obsidian..."
    if command -v brew &> /dev/null; then
        # Try the installation and show output for debugging
        if brew install --cask obsidian; then
            print_success "Obsidian installed successfully"
        else
            print_error "Failed to install Obsidian via Homebrew"
            print_step "Trying alternative installation method..."
            # Alternative: direct download
            OBSIDIAN_URL="https://github.com/obsidianmd/obsidian-releases/releases/latest/download/Obsidian-universal.dmg"
            TEMP_DIR=$(mktemp -d)
            cd "$TEMP_DIR"
            
            print_step "Downloading Obsidian..."
            if curl -L -o "Obsidian.dmg" "$OBSIDIAN_URL"; then
                print_step "Mounting DMG and installing..."
                hdiutil attach "Obsidian.dmg" -quiet
                cp -R "/Volumes/Obsidian/Obsidian.app" "/Applications/"
                hdiutil detach "/Volumes/Obsidian" -quiet
                rm -rf "$TEMP_DIR"
                print_success "Obsidian installed manually"
            else
                print_error "Failed to download Obsidian"
                rm -rf "$TEMP_DIR"
                exit 1
            fi
        fi
    else
        print_error "Homebrew not available. Please install Obsidian manually from obsidian.md"
        exit 1
    fi
else
    print_success "Obsidian already installed"
fi

# Verify installation
if [ -d "/Applications/Obsidian.app" ]; then
    print_success "Obsidian installation verified"
else
    print_error "Obsidian installation failed"
    exit 1
fi

# ------------------------------
# Create default vault directory
# ------------------------------
print_step "Setting up default vault location"

VAULT_DIR="$HOME/Documents/Obsidian"
if [ ! -d "$VAULT_DIR" ]; then
    mkdir -p "$VAULT_DIR"
    print_success "Created vault directory at $VAULT_DIR"
else
    print_success "Vault directory already exists at $VAULT_DIR"
fi

# ------------------------------
# Launch Obsidian
# ------------------------------
if ! pgrep -f "Obsidian" > /dev/null; then
    print_step "Launching Obsidian..."
    open -a Obsidian
    print_success "Obsidian launched"
else
    print_success "Obsidian is already running"
fi

print_success "Obsidian setup complete!"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Create or open a vault in $VAULT_DIR"
echo "2. Configure your preferred theme and settings"
echo "3. Install any desired community plugins"
echo "4. Start organizing your knowledge!"