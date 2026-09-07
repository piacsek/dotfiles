# AGENTS.md

Notes and gotchas for working in this dotfiles repo. Each item is a hard-won fact — verify against current code before treating as live state.

## Tone & verbosity

Default to concise. Walls of text are tiring to read.

- Answer the question, then stop. No "let me know if you want…" trailers.
- Skip preambles ("Great question!", "Sure, I can help with that").
- Skip recaps of what I just said or what you just did.
- Use bullets/tables when they're genuinely denser than prose. Don't pad with structure.
- One short sentence updates beat one paragraph.
- Code over prose when the code is self-explanatory.

Concise ≠ incomplete. Do NOT omit:

- Caveats, gotchas, or risks I'd want to know before acting.
- Assumptions you're making that I might disagree with.
- Failure modes when proposing a command or change.
- Relevant context that changes the recommendation.

When in doubt, prefer terse and offer to expand ("happy to dig deeper on X") rather than dumping everything upfront.

## Repo conventions

- **Auto-sync:** `~/dotfiles` commits/pushes automatically. Don't offer to commit or push — just finish editing. Don't run manual commits unless explicitly asked.

## Neovim

- **`<M-r>` restart is unreliable.** When testing config changes (plugin setup, autocmds, highlight groups, treesitter query overrides), prefer a full `:qa!` + shell relaunch. Stale state from session restore leaks through `<M-r>` and makes working code look broken.
- **`gd` is NOT a Neovim 0.11+ LSP default.** The 0.11 defaults are `grr` (references), `gri` (implementation), `grn` (rename), `gra` (code action), `K` (hover). `gd` stays the built-in cword-search. A custom `gd → vim.lsp.buf.definition` mapping is load-bearing — don't drop it.
- **fzf-lua `setup()` resets defaults.** A second `setup(opts)` call (e.g. from a project `.nvim.lua`) wipes the global config back to built-in defaults. Pass the second positional arg: `setup(opts, true)` to merge instead of replace.
- **To hide a path from fzf-lua's files/grep pickers, don't hand-roll `fd_opts`/`rg_opts`.** Both fd and rg auto-respect `.git/info/exclude` (same syntax as `.gitignore`, but untracked/local-only — doesn't affect other devs' checkouts or `git status`). Add a line there instead: no risk of drifting from fzf-lua's default CLI flags, and it fixes every fd/rg-backed tool at once, not just fzf. Used to hide `apps/pyre/` in ws-common.
- **Treesitter injections need `include-children`.** Custom injection queries in `nvim/after/queries/<lang>/injections.scm` targeting nodes whose text lives in named children (`template_string`, `string`, block `comment`) come out empty unless you add `(#set! injection.include-children)`. Pair with `injection.language` and `(#offset! @injection.content 0 1 0 -1)` to trim delimiters. Note: tree-sitter-typescript misparses `await sql<T>\`...\`` as `<`/`>` comparison, so a content-based predicate on a bare `(template_string)` is the workaround.
- **exrc + Session.vim gotcha.** `exrc` auto-sources `.nvim.lua` only once, from the cwd at startup — it doesn't walk up the tree or re-fire on `:cd`. A session plugin that restores cwd to a subdir after startup defeats it: `&exrc` is `1`, the file is trusted, but its autocmds never register (`E216`). Fix: delete the stale `Session.vim`, `cd` to repo root, relaunch.
- **vim-test reads only `g:` vars, never `b:`.** Buffer-local `b:test#...` overrides are ignored. For per-buffer behavior, mutate the `g:` globals (`g:test#javascript#runner`, `...#jest#executable`, etc.) on `BufEnter`. vim-test's `nx.vim` runner auto-claims buffers when the runner global is `'nx'` or unset — set a specific runner (`jest`/`vitest`) to bypass it.

## herdr (side-by-side trial vs tmux)

