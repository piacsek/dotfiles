---
name: track-in-dotfiles
description: Move a config file into the ~/dotfiles repo, symlink it back to its original location, and add it to scripts/link_dotfiles.sh so a fresh machine reproduces the setup. Use when the user says "port this to dotfiles", "track X in dotfiles", "let's save these settings to the dotfiles repo", or after editing a config that isn't yet under `~/dotfiles/`.
---

# Track a config file in the dotfiles repo

The dotfiles repo at `~/dotfiles/` holds tracked configs as plain files at the repo root (e.g. `gh-dash-config.yml`, `claude-settings.json`). The original system location holds a symlink. `scripts/link_dotfiles.sh` creates those symlinks on a fresh machine (the bootstrap runs it) — every tracked file MUST have a `link_dotfile` line there or it won't survive a reinstall.

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

4. **Add a line to `~/dotfiles/scripts/link_dotfiles.sh`**, grouped near related entries (e.g. claude-related lines stay together):
   ```
   link_dotfile "$dotfiles_dir/<target>" "$HOME/<source-relative-to-home>"
   ```
   `link_dotfile` creates the parent directory and backs up anything already there.

5. **Don't commit.** Leave the working tree dirty; the user commits dotfiles changes themselves.

## Gotchas

- `~/dotfiles/.claude/` is **project-scoped** for Claude Code (only loads when running claude inside `~/dotfiles`). User-global Claude settings belong at `~/dotfiles/claude-settings.json` symlinked to `~/.claude/settings.json`, NOT inside `.claude/`.
- If the source is a directory, use `ln -sf` on the directory itself, not its contents.
- Don't track GENERATED files (e.g. ghostty-mirror.nvim's theme output in `~/.config/ghostty/themes/`) — track the config that generates them instead.
