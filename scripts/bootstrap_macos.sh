#!/usr/bin/env bash
# Set up a brand-new Mac end to end: Command Line Tools, Homebrew, CLI tools,
# git + SSH + gh auth, dotfiles clone/link, launch agents, asdf, nvim tools,
# apps and macOS settings. Scripted twin of SETUP_MACOS.md — keep both in sync.
#
# Only prerequisite: Ghostty (downloaded by hand). From Ghostty, run:
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/piacsek/dotfiles/main/scripts/bootstrap_macos.sh)"
#
# Idempotent: a rerun only does what is still missing. It never upgrades
# installed packages, and one-shot seeds (Docker/Rectangle settings) never
# overwrite later changes — their markers live in $STATE_DIR. Non-critical
# steps that fail are listed at the end instead of stopping the run.
#
# Still interactive: your password (sudo), git email, SSH key passphrase, the
# GitHub browser login, and App Store sign-in for Pasty.
set -euo pipefail

DOTFILES="$HOME/dotfiles"
DOTFILES_RAW="https://raw.githubusercontent.com/piacsek/dotfiles/main"
STATE_DIR="$HOME/.local/state/dotfiles-bootstrap"
FAILED=""
# `brew install` upgrades an outdated formula by default; a rerun must not.
export HOMEBREW_NO_INSTALL_UPGRADE=1 HOMEBREW_NO_AUTO_UPDATE=1

say() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m!! %s\033[0m\n' "$*" >&2; }

# Run a non-critical step; record it and keep going if it fails.
try() {
	local name=$1
	shift
	say "$name"
	# Subshell with its own `set -e`: bash ignores -e inside a function called
	# from an `if`, so `if ! "$@"` would miss failures mid-step.
	local rc
	set +e
	(
		set -e
		"$@"
	)
	rc=$?
	set -e
	if ((rc != 0)); then
		warn "$name failed — continuing"
		FAILED="$FAILED\n  - $name"
	fi
}

# Run a step only once per machine, so a rerun cannot reset later changes.
# Delete "$STATE_DIR/<marker>" to run it again.
once() {
	local marker=$1
	shift
	if [[ -e "$STATE_DIR/$marker" ]]; then
		echo "Already done (marker: $STATE_DIR/$marker)"
		return
	fi
	"$@"
	mkdir -p "$STATE_DIR"
	touch "$STATE_DIR/$marker"
}

# Write a macOS default only when it differs. Returns 1 if nothing changed.
set_default() {
	local domain=$1 key=$2 type=$3 value=$4 current expected=$4
	current=$(defaults read "$domain" "$key" 2>/dev/null || true)
	# `defaults read` prints booleans as 1/0.
	if [[ $type == -bool ]]; then
		expected=0
		[[ $value == true ]] && expected=1
	fi
	[[ "$current" == "$expected" ]] && return 1
	defaults write "$domain" "$key" "$type" "$value"
}

[[ $(uname -s) == Darwin ]] || { echo "macOS only" >&2; exit 1; }

# --- sudo: ask once, keep the ticket alive for the whole run -----------------
say "Asking for your password once (sudo)"
sudo -v
while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &

# --- Command Line Tools ------------------------------------------------------
install_clt() {
	if xcode-select -p >/dev/null 2>&1; then
		echo "Command Line Tools already installed"
		return
	fi
	# This marker file makes softwareupdate list CLT, so it installs with no GUI.
	local marker=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress label
	touch "$marker"
	label=$(softwareupdate -l 2>/dev/null |
		sed -n 's/^[[:space:]]*\* Label: \(Command Line Tools.*\)$/\1/p' | sort -V | tail -1)
	if [[ -n "$label" ]]; then
		sudo softwareupdate -i "$label" --verbose
	else
		# Fallback: Apple's GUI installer. Wait until it finishes.
		xcode-select --install || true
		echo "Finish the Command Line Tools installer window…"
		until xcode-select -p >/dev/null 2>&1; do sleep 5; done
	fi
	rm -f "$marker"
	# License acceptance only exists for full Xcode; CLT-only needs none.
	if xcodebuild -version >/dev/null 2>&1; then
		sudo xcodebuild -license accept
	fi
}
say "Command Line Tools"
install_clt

# --- Homebrew ----------------------------------------------------------------
say "Homebrew"
if [[ ! -x /opt/homebrew/bin/brew ]]; then
	NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv)"
# No `brew upgrade`: upgrading is not setup, and would change a rerun's result.
brew update

# --- Core CLI tools (core-deps.txt is the single source of truth) ------------
say "Core CLI tools"
if [[ -f "$DOTFILES/core-deps.txt" ]]; then
	deps=$(sed 's/#.*//' "$DOTFILES/core-deps.txt" | tr -d ' ' | grep .)
else
	deps=$(curl -fsSL "$DOTFILES_RAW/core-deps.txt" | sed 's/#.*//' | tr -d ' ' | grep .)