- **herdr and tmux coexist; never nest them.** `herdr-config.toml` (→ `~/.config/herdr/config.toml`) mirrors `.tmux.conf` with the same `ctrl+space` prefix. Launch `herdr` in its own Ghostty tab — inside a tmux pane tmux swallows the prefix. Mapping: tmux session → herdr workspace, window → tab. `herdr server stop` kills every herdr pane; detach is `prefix q`.
- **nvim is multiplexer-aware via env guards, not forks.** `$HERDR_ENV=1` (only set inside herdr panes) loads `herdr-nvim-nav` and mutes vim-tmux-navigator's maps; `$TMUX` unset switches `test#strategy` and `<leader>r`/`<leader>R` from vimux to vim-test's `neovim_sticky`. Without that guard vimux would `split-window` into whatever *tmux* server is running. Under tmux both paths are byte-for-byte the old behavior.
- **Test-runner pane is ported.** Inside herdr vim-test uses the custom `herdr` strategy (`nvim/lua/core/herdr.lua` → `scripts/herdr-vimtest run`): a real pane labeled `vimtest` split below nvim (ratio 0.8 = top pane share, so the runner is 20%). `prefix C-f` = `herdr-vimtest focus` (zoom toggle; no copy-mode API, press `prefix [` after), `scripts/herdr-layout <preset|toggle>` = tmux `select-layout` (prefix C-t toggle, prefix M-1..M-5, `=` `|` `\`): parks every pane but the first in temp tabs and re-attaches them in visual order with computed ratios (`--ratio` = first pane's share) — processes survive, same PID. Pane labels exist only in `herdr api snapshot`, not `pane list`; focus-by-id only via the raw socket (`nc -U`), the CLI `pane focus` is direction-only.
- **Still tmux-only inside herdr:** `tmux-gf`/`gw` copy-mode openers (use `prefix e` = scrollback in nvim, then `gf`/`gx`), lazygit's `O` open-in-nvim (targets tmux window 1), `C-j` join / `C-i` insert window, the git-flow status widget (flow runs in the foreground popup instead).
- **Plugin config lives under `~/.config/herdr/plugins/config/<id>/`**, not in `config.toml`. Tracked here: `herdr-plugins/sessionizer.toml` (roots + nvim|claude layout; per-repo override is `<repo>/.sessionizer/config.toml`, the `.tmux-sessionizer` counterpart) and `herdr-plugins/quick-actions/available-scripts.toml` (herdr-plus quick action that reads the nearest `.available-scripts`). `herdr-plugins/navigator.toml` configures `herdr-navigator` (prefix t fuzzy jump; prefix L = last workspace). Tab labels come from `herdr-automatic-rename` (config `herdr-plugins/automatic-rename.sh` → `~/.config/herdr-automatic-rename/config.sh`, plus a `$HERDR_PANE_ID`-guarded zsh hook in `.zshrc`); a manual rename opts that tab out until its `reset` action. `herdr server reload-config` re-reads `config.toml` only — plugin manifests need reinstall.
- **Never start `herdr server` from inside a Claude Code (or any agent) session.** Every herdr pane inherits the server's environment, so `CLAUDECODE`/`CLAUDE_CODE_CHILD_SESSION` leak in and `claude` in herdr runs as a child session ("Transcript saving is off"). Start the server by running `herdr` from a plain Ghostty tab. Fix after the fact: `herdr server stop` (kills all herdr panes) and relaunch from a clean shell.
- **Key-name gotchas:** `apostrophe` is invalid, use `quote`; `equal`/`pipe` are invalid, use the literal `=` / `|`; `period`, `comma`, `semicolon`, `ampersand`, `backslash`, `[` are fine. Invalid keys are silently disabled — check `~/.config/herdr/herdr-server.log` for `invalid keybinding`, or `herdr server reload-config` diagnostics. `herdr workspace list` is JSON with `workspace_id` (not `id`).

## Terminal / theme sync

- **Ghostty theme follows nvim colorscheme.** Changing nvim's colorscheme writes `theme = <name>` to `~/.config/ghostty/theme-current` and reloads Ghostty. Theme files are GENERATED by the `piacsek/ghostty-mirror.nvim` plugin into `~/.config/ghostty/themes/` (untracked — regenerable output, do not hand-edit or track in this repo). Per-theme tweaks go in the `overrides` tables of the `ghostty-mirror` setup in `nvim/lua/core/plugins.lua`, not in theme files. `:ThemeFromGhostty` (`<M-t>`) applies the current theme cross-instance. Light variants: when `&background=light` and `<name>-light` exists, it's preferred. gh-dash follows too via `scripts/gh-dash-theme` + a launchd WatchPaths refresh (no hot-reload — gh-dash restarts).
- **gh-dash config is a merge; `config.merged.yml` is AUTOGENERATED — never edit it.** The `gh()` wrapper in `.zshrc` regenerates `~/.config/gh-dash/config.merged.yml` on every `gh dash` launch by `yq`-merging three files: base `~/dotfiles/gh-dash-config.yml` (tracked), a theme overlay `theme.generated.yml`, and an optional local override `~/gh-dash-config.yml` (untracked, work-specific sections). Edits to `config.merged.yml` are silently wiped on next launch. **Maps deep-merge; arrays are REPLACED** (last file wins) — so putting `keybindings:` or `prSections:` in the override clobbers the base's entire array, not appends. Company-agnostic bindings/scripts go in the base; work-only sections go in `~/gh-dash-config.yml` (and must re-list any base array items they want to keep).
- **delta light/dark in lazygit.** delta's default is dark; removing `--dark` does NOT fall back to light. `--detect-dark-light=auto/always` queries the terminal via stdout-tty, which **fails through lazygit's pipe** → always dark. Fix: `scripts/delta-themed.sh` reads `~/.config/ghostty/theme-current`, picks `--light` if the name contains `-light` else `--dark`, then `exec delta`. lazygit's `git.pagers[].pager` points at it and respawns per diff, so it tracks theme switches live. (Detection is by `-light` suffix — built-in light themes without it would wrongly pick dark.)

## macOS paths

- **lazygit config** lives at `~/Library/Application Support/lazygit/config.yml`, NOT `~/.config/lazygit/`. Confirm with `lazygit -cd`. A pre-existing empty file there silently overrides `~/.config`. Dotfiles symlink it to `~/dotfiles/lazygit-config.yml`.

## ws-common (referenced from this repo's `.nvim.lua`)

- **`nx test <project>` fans out.** For **nexus**, `test` runs unit/integration/component sequentially — slow and noisy for a single file. For **nova-assets** (`@nx/vite:test`), `--test-file` is silently ignored and the whole suite runs. Bypass nx: call `npx jest --config <path>` (file conventions: `*.spec.ts`→unit, `*.ispec.ts`→integration, `*.cspec.ts`→component) or `npx vitest --root apps/nova/assets run <file>`. The `ws-common/.nvim.lua` already wires vim-test to do this via BufEnter global swaps.
