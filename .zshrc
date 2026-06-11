# Exports
export ZSH="$HOME/.oh-my-zsh"
export PATH=/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:$HOME/dotfiles/scripts/:$HOME/scripts/:$HOME/.tmux-sessionizer/:$HOME/.opencode/bin:$HOME/.local/share/nvim/mason/bin
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl/lib/pkgconfig"
export LDFLAGS="-L/opt/homebrew/opt/openssl/lib"
export ERL_AFLAGS="-kernel shell_history enabled"
export RUBY_CONFIGURE_OPTS="--with-libyaml-dir=$(brew --prefix libyaml)"
export EDITOR=nvim
export VISUAL=nvim

# ZSH customization
# Enable prompt substitution
setopt prompt_subst

# Load and configure vcs_info
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats $'\uE0A0 %b'

# Load colors
autoload -U colors && colors

# Configure the two-line prompt
PROMPT='%F{blue}%~%f - %F{magenta}${vcs_info_msg_0_}%f
%F{yellow}%*%f ➜ '

plugins=(git)

source $ZSH/oh-my-zsh.sh

# Init ASDF
if [ -f /opt/homebrew/opt/asdf/libexec/asdf.sh ]; then
	. /opt/homebrew/opt/asdf/libexec/asdf.sh
fi

# Init direnv
eval "$(direnv hook zsh)"

# Init zoxide (smarter cd: `z <partial-dir-name>`, `zi` for interactive pick)
eval "$(zoxide init zsh)"

# Aliases
alias vim='nvim'
alias dotfiles='cd $HOME/dotfiles/'
alias lz='lazygit'
alias tx='tmux-sessionizer'
# alias lazysql='op run --env-file="$HOME/projects/wonderschool/.db_env" -- lazysql'

# gh dash: merge checked-in base config with optional local override
# (~/gh-dash-config.yml — kept out of dotfiles for work-specific sections).
# Deep-merges maps (e.g. repoPaths); arrays are replaced. To append arrays
# instead, change `. * $item` to `. *+ $item`.
gh() {
	if [[ "$1" == "dash" ]]; then
		shift
		local base="$HOME/dotfiles/gh-dash-config.yml"
		local override="$HOME/gh-dash-config.yml"
		local merged="$HOME/.config/gh-dash/config.merged.yml"
		if [[ -f "$override" ]]; then
			yq eval-all '. as $item ireduce ({}; . * $item)' "$base" "$override" > "$merged"
		else
			cp "$base" "$merged"
		fi
		command gh dash --config "$merged" "$@"
	else
		command gh "$@"
	fi
}

bindkey -r '^[d'

if [ -f $HOME/.zshrc_work ]; then
	source $HOME/.zshrc_work
fi

# Fzf

source <(fzf --zsh)

# Source the first existing file among the candidates; silently skips if the
# plugin isn't installed. Covers macOS brew, Linuxbrew, Debian/Fedora, Arch.
source_first() {
	local f
	for f in "$@"; do
		if [[ -f "$f" ]]; then
			source "$f"
			return
		fi
	done
}

# Autosuggestions (ghost-text from history; accept with right-arrow)
source_first \
	/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
	/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
	/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
	/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Syntax highlighting — must stay the last thing sourced in this file
source_first \
	/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
