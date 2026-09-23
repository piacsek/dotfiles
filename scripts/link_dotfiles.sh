#!/usr/bin/env bash
# Link tracked configs into HOME, preserving anything already at a destination.
set -euo pipefail

dotfiles_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)

link_dotfile() {
  local source=$1 target=$2 backup suffix=1

  [[ -e "$source" ]] || { printf 'Missing source: %s\n' "$source" >&2; return 1; }
  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" && $(readlink "$target") == "$source" ]]; then
    return 0
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup="${target}.pre-dotfiles.$(date +%Y%m%d-%H%M%S)"
    while [[ -e "$backup" || -L "$backup" ]]; do
      backup="${target}.pre-dotfiles.$(date +%Y%m%d-%H%M%S).$suffix"
      suffix=$((suffix + 1))
    done
    mv "$target" "$backup"
    printf 'Backed up %s to %s\n' "$target" "$backup"
  fi

  ln -s "$source" "$target"
  printf 'Linked %s\n' "$target"
}

mkdir -p "$HOME/.config/gh-dash" "$HOME/.config/tmux-sessionizer" \
  "$HOME/.config/tmux" "$HOME/scratch.nvim"
sessionizer_config="$HOME/.config/tmux-sessionizer/tmux-sessionizer.conf"
if [[ ! -e "$sessionizer_config" && ! -L "$sessionizer_config" ]]; then
  touch "$sessionizer_config"
fi

link_dotfile "$dotfiles_dir/nvim" "$HOME/.config/nvim"
link_dotfile "$dotfiles_dir/lazygit-config.yml" "$HOME/Library/Application Support/lazygit/config.yml"
link_dotfile "$dotfiles_dir/.claude/skills" "$HOME/.claude/skills"
link_dotfile "$dotfiles_dir/.claude/output-styles" "$HOME/.claude/output-styles"
link_dotfile "$dotfiles_dir/.claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
link_dotfile "$dotfiles_dir/claude-settings.json" "$HOME/.claude/settings.json"
link_dotfile "$dotfiles_dir/.ideavimrc" "$HOME/.ideavimrc"
link_dotfile "$dotfiles_dir/.tmux.conf" "$HOME/.tmux.conf"
link_dotfile "$dotfiles_dir/opencode.json" "$HOME/opencode.json"
link_dotfile "$dotfiles_dir/.zshrc" "$HOME/.zshrc"
link_dotfile "$dotfiles_dir/.ghosttyrc" "$HOME/.config/ghostty/config"
link_dotfile "$dotfiles_dir/opencode.json" "$HOME/.config/opencode/opencode.json"
link_dotfile "$dotfiles_dir/.tool-versions" "$HOME/.tool-versions"
