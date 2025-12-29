# macOS Setup Guide

Executable documentation for setting up a fresh macOS system. Follow sections in order for optimal setup experience.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Terminal Environment](#terminal-environment)
- [Essential Apps](#essential-apps)
- [Communication & Media](#communication--media)
- [Final Steps](#final-steps)

---

## Prerequisites

### Install Xcode Command Line Tools & accept terms

```bash
xcode-select --install && sudo xcodebuild -license accept
```

### Install Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update && brew upgrade
```

---

## Terminal Environment

### 1. Install Ghostty

```bash
brew install --cask ghostty
```
### 2. Configure Zsh

```bash
chsh -s $(which zsh)
```

### 3. Configure Git

```bash
git config --global user.name "Felipe Moraes Piacsek"
read "git_email?Enter your git email: "
git config --global user.email "$git_email"
```

### 4. Clone and Link Dotfiles
Clone the dotfiles repository and set up symlinks:

```bash
# Clone dotfiles repo
cd $HOME
git clone https://github.com/piacsek/dotfiles.git

ln -sf $HOME/dotfiles/nvim $HOME/.config/nvim
ln -sf $HOME/dotfiles/.ideavimrc $HOME/.ideavimrc
ln -sf $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/.ghosttyrc $HOME/.config/ghostty/config
```

### 5. Set Up Dotfiles Auto-Sync

Install fswatch and set up the auto-sync service to automatically commit and push dotfile changes:

```bash
# Install fswatch for monitoring file changes
brew install fswatch

# Create symlink for LaunchAgent
ln -sf $HOME/dotfiles/com.dotfiles.sync.plist $HOME/Library/LaunchAgents/com.dotfiles.sync.plist

# Load and start the service
launchctl load $HOME/Library/LaunchAgents/com.dotfiles.sync.plist
launchctl start com.dotfiles.sync
```

Verify the service is running:

```bash
launchctl list | grep dotfiles
```

### 6. Install Common CLI Tools

```bash
brew install \
  neovim \
  fzf \
  ripgrep \
  fd \
  bat
```

### 7. Install asdf

Install asdf and common language plugins:

```bash
brew install asdf && source ~/.zshrc

asdf plugin add elixir
asdf plugin add erlang
asdf plugin add nodejs
asdf plugin add python
asdf plugin add ruby
asdf plugin add postgres
asdf plugin add yarn
asdf plugin add lua
asdf plugin add java
asdf plugin add k9s
asdf plugin add vault
asdf plugin add gcloud
asdf plugin add rebar
asdf plugin add teleport-community

# Install Node.js and set as global
asdf install nodejs 24.12.0
asdf global nodejs 24.12.0

# Install Claude CLI globally
npm install -g @anthropic-ai/claude-code
```

---

## Essential Apps

### 1Password
Password manager.

```bash
brew install --cask 1password
```

### rcmd

```bash
# Visit: https://lowtechguys.com/rcmd/
# Download and install manually, or:
brew install --cask rcmd
```

**Remember to import your rcmd.json settings after installation.**

### Rectangle

```bash
brew install --cask rectangle
```

**Remember to import your RectangleConfig.json settings after installation.**

### Chrome
Web browser.

```bash
brew install --cask google-chrome
```

### Pasty

```bash
# Visit: https://getpasty.app/
# Download from website or Mac App Store
```

### Stats

```bash
brew install --cask stats
```

### Cleanshot

```bash
brew install --cask cleanshot
```

### Docker

```bash
brew install --cask docker
```

---

## Communication & Media

### Slack

```bash
brew install --cask slack
```

### Spotify

```bash
brew install --cask spotify
```

### WhatsApp

```bash
brew install --cask whatsapp
```

---

## Final Steps

### macOS System Preferences

#### Dock Settings

```bash
# Enable auto-hide
defaults write com.apple.dock autohide -bool true && killall Dock
```

#### Manual Settings
Configure these settings manually:

- **Login Items**: System Settings > General > Login Items
  - Add Stats
  - Add Cleanshot
  - Add Docker

### Launch and Configure Apps

```bash
# Open apps to complete setup
open -a Ghostty
open -a rcmd
open -a Stats
open -a Pasty
```

### Verify Installations

```bash
# Check Homebrew installations
brew list --cask

# Check CLI tools
which git zsh fzf rg fd bat eza
```

---

## Notes

- Run `brew update && brew upgrade` regularly to keep packages updated
- Some apps may require manual configuration on first launch
- Add license keys for paid apps (rcmd, Cleanshot, Pasty)
- Restart terminal after major changes to environment

---

**Last Updated**: 2025-12-28
