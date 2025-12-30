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
xcode-select --install
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

### 3. Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 4. Configure Git

```bash
git config --global user.name "Felipe Moraes Piacsek"
read "git_email?Enter your git email: "
git config --global user.email "$git_email"
```

### 5. Set Up SSH Key for GitHub

Generate SSH key and add to ssh-agent:

```bash
ssh-keygen -t ed25519 -C "$git_email"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
mkdir -p ~/.ssh
echo "Host *" > ~/.ssh/config
echo "  AddKeysToAgent yes" >> ~/.ssh/config
echo "  UseKeychain yes" >> ~/.ssh/config
echo "  IdentityFile ~/.ssh/id_ed25519" >> ~/.ssh/config
cat ~/.ssh/id_ed25519.pub | pbcopy
echo SSH public key copied to clipboard!
echo Add it to GitHub: https://github.com/settings/keys
```

**Next:** Paste your SSH key into GitHub at https://github.com/settings/keys before continuing.

### 6. Install Common CLI Tools

```bash
brew install \
  neovim \
  direnv \
  asdf \
  fzf \
  ripgrep \
  fd \
  bat
```

### 7. Clone and Link Dotfiles
Clone the dotfiles repository and set up symlinks:

```bash
cd $HOME
git clone https://github.com/piacsek/dotfiles.git

rm -rf $HOME/.config/nvim
rm -rf $HOME/.config/ghostty

mkdir -p $HOME/.config/ghostty

ln -sf $HOME/dotfiles/nvim $HOME/.config/nvim
ln -sf $HOME/dotfiles/.ideavimrc $HOME/.ideavimrc
ln -sf $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/.ghosttyrc $HOME/.config/ghostty/config
ln -sf $HOME/dotfiles/.tool-versions $HOME/.tool-versions
```

### 8. Set Up Dotfiles Auto-Sync

Install fswatch and set up the auto-sync service to automatically commit and push dotfile changes:

```bash
brew install fswatch
mkdir -p $HOME/Library/LaunchAgents

ln -sf $HOME/dotfiles/com.dotfiles.sync.plist $HOME/Library/LaunchAgents/com.dotfiles.sync.plist

launchctl load $HOME/Library/LaunchAgents/com.dotfiles.sync.plist
launchctl start com.dotfiles.sync
```

Verify the service is running:

```bash
launchctl list | grep dotfiles
```

### 9. Install asdf plugins and versions

Install common language plugins and their versions (from ~/.tool-versions):

```bash
source ~/.zshrc

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
asdf plugin add zig

# Install all versions from .tool-versions
asdf install

# Install Claude CLI globally
npm install -g @anthropic-ai/claude-code
```

---

## Essential Apps

### Install via Homebrew

```bash
CASKS=(
  1password
  rectangle
  google-chrome
  stats
  cleanshot
  docker
  slack
  spotify
  whatsapp
  brainfm
)

for cask in "${CASKS[@]}"; do
  brew install --cask $cask 2>/dev/null || echo "$cask already installed or failed, skipping..."
done
```

### Manual Installations

**rcmd** - Fast app switching tool
- Visit: https://lowtechguys.com/rcmd/
- Download and install manually
- Import your `rcmd.json` settings after installation

**Pasty** - Clipboard manager
- Visit: https://getpasty.app/
- Download from website or Mac App Store

### Post-Installation Configuration

- **Rectangle**: Import your `RectangleConfig.json` settings

---

## Final Steps

### macOS System Preferences

#### Docker Settings

Configure Docker with your saved settings (3GB RAM, 1 CPU, no swap):

```bash
# Open Docker once to initialize the directory structure, then quit it
open -a Docker
sleep 5
osascript -e 'quit app "Docker"'

# Copy your Docker settings from dotfiles
cp "$HOME/dotfiles/docker-settings.json" "$HOME/Library/Group Containers/group.com.docker/settings.json"

echo "Docker settings configured. Launch Docker to apply."
```

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
