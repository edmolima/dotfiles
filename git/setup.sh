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
    echo -e "${BLUE}🔧 [Git] $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ [Git] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  [Git] $1${NC}"
}

print_error() {
    echo -e "${RED}❌ [Git] $1${NC}"
}

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_step "Setting up Git configuration"

# ------------------------------
# Check if Git is installed
# ------------------------------
if ! command -v git &> /dev/null; then
    print_error "Git is not installed. Installing via Xcode Command Line Tools..."
    xcode-select --install
    print_warning "Please complete Xcode Command Line Tools installation and re-run this script"
    exit 1
fi

print_success "Git is installed ($(git --version))"

# ------------------------------
# Configure Git user
# ------------------------------
print_step "Configuring Git user information"

# Check if user.name is already set
CURRENT_NAME=$(git config --global user.name 2>/dev/null || echo "")
CURRENT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

if [ -n "$CURRENT_NAME" ] && [ -n "$CURRENT_EMAIL" ]; then
    print_success "Git user already configured:"
    echo "  Name: $CURRENT_NAME"
    echo "  Email: $CURRENT_EMAIL"
    
    read -p "Do you want to update the configuration? (y/N): " -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_success "Keeping existing Git configuration"
        exit 0
    fi
fi

# Get user information
echo ""
echo -e "${BLUE}Please enter your Git configuration:${NC}"

if [ -z "$CURRENT_NAME" ]; then
    read -p "Full Name: " GIT_NAME
else
    read -p "Full Name [$CURRENT_NAME]: " GIT_NAME
    GIT_NAME=${GIT_NAME:-$CURRENT_NAME}
fi

if [ -z "$CURRENT_EMAIL" ]; then
    read -p "Email: " GIT_EMAIL
else
    read -p "Email [$CURRENT_EMAIL]: " GIT_EMAIL
    GIT_EMAIL=${GIT_EMAIL:-$CURRENT_EMAIL}
fi

# Validate inputs
if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    print_error "Name and email are required"
    exit 1
fi

# Set Git configuration
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

print_success "Git user configured:"
echo "  Name: $GIT_NAME"
echo "  Email: $GIT_EMAIL"

# ------------------------------
# Configure Git settings
# ------------------------------
print_step "Configuring Git settings"

# Core settings
git config --global init.defaultBranch main
git config --global core.editor "code --wait"
git config --global core.autocrlf input
git config --global core.safecrlf warn

# Push settings
git config --global push.default simple
git config --global push.autoSetupRemote true

# Pull settings
git config --global pull.rebase false

# Color settings
git config --global color.ui auto
git config --global color.branch.current "yellow reverse"
git config --global color.branch.local yellow
git config --global color.branch.remote green
git config --global color.diff.meta "yellow bold"
git config --global color.diff.frag "magenta bold"
git config --global color.diff.old "red bold"
git config --global color.diff.new "green bold"
git config --global color.status.added yellow
git config --global color.status.changed green
git config --global color.status.untracked cyan

print_success "Git settings configured"

# ------------------------------
# Configure useful aliases
# ------------------------------
print_step "Setting up Git aliases"

# Status and log aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage "reset HEAD --"
git config --global alias.last "log -1 HEAD"
git config --global alias.visual "!gitk"

# Advanced aliases
git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
git config --global alias.lga "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
git config --global alias.tree "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"

print_success "Git aliases configured"

# ------------------------------
# Setup SSH key if needed
# ------------------------------
print_step "Checking SSH key for Git"

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo ""
    read -p "Do you want to generate an SSH key for Git? (y/N): " -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Generating SSH key..."
        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY_PATH" -N ""
        
        # Add to ssh-agent
        eval "$(ssh-agent -s)"
        ssh-add "$SSH_KEY_PATH"
        
        print_success "SSH key generated at $SSH_KEY_PATH"
        print_warning "Add this public key to your Git provider (GitHub, GitLab, etc.):"
        echo ""
        cat "${SSH_KEY_PATH}.pub"
        echo ""
        print_warning "The key has been copied to clipboard (if pbcopy is available)"
        cat "${SSH_KEY_PATH}.pub" | pbcopy 2>/dev/null || true
    fi
else
    print_success "SSH key already exists at $SSH_KEY_PATH"
fi

print_success "Git setup complete!"
echo ""
echo -e "${BLUE}Git Configuration Summary:${NC}"
echo "📧 User: $GIT_NAME <$GIT_EMAIL>"
echo "🌿 Default branch: main"
echo "📝 Editor: VS Code"
echo "🎨 Colors: enabled"
echo "⚡ Aliases: configured"
echo ""
echo -e "${BLUE}Useful Git aliases:${NC}"
echo "  git st    → git status"
echo "  git co    → git checkout"
echo "  git br    → git branch"
echo "  git ci    → git commit"
echo "  git lg    → pretty log with graph"
echo "  git tree  → full repository tree"