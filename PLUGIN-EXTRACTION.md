# Extraction prompt: project-wide checker diagnostics plugin

## The task

Extract the working prototype in this dotfiles repo into a standalone Neovim
plugin. The prototype runs a project's own command-line checkers (`tsc`,
`eslint`, …) in the background and publishes their output as `vim.diagnostic`
entries, so problems in files that were never opened are visible everywhere
diagnostics normally appear.

Fix the flaws listed in **Known flaws** while extracting. Do not treat the
prototype as a reference implementation to copy verbatim — it is a proof that
the idea works, with known rough edges.

## Why the plugin exists (keep this framing in the README)

A language server like `ts_ls` is single-file: it only reports problems in files
you have opened. Run `tsc` in a terminal and you see 27 errors; open Neovim and
you see the 2 in your current buffer. This plugin closes that gap by running the
real checker and feeding its output into the diagnostic system, so Trouble,
`vim.diagnostic` pickers, the gutter and any statusline count all see the whole
project.

## Source material

| Path | What it is |
| --- | --- |
| `nvim/lua/core/typecheck.lua` | The engine: config normalization, parsers, process lifecycle, publishing, LSP dedup, `:Typecheck` command |
| `nvim/lua/plugins/lualine.lua` | Statusline integration: spinner driven by a `User TypecheckStateChanged` autocmd, per-buffer + workspace diagnostic counts |
| `~/projects/wonderschool/ws-common/.nvim.lua` | Real-world consumer: two checkers, save trigger, startup trigger |

Read all three before designing. The consumer file matters most — it shows what
project-level configuration actually needs to express.

## Verified behavior to preserve

These were all confirmed by running them, and each exists because of a concrete
failure. Do not regress them.

1. **Debounce collapses bursts.** A stream of saves (or `:wall`) produces one
   run. Per-checker timers.
2. **A new run kills the in-flight one.** Two passes must never race to publish;
   the superseded run's output is discarded, not published.
3. **The saved buffer's markers clear immediately.** Without this, a fixed error
   keeps its sign for the entire run (5–15s), which feels broken next to LSP
   diagnostics that vanish instantly. The run then republishes whatever is
   genuinely still wrong.
4. **Identical raw output lines collapse.** An `nx` target that runs
   `tsc -p tsconfig.app.json` and `tsc -p tsconfig.spec.json` emits every problem
   in a file both configs include *twice*. Verified: `2 …route.ts(57,17): error
   TS1155…`. Dedup on the whole raw line, so two genuinely different errors at
   the same position (e.g. `TS1155` and `TS7005` on one line) both survive.
5. **Each checker owns a namespace.** `typecheck:tsc` and `typecheck:lint` must
   not clobber each other; they publish independently and in parallel.
6. **Results attach to unopened files.** `vim.fn.bufadd` (not `bufload`) is
   enough to hold diagnostics; they render when the file is later opened.
7. **The statusline indicator only exists while work is in flight**, covers the
   debounce window too (so `:w` gives instant feedback), and names the checkers
   still running (`⣻ lint tsc` → `⣽ tsc`).

## Proposed architecture

```
lua/<plugin>/init.lua      setup(), public API, user commands
lua/<plugin>/config.lua    schema + validation + defaults
lua/<plugin>/runner.lua    process lifecycle: spawn, kill, debounce, process groups
lua/<plugin>/publish.lua   parsed results -> vim.diagnostic, buffer bookkeeping
lua/<plugin>/formats/      one module per output format, open for registration
lua/<plugin>/status.lua    state introspection for statuslines (is_running, names, counts)
lua/<plugin>/health.lua    :checkhealth — resolve each configured cmd, cwd, format
```

### Config shape

Take the prototype's list-of-checkers and add what it lacks (`when`, `pattern`,
`env`, `timeout`, `dedup`):

```lua
require("<plugin>").setup({
  checkers = {
    {
      name = "tsc",
      cmd = { "npx", "nx", "run", "nexus:typecheck" },  -- prefer argv over a shell string
      env = { NX_TUI = "false" },
      cwd = "<repo>",
      root = "<repo>/apps/nexus",   -- relative output paths resolve against this
      format = "tsc",
      when = { "save", "startup" },  -- also "manual"
      pattern = { "*/apps/nexus/**/*.ts" },  -- which saves trigger it
      timeout = 120000,
      dedup = { lsp = true },        -- drop entries a live server already reports
    },
  },
  debounce = 1000,
  notify = "errors",  -- "always" | "errors" | "never"
})
```

`cmd` as `{ argv }` avoids `sh -c` entirely, which is also half the fix for flaw
F1. Keep a string form as a documented escape hatch for pipelines.

### Public API

```lua
M.run(opts)              -- opts.name?, opts.debounce?, opts.clear_buf?, opts.quiet?
M.cancel(name?)          -- kill in-flight runs
M.clear(name?)           -- reset namespaces
M.is_running(name?)      -- boolean
M.running_names()        -- sorted list, for statusline labels
M.results(name?)         -- structured counts, for statusline / telescope pickers
```

