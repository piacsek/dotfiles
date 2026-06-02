# macOS Setup Guide

Executable documentation for setting up a fresh macOS system. Follow sections in order for optimal setup experience.

## Table of Contents

- [Prerequisites](#prerequisites)
  - [Install Xcode Command Line Tools & accept terms](#install-xcode-command-line-tools--accept-terms)
  - [Install Homebrew](#install-homebrew)
- [Terminal Environment](#terminal-environment)
  - [1. Install Ghostty](#1-install-ghostty)
  - [2. Configure Zsh](#2-configure-zsh)
  - [3. Install Oh My Zsh](#3-install-oh-my-zsh)
  - [4. Configure Git](#4-configure-git)
  - [5. Set Up SSH Key for GitHub](#5-set-up-ssh-key-for-github)
  - [6. Install Common CLI Tools](#6-install-common-cli-tools)
  - [7. Clone and Link Dotfiles](#7-clone-and-link-dotfiles)
  - [8. Set Up Dotfiles Auto-Sync](#8-set-up-dotfiles-auto-sync)
  - [9. Install asdf plugins and versions](#9-install-asdf-plugins-and-versions)
  - [10. Install GH extensions](#10-install-gh-extensions)
  - [11. Customize tmux sessionizer](#11-customize-tmux-sessionizer)
- [Essential Apps](#essential-apps)
  - [Install via Homebrew](#install-via-homebrew)
  - [Manual Installations](#manual-installations)
  - [Post-Installation Configuration](#post-installation-configuration)
- [Final Steps](#final-steps)
  - [macOS System Preferences](#macos-system-preferences)
  - [Launch and Configure Apps](#launch-and-configure-apps)
  - [Verify Installations](#verify-installations)
- [Notes](#notes)

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
echo "piacsek/" > $HOME/.gitignore
echo "Session.vim" >> $HOME/.gitignore
echo ".tmux-sessionizer" >> $HOME/.gitignore
echo ".nvim.lua" >> $HOME/.gitignore
git config --global core.excludesfile $HOME/.gitignore
git config --global user.name "Felipe Moraes Piacsek"
read "git_email?Enter your git email: "
git config --global user.email "$git_email"
git config --global pull.rebase false
```

### 5. Set Up SSH Key for GitHub

Generate SSH key and add to ssh-agent:

```bash
ssh-keygen -t ed25519 -C "$git_email"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain $HOME/.ssh/id_ed25519
mkdir -p $HOME/.ssh
echo "Host *" > $HOME/.ssh/config
echo "  AddKeysToAgent yes" >> $HOME/.ssh/config
echo "  UseKeychain yes" >> $HOME/.ssh/config
echo "  IdentityFile $HOME/.ssh/id_ed25519" >> $HOME/.ssh/config
cat $HOME/.ssh/id_ed25519.pub | pbcopy
echo "SSH public key copied to clipboard!"
echo "Add it to GitHub: https://github.com/settings/keys"
```

**Next:** Paste your SSH key into GitHub at https://github.com/settings/keys before continuing.

### 6. Install Common CLI Tools

```bash
brew install \
  claude \
  btop \
  tmux \
  1password-cli \
  neovim \
  lazygit \
  direnv \
  asdf \
  fzf \
  ripgrep \
  fd \
  gpg \
  libyaml \
  lua \
  luarocks \
  dua-cli \
  tree-sitter-cli \
  sl \
  gh \
  yq \
  imagemagick \
  bat
```

### 7. Clone and Link Dotfiles

Clone the dotfiles repository and set up symlinks:

```bash
cd $HOME

git clone git@github.com:piacsek/dotfiles.git
git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm

rm -rf $HOME/.config/nvim
rm -rf $HOME/.config/ghostty

mkdir -p $HOME/.config/ghostty
mkdir -p $HOME/.config/gh-dash
mkdir -p "$HOME/Library/Application Support/lazygit"
mkdir -p $HOME/.config/tmux-sessionizer
mkdir -p $HOME/.config/opencode
touch -p $HOME/.config/tmux-sessionizer/tmux-sessionizer.conf
mkdir $HOME/scratch.nvim

ln -sf $HOME/dotfiles/nvim $HOME/.config/nvim
ln -sf $HOME/dotfiles/gh-dash-config.yml $HOME/.config/gh-dash/config.yml
ln -sf $HOME/dotfiles/lazygit-config.yml "$HOME/Library/Application Support/lazygit/config.yml"
ln -sf $HOME/dotfiles/.claude/skills $HOME/.claude/skills
ln -sf $HOME/dotfiles/.claude/statusline-command.sh $HOME/.claude/statusline-command.sh
ln -sf $HOME/dotfiles/claude-settings.json $HOME/.claude/settings.json
ln -sf $HOME/dotfiles/CLAUDE.md $HOME/.claude/CLAUDE.md
ln -sf $HOME/dotfiles/.ideavimrc $HOME/.ideavimrc
ln -sf $HOME/dotfiles/.tmux.conf $HOME/.tmux.conf
ln -sf $HOME/dotfiles/opencode.json $HOME/opencode.json
ln -sf $HOME/dotfiles/.zshrc $HOME/.zshrc
ln -sf $HOME/dotfiles/.ghosttyrc $HOME/.config/ghostty/config
# ln -sf $HOME/dotfiles/ghostty-themes $HOME/.config/ghostty/themes
ln -sf $HOME/dotfiles/opencode.json $HOME/.config/opencode/
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

Install common language plugins and their versions (from $HOME/.tool-versions):

```bash
source $HOME/.zshrc

asdf plugin add elixir
asdf plugin add erlang
asdf plugin add nodejs
asdf plugin add python
asdf plugin add ruby
asdf plugin add postgres
asdf plugin add yarn
asdf plugin add java
asdf plugin add gradle
asdf plugin add k9s
asdf plugin add vault
asdf plugin add gcloud
asdf plugin add rebar
asdf plugin add teleport-community
asdf plugin add zig

asdf install
```

### 10. Install GH extensions


```bash
brew install --cask font-fira-code-nerd-font

gh extension install dlvhdr/gh-dash
gh extension install dlvhdr/gh-enhance
```

### 11. Customize tmux sessionizer

Configure search paths in `~/.config/tmux-sessionizer/tmux-sessionizer.conf`:

```bash
# :1 for `find` depth=1(useful for working w/ symlinks)
TS_SEARCH_PATHS=($HOME/path/to/dir:0 $HOME/.tmux-sessions:1)
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
  zoom
  loom
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
open -a Docker
sleep 5
osascript -e 'quit app "Docker"'

# Copy your Docker settings from dotfiles
cp "$HOME/dotfiles/docker-settings.json" "$HOME/Library/Group Containers/group.com.docker/settings.json"

echo "Docker settings configured. Launch Docker to apply."
```

#### MacOS Settings

```bash
# Enable auto-hide
defaults write com.apple.dock autohide -bool true && killall Dock
defaults write -g ApplePressAndHoldEnabled -bool false
```

#### Manual Settings

Configure these settings manually:

- **Login Items**: System Settings > General > Login Items
  - Add Stats
  - Add Cleanshot
  - Add Docker

### Launch and Configure Apps

```bash
open -a rcmd
open -a Stats
open -a Pasty
```

### Verify Installations

```bash
brew list --cask

which git zsh fzf rg fd bat eza
```

---

## Notes

- Run `brew update && brew upgrade` regularly to keep packages updated
- Some apps may require manual configuration on first launch
- Add license keys for paid apps (rcmd, Cleanshot, Pasty)
- Restart terminal after major changes to environment
- If the keyboard doesn't connect via bluetooth, check [this](https://docs.moergo.com/glove80-user-guide/troubleshooting/)

---

**Last Updated**: 2025-12-28
