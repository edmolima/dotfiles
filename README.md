# Dotfiles - Development Environment Setup

A modular and automated setup for macOS development environment with terminal, productivity apps, and coding tools.

## Quick Start

```bash
# Clone the repository
git clone <your-repo-url> ~/dev/dotfiles
cd ~/dev/dotfiles

# Run the setup
chmod +x setup.sh
./setup.sh
```

## What Gets Installed

### Terminal & Shell
- **Zsh** with Oh-My-Zsh framework
- **Powerlevel10k** theme for beautiful prompts
- **Plugins**: autosuggestions, syntax highlighting, completions
- **Fira Code Nerd Font** for programming ligatures

### Development Tools
- **Homebrew** package manager
- **NVM** for Node.js version management
- **Node.js LTS** with npm
- **pnpm** for faster package management

### Productivity Apps
- **Raycast** as default launcher (replaces Spotlight)
- **Obsidian** for knowledge management
- **Grammarly Desktop** for writing assistance

### Code Editor
- **VS Code** with Dracula theme
- **Essential extensions** for web development
- **Configured settings** for optimal coding experience

## Project Structure

```
~/dev/dotfiles/
├── setup.sh                    # Main setup script
├── .zshrc                      # Zsh configuration
├── p10k.zsh                    # Powerlevel10k config
├── raycast/
│   └── setup.sh               # Raycast installation
├── obsidian/
│   └── setup.sh               # Obsidian setup
├── vscode/
│   ├── setup.sh               # VS Code setup
│   ├── settings.json          # VS Code configuration
│   ├── extensions.yml         # Extensions list
│   └── fix.sh                 # VS Code repair tool
└── oh-my-zsh/                 # Auto-generated
```

## Individual Module Setup

### VS Code Only
```bash
cd ~/dev/dotfiles/vscode
./setup.sh
```

### Raycast Only
```bash
cd ~/dev/dotfiles/raycast
./setup.sh
```

### Obsidian Only
```bash
cd ~/dev/dotfiles/obsidian
./setup.sh
```

## Configuration Management

### VS Code Extensions
Edit `vscode/extensions.yml` to add or remove extensions:

```yaml
extensions:
  theme:
    - id: dracula-theme.theme-dracula
      name: "Dracula Official"
```

Then run:
```bash
./vscode/setup.sh
```

### VS Code Settings
Modify `vscode/settings.json` and re-run the setup to apply changes.

### Terminal Configuration
- Edit `.zshrc` for shell customization
- Run `p10k configure` to customize the theme
- Changes are automatically symlinked to `~/.zshrc`

## Troubleshooting

### VS Code Issues
If VS Code becomes corrupted or extensions fail to install:

```bash
cd ~/dev/dotfiles/vscode
./fix.sh
```

### Raycast Not Working
If Command+Space doesn't open Raycast:
1. Open Raycast manually
2. Go to Preferences
3. Set Global Hotkey to Command+Space
4. Grant necessary permissions

### Font Issues
If the terminal font doesn't look right:
1. Restart your terminal
2. Check VS Code terminal font settings
3. Re-run the setup if needed

### NVM/Node Issues
If Node.js commands aren't working:
```bash
source ~/.zshrc
nvm install --lts
nvm use --lts
```

## Customization

### Adding New Apps
1. Create a new directory: `mkdir ~/dev/dotfiles/myapp`
2. Create setup script: `touch ~/dev/dotfiles/myapp/setup.sh`
3. Add to main setup.sh in the productivity apps section

### Modifying Existing Setups
Each module is independent. Modify the individual setup scripts as needed without affecting others.

## Prerequisites

- macOS (tested on latest versions)
- Internet connection for downloads
- Admin privileges for app installations

## What the Setup Does

1. **Installs Homebrew** if not present
2. **Configures terminal** with Zsh and Powerlevel10k
3. **Sets up development tools** (Node.js, pnpm)
4. **Installs productivity apps** (Raycast, Obsidian, Grammarly)
5. **Configures VS Code** with theme and extensions
6. **Creates symlinks** for configuration files
7. **Backs up existing** configurations safely

## Safety Features

- **Automatic backups** of existing configurations
- **Idempotent scripts** - safe to run multiple times
- **Modular design** - install only what you need
- **Error handling** with fallback methods
- **Verification steps** to ensure successful installation

## Contributing

To add new features or fix issues:

1. Test changes thoroughly
2. Maintain the modular structure
3. Add appropriate error handling
4. Update this README if needed

## License

This project is for personal use. Modify and distribute as needed.

---

**Note**: This setup is optimized for web development workflows. Adjust configurations based on your specific needs.