Fire `User <Plugin>StateChanged` on every state transition so statuslines can
refresh on an event rather than polling. This is what makes the spinner feel
instant; lualine's own refresh is a 1s timer, far too slow to animate.

### Format adapters

Ship `tsc` and `unix`, and make the table user-extensible:

```lua
require("<plugin>.formats").register("mytool", function(line, root)
  return path, { lnum = 0, col = 0, severity = …, message = …, code = … }
end)
```

Verified formats from the prototype:

- **tsc** (non-pretty): `src/foo.ts(12,5): error TS2345: message` — paths are
  relative to the tsconfig's dir, which is often *not* the repo root.
- **eslint `--format unix`**: `/abs/foo.ts:12:5: message [Error/rule-name]` —
  absolute paths, severity and rule included, one line per problem, and a
  trailing `N problems` summary line that must not parse. Prefer this over the
  default `stylish` formatter, which is multi-line and fragile.

Consider also shipping `rustc`/`cargo` JSON, `ruff`, `golangci-lint` (all have
line-oriented or JSON modes) to prove the abstraction generalizes.

## Known flaws (fix these)

### F1 — Killing a run orphans the actual work. **Measured: confirmed.**

The prototype spawns `sh -c "<cmd>"` and kills the shell with `SIGTERM`. A test
where the command backgrounds a child (`(sleep 3; touch marker) & wait`) showed
`orphan survived kill = true` — the marker appeared after the kill. With
`npx nx …`, killing the wrapper leaves `node`/`tsc` running.

Consequence: rapid saves stack orphaned typechecker processes, each burning a
core, on a command that already takes 5–15s. This is the most serious flaw.

Fix: spawn via argv (no shell) and put the child in its own process group
(`vim.uv.spawn` with `detached = true`), then signal the **group**
(`vim.uv.kill(-pid, "sigterm")`). Verify with the same marker-file test, and
follow up with `SIGKILL` after a grace period.

### F2 — Every run is a full-project run

Each save re-checks the entire project from cold. Measured on the real repo:
`nx typecheck --skip-nx-cache` ≈ 5–15s, `eslint src/licensing` ≈ 10.6s. On a
1s debounce that means near-continuous CPU load while actively editing.

Fix, in increasing order of ambition:

- Document that caching flags belong in `cmd` (`eslint --cache`, dropping
  `--skip-nx-cache`, `tsc --incremental`).
- Support a `watch` checker kind: a long-lived process (`tsc --watch`) whose
  output is streamed and re-published on each emitted batch. This is the real
  answer for large projects and changes the architecture, so decide early.

### F3 — `bufadd` leaks buffers

Every file with a problem gets an unlisted buffer that is never cleaned up, even
after the problem is fixed and the buffer holds nothing. Over a long session with
a churning error set, these accumulate.

Fix: track buffers the plugin created; on republish, delete the ones that are
unloaded, hidden, and now diagnostic-free.

### F4 — LSP dedup is positional, one-directional, and permanent

The prototype drops its own entry when a live server reports the same
`line:col:code`. Three problems:

- **Column agreement is assumed.** `tsc` and `ts_ls` agree today; another
  tool/server pair may not, and then duplicates reappear.
- **`normalize_code` strips a `TS` prefix** — hardcoded TypeScript knowledge in
  generic code.
- **It never restores.** Once dropped, the entry is gone until the next full
  run, even if the server later stops reporting it.

Fix: make dedup per-checker and configurable (`off` | `position` | `line`), keep
the raw parsed results so entries can be recomputed rather than destroyed, and
move code normalization into the format adapter.

### F5 — Global state, single project

`vim.g.typecheck` is global and state is keyed by checker name alone. One Neovim
instance visiting two projects (`:cd`, or a session that restores another root)
mixes their state and namespaces.

Fix: key state by `(resolved root, checker name)`; resolve the root once at
config time.

### F6 — No trigger scoping in the engine

The engine has no notion of *which* saves matter; the consumer's `.nvim.lua`
does the path filtering by hand and then triggers **all** checkers. Saving a
file that only one checker covers still runs the others.

Fix: `when` + `pattern` per checker, with the autocmd owned by the plugin.

### F7 — `quiet` hides hard failures

Auto-runs pass `quiet = true`, which suppresses *everything*, including "command
not found" or a non-zero exit with unparseable output. The failure mode is
silent: diagnostics vanish and never return, and nothing says why. This already
caused a live confusion during development.

Fix: `quiet` should suppress *success* chatter only. A run that exits non-zero
and produces zero parseable results must always report once (rate-limited per
checker), because that is indistinguishable from "clean" to the user.

### F8 — Unbounded output buffering and main-thread parsing

`vim.system` accumulates all stdout/stderr into one string, parsed in a single
synchronous pass. Fine at today's sizes; a pathological run (thousands of
errors, or a tool that logs progress) blocks the UI.

Fix: stream stdout, parse line-by-line as it arrives, cap retained results, and
publish in one batch at exit.

### F9 — Our own kill is indistinguishable from a real signal

The completion handler discards any result where `res.signal ~= 0`, which is how
superseded runs are ignored — but it also silently swallows a genuine
`SIGKILL` (OOM killer, for instance).

