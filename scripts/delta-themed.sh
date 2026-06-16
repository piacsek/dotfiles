#!/usr/bin/env bash
# Run delta as a pager, picking --light/--dark from the live Ghostty theme.
# ghostty-mirror.nvim rewrites ~/.config/ghostty/theme-current on colorscheme
# changes; light themes carry a "-light" suffix. lazygit spawns the pager fresh
# per diff, so this tracks theme switches live.
set -euo pipefail

mode=--dark
if grep -q -- '-light' "$HOME/.config/ghostty/theme-current" 2>/dev/null; then
	mode=--light
fi

exec delta "$mode" "$@"
