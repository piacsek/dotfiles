#!/usr/bin/env bash
# Run delta as a pager, picking --light/--dark from the live Ghostty theme.
# ghostty-mirror.nvim rewrites ~/.config/ghostty/theme-current on colorscheme
# changes; lazygit spawns the pager fresh per diff, so this tracks theme
# switches live.
#
# Light/dark comes from the theme file's actual background luminance, NOT the
# "-light" name suffix: the suffix reflects nvim's &background at generation
# time, not the palette (stargum-light has a #000000 background; suffix-less
# scintilla-diamond is light). Unresolvable anything falls back to --dark.
set -uo pipefail

mode=--dark

name=$(awk -F' *= *' '$1 == "theme" { print $2; exit }' "$HOME/.config/ghostty/theme-current" 2>/dev/null)
if [[ -n "${name:-}" ]]; then
	for dir in "$HOME/.config/ghostty/themes" \
		"/Applications/Ghostty.app/Contents/Resources/ghostty/themes"; do
		if [[ -f "$dir/$name" ]]; then
			bg=$(awk -F' *= *' '$1 == "background" { sub(/^#/, "", $2); print $2; exit }' "$dir/$name")
			if [[ "$bg" =~ ^[0-9a-fA-F]{6}$ ]]; then
				# Perceived luminance (ITU BT.601); midpoint 128 splits light/dark.
				lum=$(((299 * 16#${bg:0:2} + 587 * 16#${bg:2:2} + 114 * 16#${bg:4:2}) / 1000))
				((lum >= 128)) && mode=--light
			fi
			break
		fi
	done
fi

exec delta "$mode" "$@"
