# Exports
export ZSH="$HOME/.oh-my-zsh"
export PATH=/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin
export PKG_CONFIG_PATH="/opt/homebrew/opt/openssl/lib/pkgconfig"
export LDFLAGS="-L/opt/homebrew/opt/openssl/lib"
export ERL_AFLAGS="-kernel shell_history enabled"

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

# Aliases
alias lab='cd $HOME/Projects/elixir_lab/ && nvim'
alias bank='cd $HOME/Projects/ex_bank/ && nvim'
alias dotfiles='cd $HOME/dotfiles/'
alias cdnvimconfig='cd $HOME/.config/nvim/'
alias lz='lazygit'
alias postgres_current_version="echo $(asdf current postgres | awk '{print $2}')"
alias postgres_start='/$HOME/.asdf/installs/postgres/$(postgres_current_version)/bin/pg_ctl -D /$HOME/.asdf/installs/postgres/$(postgres_current_version)/data -l logfile start'


if [ -f $HOME/.zshrc_work ]; then
	source $HOME/.zshrc_work
fi
