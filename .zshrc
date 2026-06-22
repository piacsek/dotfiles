# Exports
export ZSH="$HOME/.oh-my-zsh"
export PATH=/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:$HOME/dotfiles/scripts/:$HOME/scripts/:$HOME/.tmux-sessionizer/:$HOME/.opencode/bin:$HOME/.local/share/nvim/mason/bin
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl/lib/pkgconfig"
export LDFLAGS="-L/opt/homebrew/opt/openssl/lib"
export ERL_AFLAGS="-kernel shell_history enabled"
export RUBY_CONFIGURE_OPTS="--with-libyaml-dir=$(brew --prefix libyaml)"
export EDITOR=nvim
export VISUAL=nvim
# Syntax-highlighted man pages via bat
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

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
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Init direnv
eval "$(direnv hook zsh)"

# Init zoxide (smarter cd: `z <partial-dir-name>`, `zi` for interactive pick)
eval "$(zoxide init zsh)"

# Override zoxide's `z` completion: always query the db interactively via fzf,
# so `z ws<Tab>` (no trailing space needed) opens the picker filtered to "ws",
# and `z<Tab>` opens it with everything. Default behavior only completed local
# subdirs and reserved the db query for the awkward Space-Tab. Reuses zoxide's
# own helper + keybinding (set by `zoxide init`); we only swap the function body.
function __zoxide_z_complete() {
    [[ "${#words[@]}" -eq "${CURRENT}" ]] || return 0
    __zoxide_result="$(\command zoxide query --exclude "$(__zoxide_pwd || \builtin true)" --interactive -- ${words[2,-1]})" || __zoxide_result=''
    compadd -Q ""
    \builtin bindkey '\e[0n' '__zoxide_z_complete_helper'
    \builtin printf '\e[5n'
    return 0
}

# Aliases
alias vim='nvim'
alias cat='bat -pp' # plain style, no pager — safe drop-in for cat
alias dotfiles='cd $HOME/dotfiles/'
alias lz='lazygit'
alias tx='tmux-sessionizer'
# alias lazysql='op run --env-file="$HOME/projects/wonderschool/.db_env" -- lazysql'

# gh dash: merge checked-in base config with a theme overlay derived from the
# current Ghostty theme (scripts/gh-dash-theme) and an optional local override
# (~/gh-dash-config.yml — kept out of dotfiles for work-specific sections).
# Deep-merges maps (e.g. repoPaths); arrays are replaced. To append arrays
# instead, change `. * $item` to `. *+ $item`.
gh() {
	if [[ "$1" == "dash" ]]; then
		shift
		local base="$HOME/dotfiles/gh-dash-config.yml"
		local override="$HOME/gh-dash-config.yml"
		local theme="$HOME/.config/gh-dash/theme.generated.yml"
		local merged="$HOME/.config/gh-dash/config.merged.yml"
		"$HOME/dotfiles/scripts/gh-dash-theme" > "$theme" 2>/dev/null || echo '{}' > "$theme"
		if [[ -f "$override" ]]; then
			yq eval-all '. as $item ireduce ({}; . * $item)' "$base" "$theme" "$override" > "$merged"
		else
			yq eval-all '. as $item ireduce ({}; . * $item)' "$base" "$theme" > "$merged"
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

# Syntax highlighting — must stay the last thing sourced in this file
source_first \
	/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