Fix: track a per-checker "superseded" flag set at kill time; treat any other
signal as a real failure and report it (see F7).

### F10 — Parser fragility

- `parse_unix`'s `^(.-):(%d+):(%d+):` breaks on Windows drive letters (`C:\…`)
  and on paths containing colons.
- `parse_tsc` requires a `TS%d+` code, so tsc lines without one are dropped.
- Multi-line diagnostics (tsc's indented "related information") are discarded.

Fix: anchor path matching more carefully, make the code group optional, and let
adapters return multiple lines' worth of context as `related_information`.

### F11 — No timeout, no hang protection

A wedged checker leaves `is_running()` true forever and the spinner spinning.

Fix: per-checker `timeout`, kill on expiry, report it.

### F12 — Timers are not closed on exit

`typecheck.lua` never closes its debounce timers on `VimLeavePre` (the lualine
spinner does close its own). Harmless today, sloppy in a plugin.

## Performance notes

- **Statusline cost is not a problem.** `vim.diagnostic.count(nil)` with 600
  diagnostics across 60 buffers measured **23.4 µs/call**. Called on every
  statusline render, that is negligible; it scales linearly, so cache it against
  `DiagnosticChanged` only if someone reports pathological counts.
- **The spinner timer runs at 220 ms and only while a run is in flight.** There
  is no idle repaint loop. Keep that property; a always-on animation timer in a
  statusline is a real battery cost.
- **The dominant cost is the checkers themselves** (F2). Everything in Lua here
  is noise by comparison. Optimize process lifecycle, not the Lua.

## Non-goals

- Replacing `nvim-lint` for single-buffer linting on the fly. This is the
  project-wide complement to a language server, not a per-keystroke linter.
- Being a general task runner. If someone wants task lists, templates and
  restart policies, `overseer.nvim` already does that and can publish
  diagnostics via `on_output_parse` + `on_result_diagnostics`. State this
  comparison in the README honestly — it is the closest existing plugin.
- Fixing or formatting code. Read-only.

## Testing guide (learned the hard way)

Headless Neovim lies in specific ways. Every one of these cost real debugging
time during the prototype:

- **`vim.wait` inside `-S`/`-c` startup scripts blocks `VimEnter`.** A startup
  hook will appear broken. Use `vim.defer_fn` and let the loop run.
- **Mappings driven by `:normal` are unreliable headless.** Test the API
  (`M.run`, parsers) directly; reserve keymap tests for a real UI.
- **`#vim.api.nvim_list_uis() == 0` in headless** — any UI-guarded code path
  needs either a stub (`vim.api.nvim_list_uis = function() return {{}} end`) or a
  pty (`script -q /dev/null nvim …`, which is itself flaky in sandboxes).
- **Editing a project-local `.nvim.lua` invalidates its exrc trust hash**, so
  the file silently stops loading. Re-trust with
  `vim.secure.trust({ action = "allow", path = ".nvim.lua" })`.
- **Statusline assertions** go through `vim.api.nvim_eval_statusline(vim.o.statusline, { winid = 0 })`.
- **Stub the checkers.** `echo`/`printf` for output shapes, `sleep N; echo …` for
  slow runs, and a marker file (`(sleep 3; touch X) & wait`) to prove kill
  semantics. Real checkers are too slow for a test suite and go clean/dirty as
  the repo changes — a real run that finds nothing looks exactly like a broken
  run.
- **Sampling interval vs animation period**: polling a spinner at 250 ms with a
  120 ms period aliases and looks stuck. Sample faster than the frame rate.

Suggested suite: `busted`/`plenary` unit tests for every format adapter against
captured real output (keep fixtures of genuine `tsc`/`eslint` output, including
the duplicate-pass case and the trailing summary line), plus integration tests
using stub commands for debounce, kill/supersede, clear-on-save, parallelism, and
process-group cleanup.

## Acceptance criteria

1. Two checkers with different formats run in parallel, each publishing to its
   own namespace, with results attached to files that were never opened.
2. Killing a superseded run leaves **no** orphaned processes (marker-file test).
3. A save clears the saved buffer's entries immediately and republishes after
   the run; other files' entries are untouched meanwhile.
4. A checker whose command is missing or fails without parseable output reports
   an error exactly once, even in `quiet` mode.
5. Duplicate raw output lines collapse; distinct problems at one position do not.
6. `:checkhealth` reports each checker's resolved command, cwd, format, and
   whether the executable exists.
7. Statusline API exposes running state and names; a documented lualine snippet
   is in the README.
8. No global state leaks between two projects opened in one Neovim instance.

## Naming

Checked on GitHub — all unclaimed at time of writing:

- **`blindspot.nvim`** (preferred) — names the problem: your language server
  only sees open files, this covers the blind spot.
- `errata.nvim` — an errata is a published list of errors.
- `elsewhere.nvim` / `offscreen.nvim` — the problems are in files you are not
  looking at.
- `dragnet.nvim` — emphasizes the project-wide sweep.

Evocative names are invisible to search. Whichever is chosen, put the searchable
terms ("project-wide diagnostics", "run tsc/eslint in background", "workspace
diagnostics") in the description and GitHub topics.