fi
# `brew list <name>` resolves aliases (gpg → gnupg) and casks (1password-cli).
missing=""
for dep in $deps fswatch mas; do
	brew list "$dep" >/dev/null 2>&1 || missing="$missing $dep"
done
if [[ -n "$missing" ]]; then
	# shellcheck disable=SC2086
	brew install $missing
else
	echo "All core CLI tools already installed"
fi

# --- Git ---------------------------------------------------------------------
say "Git config"
touch "$HOME/.gitignore"
for pattern in piacsek/ Session.vim .tmux-sessionizer .nvim.lua .available-scripts; do
	grep -Fxq "$pattern" "$HOME/.gitignore" || echo "$pattern" >>"$HOME/.gitignore"
done
git config --global core.excludesfile "$HOME/.gitignore"
git config --global user.name "Felipe Moraes Piacsek"
git config --global pull.rebase false
git_email=$(git config --global user.email || true)
if [[ -z "$git_email" ]]; then
	read -rp "Enter your git email: " git_email
	git config --global user.email "$git_email"
fi

# --- SSH key + GitHub --------------------------------------------------------
say "SSH key"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [[ ! -f "$HOME/.ssh/id_ed25519" ]]; then
	ssh-keygen -t ed25519 -C "$git_email" -f "$HOME/.ssh/id_ed25519"
fi
if [[ ! -f "$HOME/.ssh/config" ]]; then
	cat >"$HOME/.ssh/config" <<EOF
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile $HOME/.ssh/id_ed25519
EOF
fi
# macOS runs an ssh-agent per login (SSH_AUTH_SOCK). Start one only if it is
# missing, and add the key only if it is not loaded yet.
[[ -n "${SSH_AUTH_SOCK:-}" ]] || eval "$(ssh-agent -s)" >/dev/null
key_fp=$(ssh-keygen -lf "$HOME/.ssh/id_ed25519.pub" | awk '{print $2}')
ssh-add -l 2>/dev/null | grep -Fq "$key_fp" ||
	ssh-add --apple-use-keychain "$HOME/.ssh/id_ed25519"
# Trust github.com's host key up front, so the first clone does not prompt.
ssh-keygen -F github.com >/dev/null 2>&1 || ssh-keyscan github.com >>"$HOME/.ssh/known_hosts" 2>/dev/null

say "GitHub login (browser)"
gh auth status >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol ssh --web --skip-ssh-key
# `ssh -T` exits 1 even on success; check the greeting instead.
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
	gh auth refresh --hostname github.com --scopes admin:public_key
	gh ssh-key add "$HOME/.ssh/id_ed25519.pub" --title "$(scutil --get ComputerName)"
	ssh -T git@github.com 2>&1 | grep -q "successfully authenticated" ||
		{ echo "SSH to GitHub still fails" >&2; exit 1; }
fi

# --- Oh My Zsh (before linking, so our .zshrc replaces its template) ---------
say "Oh My Zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
		"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
[[ $(dscl . -read "/Users/$USER" UserShell | awk '{print $2}') == /bin/zsh ]] || sudo chsh -s /bin/zsh "$USER"

# --- Dotfiles ----------------------------------------------------------------
say "Clone and link dotfiles"
[[ -d "$DOTFILES/.git" ]] || git clone git@github.com:piacsek/dotfiles.git "$DOTFILES"
mkdir -p "$HOME/.tmux/plugins"
[[ -d "$HOME/.tmux/plugins/tpm/.git" ]] ||
	git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
"$DOTFILES/scripts/link_dotfiles.sh"

# From here on, steps are non-critical: failures are collected, not fatal.

launch_agents() {
	# The plists hardcode /Users/piacsek paths.
	if [[ "$HOME" != /Users/piacsek ]]; then
		warn "HOME is $HOME, but the plists expect /Users/piacsek — skipping"
		return 1
	fi
	mkdir -p "$HOME/Library/LaunchAgents"
	local plist
	for plist in com.dotfiles.sync com.gh-dash.theme-refresh com.dotfiles.audio-input-fix; do
		ln -sf "$DOTFILES/$plist.plist" "$HOME/Library/LaunchAgents/$plist.plist"
		if ! launchctl list "$plist" >/dev/null 2>&1; then
			launchctl load "$HOME/Library/LaunchAgents/$plist.plist"
			if [[ $plist == com.dotfiles.sync ]]; then launchctl start "$plist"; fi
		fi
	done
}
try "Launch agents (auto-sync, gh-dash theme, audio fix)" launch_agents

asdf_tools() {
	cd "$HOME"
	export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$HOME/.local/bin:$PATH"
	local plugin version
	while read -r plugin version; do
		case "$plugin" in '' | \#*) continue ;; esac
		asdf plugin list 2>/dev/null | grep -Fxq "$plugin" || asdf plugin add "$plugin"
	done <"$HOME/.tool-versions"
	asdf install
}
try "asdf plugins and versions" asdf_tools
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$HOME/.local/bin:$PATH"

