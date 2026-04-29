---
name: port-nvim-theme-to-ghostty
description: Port a Neovim colorscheme to a matching Ghostty theme so that switching colorschemes in nvim live-updates Ghostty. Use when the user installs a new nvim colorscheme and wants Ghostty to follow, or asks "add X to ghostty themes", "port X to ghostty", or `:colorscheme X` produces a mismatch with the terminal.
---

# Port a Neovim colorscheme to Ghostty

The user's setup syncs Ghostty's theme to whatever colorscheme nvim is using. The autocmd lives at `~/dotfiles/nvim/lua/core/ghostty_sync.lua`. Theme files live in `~/dotfiles/ghostty-themes/` and are picked up by name — a colorscheme called `foo` requires a theme file at `~/dotfiles/ghostty-themes/foo`. No code edits are needed; the autocmd uses `fs_stat` to check existence.

## Steps

1. **Find the colorscheme's palette source**, in priority order:
   - **Plugin-shipped Ghostty extras** (best). Some plugins ship a Ghostty config under `extras/ghostty/`. Example:
     ```
     ~/.local/share/nvim/lazy/<plugin>/extras/ghostty/<name>
     ```
     If present, copy it directly into `~/dotfiles/ghostty-themes/`.
   - **Bundled vim colorschemes**: `/opt/homebrew/Cellar/neovim/*/share/nvim/runtime/colors/<name>.vim`. Grep for `g:terminal_ansi_colors` (the 16-color palette as a Vim list) and `^hi Normal ` (gives `guibg`/`guifg` for background/foreground).
   - **Plugin colorschemes**: hunt under `~/.local/share/nvim/lazy/<plugin>/`. Look for `colors/<name>.lua`, `lua/<plugin>/colors.lua`, `lua/<plugin>/palette.lua`. Each plugin organizes this differently — read until you find the bg/fg and 16 ANSI colors.

2. **Write the Ghostty theme file** at `~/dotfiles/ghostty-themes/<name>` (no extension):

   ```
   background = #RRGGBB
   foreground = #RRGGBB
   cursor-color = #RRGGBB

   palette = 0=#RRGGBB
   palette = 1=#RRGGBB
   ...
   palette = 15=#RRGGBB
   ```

   Mapping rules:
   - `background` ← `hi Normal guibg`
   - `foreground` ← `hi Normal guifg`
   - `cursor-color` ← usually `guifg`; for unique cursors check `hi Cursor guibg`
   - `palette = 0..15` ← the 16 entries of `g:terminal_ansi_colors` in order. Convention: 0=black, 1=red, 2=green, 3=yellow, 4=blue, 5=magenta, 6=cyan, 7=white, 8-15 = bright variants.
   - For plugin schemes that don't define ANSI colors explicitly, derive from the plugin's palette names (red, green, blue, yellow, cyan, magenta, fg, bg). Brights (8-15) can repeat the dim values when the plugin doesn't differentiate.

3. **Test**: in nvim, run `:colorscheme <name>`. The autocmd writes `theme = <name>` to `~/.config/ghostty/theme-current` and sends `SIGUSR2` to all Ghostty processes. Ghostty should flip immediately. Open `~/.config/ghostty/theme-current` to verify it was written. If Ghostty doesn't change but the file did, look for hardcoded `background`/`foreground`/`palette` lines in `~/dotfiles/.ghosttyrc` that override the theme — those must not exist.

4. **No setup-doc edits needed.** `~/.config/ghostty/themes` is a directory symlink to `~/dotfiles/ghostty-themes/`, so new files are visible immediately. The nvim autocmd resolves themes by name via `fs_stat`, so no Lua map to update.

## Light/dark variants of the same plugin

Some plugins (cyberdream is the canonical example) set the same `g:colors_name` for both light and dark variants. The autocmd has a special case: when `&background == "light"` and a `<name>-light` theme file exists, it prefers that. So if a plugin has separate variants, name the files `<name>` and `<name>-light` — the autocmd handles routing.

## Common gotchas

- **Don't add `background = ...` to `~/dotfiles/.ghosttyrc`**. Any setting after the `config-file = ?...theme-current` line will override the theme. Bg/fg/palette belong in theme files, never in `.ghosttyrc`.
- **Plugins behind `vim.pack`/lazy aren't loaded yet during `options.lua`**. If you `:colorscheme <plugin-theme>` and get `module not found`, it's the colorscheme being applied before the plugin loads at startup — the existing `options.lua` already pcalls and retries on `VimEnter`, so this only matters if you're writing fresh nvim config.
- **The autocmd doesn't fire on initial nvim startup** (the `core.ghostty_sync` module is required after `core.options` calls `colorscheme`). That's intentional — opening nvim shouldn't reflow every Ghostty window. To pull from Ghostty into nvim, use `:ThemeFromGhostty` (bound to `<M-t>`).
- **Bytecode cache**: after editing `ghostty_sync.lua`, running nvim instances need `:lua package.loaded["core.ghostty_sync"]=nil; require("core.ghostty_sync")` or a restart to pick up changes. Theme files don't have this issue — they're read fresh by Ghostty on every reload.

## Files of interest

- `~/dotfiles/ghostty-themes/` — theme files (one per colorscheme)
- `~/dotfiles/.ghosttyrc` — Ghostty config; includes `theme-current` via `config-file = ?...`
- `~/dotfiles/nvim/lua/core/ghostty_sync.lua` — the sync autocmd + `:ThemeFromGhostty` command
- `~/.config/ghostty/theme-current` — runtime state, **not** in dotfiles (rewritten on every colorscheme change)
