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
    echo -e "${BLUE}🔧 [Raycast] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ [Raycast] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  [Raycast] $1${NC}"
}

print_error() {
    echo -e "${RED}❌ [Raycast] $1${NC}"
}

print_step "Setting up Raycast as default launcher"

# ------------------------------
# Install Raycast
# ------------------------------
if ! ls /Applications/ | grep -q "Raycast.app"; then
    print_step "Installing Raycast..."
    if command -v brew &> /dev/null; then
        brew install --cask raycast
        print_success "Raycast installed"
    else
        print_error "Homebrew not available. Please install Raycast manually from raycast.com"
        exit 1
    fi
else
    print_success "Raycast already installed"
fi

# ------------------------------
# Disable Spotlight as default launcher
# ------------------------------
print_step "Configuring Spotlight to not interfere with Raycast..."

# Remove Spotlight's ⌘+Space shortcut (it will be assigned to Raycast)
# This command removes the Spotlight shortcut without affecting its indexing
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 '<dict><key>enabled</key><false/></dict>'

print_success "Spotlight ⌘+Space shortcut disabled"

# ------------------------------
# Launch Raycast and set as default
# ------------------------------
print_step "Launching Raycast for initial setup..."

# Launch Raycast
open -a Raycast

# Wait a moment for Raycast to launch
sleep 3

print_success "Raycast launched"

# ------------------------------
# Configure Raycast hotkey (programmatically if possible)
# ------------------------------
print_step "Setting up Raycast hotkey..."

# Try to set the hotkey programmatically
RAYCAST_PLIST="$HOME/Library/Preferences/com.raycast.macos.plist"

if [ -f "$RAYCAST_PLIST" ]; then
    # Set the global hotkey to Command+Space
    defaults write com.raycast.macos globalHotkey -dict-add keyCode -int 49
    defaults write com.raycast.macos globalHotkey -dict-add modifierFlags -int 1048576
    print_success "Raycast hotkey set to ⌘+Space"
else
    print_warning "Raycast preferences not found. Please set hotkey manually:"
    print_warning "1. Open Raycast"
    print_warning "2. Go to Preferences (⌘+,)"
    print_warning "3. Set Global Hotkey to ⌘+Space"
fi

# ------------------------------
# Restart SystemUIServer to apply changes
# ------------------------------
print_step "Applying system changes..."
killall SystemUIServer 2>/dev/null || true
sleep 2

# ------------------------------
# Verify setup
# ------------------------------
print_step "Verifying Raycast setup..."

if pgrep -f "Raycast" > /dev/null; then
    print_success "Raycast is running"
else
    print_warning "Raycast may not be running. Please launch it manually"
fi

# Check if Spotlight shortcut is disabled
SPOTLIGHT_DISABLED=$(defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys | grep -A 5 "64 =" | grep "enabled" | grep "0" || echo "")
if [[ -n "$SPOTLIGHT_DISABLED" ]]; then
    print_success "Spotlight ⌘+Space shortcut is disabled"
else
    print_warning "Spotlight shortcut may still be active"
fi

print_success "Raycast setup complete!"
echo ""
echo -e "${BLUE}Raycast Configuration:${NC}"
echo "📱 App: Installed and launched"
echo "⌨️  Hotkey: ⌘+Space (replacing Spotlight)"
echo "🔍 Spotlight: ⌘+Space disabled, still searchable via other methods"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Press ⌘+Space to test Raycast"
echo "2. Complete any remaining setup prompts in Raycast"
echo "3. Grant necessary permissions when asked"
echo "4. Enjoy your new productivity launcher!"
echo ""
echo -e "${YELLOW}Note:${NC} If ⌘+Space doesn't work immediately, please:"
echo "• Restart your Mac, or"
echo "• Manually set the hotkey in Raycast Preferences"