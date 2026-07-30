---
name: track-in-dotfiles
description: Move a config file into the ~/dotfiles repo, symlink it back to its original location, and update SETUP_MACOS.md so a fresh machine reproduces the setup. Use when the user says "port this to dotfiles", "track X in dotfiles", "let's save these settings to the dotfiles repo", or after editing a config that isn't yet under `~/dotfiles/`.
---

# Track a config file in the dotfiles repo

The dotfiles repo at `~/dotfiles/` holds tracked configs as plain files at the repo root (e.g. `gh-dash-config.yml`, `opencode.json`, `claude-settings.json`). The original system location holds a symlink. `SETUP_MACOS.md` is the bootstrap script for a fresh machine — every tracked file MUST have a `ln -sf` line there or it won't survive a reinstall.

## Steps

1. **Confirm the source path and target name with the user** if not already obvious. Default convention: flat at repo root, kebab-case name that hints at what it is. Examples:
   - `~/.claude/settings.json` → `~/dotfiles/claude-settings.json`
   - `~/.config/gh-dash/config.yml` → `~/dotfiles/gh-dash-config.yml`

2. **Verify the source is a real file, not already a symlink.** Run `ls -la <source>`. If it's already a symlink into `~/dotfiles/`, stop — already tracked.

3. **Move and symlink** in one shell call:
   ```sh
   mv <source> ~/dotfiles/<target> && ln -s ~/dotfiles/<target> <source>
   ```
   Then `ls -la <source>` to verify the symlink resolves correctly.

4. **Update `~/dotfiles/SETUP_MACOS.md`.** Find the block of `ln -sf $HOME/dotfiles/...` lines (around line 150). Add a new line, grouped near related entries (e.g. claude-related lines stay together):
   ```
   ln -sf $HOME/dotfiles/<target> <source-with-$HOME>
   ```
   Use `$HOME` (not `~`) and absolute-ish paths to match the existing style. If the source's parent directory isn't already `mkdir -p`'d earlier in the file, add that too.

5. **Don't commit.** The repo has an auto-sync watcher (`scripts/dotfiles-sync.sh` via `com.dotfiles.sync.plist`) that picks up changes and commits with a Claude-generated message. Just leave the working tree dirty.

## Gotchas

- `~/dotfiles/.claude/` is **project-scoped** for Claude Code (only loads when running claude inside `~/dotfiles`). User-global Claude settings belong at `~/dotfiles/claude-settings.json` symlinked to `~/.claude/settings.json`, NOT inside `.claude/`.
- If the source is a directory, use `ln -sf` on the directory itself, not its contents.
- Don't track GENERATED files (e.g. ghostty-mirror.nvim's theme output in `~/.config/ghostty/themes/`) — track the config that generates them instead.
- Don't `git add` files inside `~/dotfiles/.claude/skills/` of unrelated changes; the auto-sync handles staging.
