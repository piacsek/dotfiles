#!/usr/bin/env bash
# Open $1 (relative path from lazygit) in nvim on tmux window 1.
set -euo pipefail

rel="${1:?missing file path}"
abs="$(pwd)/$rel"

pane=$(tmux list-panes -t :1 -F '#{pane_id} #{pane_current_command}' \
  | awk '/nvim/{print $1; exit}')

tmux send-keys -t "${pane:-:1}" Escape ":edit $abs" Enter
tmux select-window -t :1
if [[ -n "$pane" ]]; then
  tmux select-pane -t "$pane"
fi
