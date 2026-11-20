#!/usr/bin/env bash
set -euo pipefail

rel="${1:?missing file path}"
abs="$(pwd)/$rel"

if command -v harbour >/dev/null 2>&1; then
  taken=0
  harbour edit -- "$abs" || taken=$?
  case "$taken" in
    0) exit 0 ;;
    2) exit 2 ;;
  esac
fi

pane=$(tmux list-panes -t :1 -F '#{pane_id} #{pane_current_command}' \
  | awk '/nvim/{print $1; exit}')

tmux send-keys -t "${pane:-:1}" Escape ":edit $abs" Enter
tmux select-window -t :1
if [[ -n "$pane" ]]; then
  tmux select-pane -t "$pane"
fi