gh_extras() {
	brew list --cask font-fira-code-nerd-font >/dev/null 2>&1 ||
		brew install --cask font-fira-code-nerd-font
	local ext
	for ext in dlvhdr/gh-dash dlvhdr/gh-enhance; do
		gh extension list | grep -q "${ext#*/}" || gh extension install "$ext"
	done
}
try "Nerd font and gh extensions" gh_extras

sessionizer() {
	local conf="$HOME/.config/tmux-sessionizer/tmux-sessionizer.conf"
	mkdir -p "$HOME/.tmux-sessions"
	[[ -s "$conf" ]] || echo 'TS_SEARCH_PATHS=(~/.tmux-sessions:1)' >"$conf"
}
try "tmux sessionizer config" sessionizer

tmux_agents() {
	mkdir -p "$HOME/projects"
	[[ -d "$HOME/projects/tmux-agents/.git" ]] ||
		git clone git@github.com:piacsek/tmux-agents.git "$HOME/projects/tmux-agents"
	# Skip the rebuild when already installed. After pulling changes, rerun
	# the cargo command below by hand.
	[[ -x "$HOME/.local/bin/tmux-agents" ]] && return
	cargo install --path "$HOME/projects/tmux-agents" --root "$HOME/.local" --locked
}
try "Build tmux-agents" tmux_agents

try "tmux plugins (tpm)" "$HOME/.tmux/plugins/tpm/bin/install_plugins"

nvim_tools() {
	# First headless start installs the vim.pack plugins (no prompt headless).
	nvim --headless -c "qall" </dev/null || true
	nvim --headless -c "MasonInstallTools" -c "qall" </dev/null
	nvim --headless -c "TSInstallParsers" -c "qall" </dev/null
}
try "Neovim plugins, mason tools, treesitter parsers" nvim_tools

apps() {
	local cask rc=0
	for cask in 1password rectangle google-chrome stats cleanshot docker slack \
		spotify whatsapp brainfm zoom loom rcmd ghostty; do
		brew list --cask "$cask" >/dev/null 2>&1 && continue
		# Ghostty (and anything else) installed by hand outside brew: leave it.
		if [[ $cask == ghostty && -d /Applications/Ghostty.app ]]; then continue; fi
		brew install --cask "$cask" || { warn "cask $cask failed"; rc=1; }
	done
	return $rc
}
try "Apps (Homebrew casks)" apps

pasty() {
	[[ -d /Applications/Pasty.app ]] && return
	mas account >/dev/null 2>&1 || {
		echo "Sign in to the App Store app, then press Enter…"
		open -a "App Store"
		read -r
	}
	mas install 1544620654 # Clipboard Manager — Pasty
}
try "Pasty (App Store)" pasty

docker_settings() {
	local dir="$HOME/Library/Group Containers/group.com.docker"
	if [[ ! -d "$dir" ]]; then
		open -a Docker
		sleep 5
		osascript -e 'quit app "Docker"'
	fi
	mkdir -p "$dir"
	cp "$DOTFILES/docker-settings.json" "$dir/settings.json"
}
try "Docker settings" once docker-settings docker_settings

rectangle_settings() {
	# Rectangle imports this file automatically on its next launch.
	local dir="$HOME/Library/Application Support/Rectangle"
	mkdir -p "$dir"
	cp "$DOTFILES/RectangleConfig.json" "$dir/RectangleConfig.json"
}
try "Rectangle settings" once rectangle-settings rectangle_settings

macos_defaults() {
	# Restart the Dock only when its setting changed.
	if set_default com.apple.dock autohide -bool true; then killall Dock; fi
	set_default -g ApplePressAndHoldEnabled -bool false || true
	# Fastest key repeat the Keyboard settings UI allows. Needs logout/login.
	set_default -g KeyRepeat -int 2 || true
	set_default -g InitialKeyRepeat -int 15 || true
}
try "macOS settings" macos_defaults

login_items() {
	local app
	for app in Stats CleanShot\ X Docker rcmd Pasty; do
		[[ -d "/Applications/$app.app" ]] || { warn "$app.app not found"; continue; }
		osascript -e "tell application \"System Events\" to if not (exists login item \"$app\") then make login item at end with properties {path:\"/Applications/$app.app\", hidden:false}"
	done
}
try "Login items" login_items

launch_apps() {
	local app
	for app in rcmd Stats Pasty Rectangle; do
		pgrep -xq "$app" || open -a "$app"
	done
}
try "Launch apps" launch_apps

# --- Summary -----------------------------------------------------------------
say "Done"
if [[ -n "$FAILED" ]]; then
	warn "These steps failed. Fix them and rerun this script:"
	printf '%b\n' "$FAILED"
fi
cat <<'EOF'

Still manual:
  - rcmd: import ~/dotfiles/rcmd.json in its settings.
  - Add license keys: rcmd, CleanShot, Pasty.
  - Log out and log in, so the key repeat settings apply.
EOF
