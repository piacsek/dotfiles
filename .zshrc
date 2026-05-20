# Exports
export ZSH="$HOME/.oh-my-zsh"
export PATH=/opt/homebrew/bin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:$HOME/dotfiles/scripts/:$HOME/scripts/:$HOME/.tmux-sessionizer/:$HOME/.opencode/bin
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

# Aliases
alias vim='nvim'
alias dotfiles='cd $HOME/dotfiles/'
alias lz='lazygit'
alias tx='tmux-sessionizer'
alias lazysql='op run --env-file="./.env" -- lazysql'

bindkey -r '^[d'

if [ -f $HOME/.zshrc_work ]; then
	source $HOME/.zshrc_work
fi

# Fzf

source <(fzf --zsh)
