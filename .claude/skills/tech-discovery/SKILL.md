---
name: tech-discovery
description: |
  Run a tech-discovery workflow: read an initial discovery doc, fetch Linear context,
  propose improvements, generate tech-docs (OpenAPI, ER mermaid, AsyncAPI, constraints),
  break the work into small parallelizable tasks, and create them as Linear tickets —
  with explicit user approval at every gate. Markdown is the source of truth for any
  later sync back to Linear.

  Invoke with /tech-discovery or when the user asks to start, resume, or sync a tech
  discovery.
argument-hint: "<path to initial doc OR slug of existing discovery>"
---

# Tech discovery

This skill encodes a 6-step discovery workflow. **Every gate stops and waits for user approval before continuing** — gates exist because the next step has a permanent or expensive side effect (file generation, Linear ticket creation). Do not "optimize" gates away; they are the point.

> Convention note: existing skills like `initiative` say *"Never gate progress."* This skill is intentionally the opposite. Each gate sits in front of an action that is hard or annoying to reverse, so the cost of asking is low and the cost of skipping is high.

## When to invoke

- User asks to start a tech discovery, generate tech-docs from a discovery doc, or break a Linear story into ≤1-day tasks.
- User says `/tech-discovery <path>` with a path to an initial-doc markdown.
- User says `/tech-discovery <slug>` to resume / re-sync an existing discovery dir.

## Inputs

- An initial-doc markdown the user filled in from [`templates/initial-doc.md`](templates/initial-doc.md). The path is the skill argument, or the user is prompted for it.
- The initial doc must declare at least one Linear ref in its frontmatter (`linear_refs`).

If the user has not yet authored an initial doc, copy `templates/initial-doc.md` to a path they specify and ask them to fill it in. Do not proceed until you have a populated initial doc.

## Outputs (per discovery)

Written under `<repo-root>/.discoveries/<slug>/`:

```
.discoveries/<slug>/
├── README.md            # auto-generated index linking everything below
├── initial-doc.md       # the user's input (possibly with approved improvements applied)
├── linear-context.md    # snapshot from Linear (regenerated on each run)
├── tech-docs/           # only the tech-docs relevant to this change (see Step 4)
│   ├── tech-constraints.md   # almost always present
│   ├── er-diagram.md         # if schema / data model changes
│   ├── openapi.yaml          # if HTTP API surface changes
│   └── asyncapi.yaml         # if events / queues / pub-sub are involved
└── tasks/
    ├── 01-<PARENT>-<slug>.md
    ├── 02-<PARENT>-<slug>.md
    └── ...
```

Repo root is the nearest ancestor containing `.git`. If the user is not in a git repo, ask them where the discovery dir should go before continuing.

## Workflow

For long-form details on parsing, slug rules, and hashing, see [`ref/workflow.md`](ref/workflow.md).

### Step 1 — Set up discovery dir

1. Resolve `<slug>` from the initial-doc frontmatter `discovery:` field. If absent, derive from the first `linear_refs[].key` (lowercased, `-` instead of `:` or `/`).
2. Create `<repo-root>/.discoveries/<slug>/` if it doesn't exist.
3. Copy the user's initial doc into `<dir>/initial-doc.md` if it isn't already there.
4. If the dir already existed, this is a re-invocation — jump to **Re-invocation behavior** at the bottom of this file.

### Step 2 — Fetch Linear context

1. Parse `linear_refs` from `initial-doc.md` frontmatter.
2. For each ref, call the matching Linear MCP tool:
   - `type: issue` → `mcp__claude_ai_Linear__get_issue`
   - `type: epic` → `mcp__claude_ai_Linear__get_issue` (epics are issues)
   - `type: project` → `mcp__claude_ai_Linear__get_project`
   - `type: initiative` → `mcp__claude_ai_Linear__get_initiative`
3. Render `<dir>/linear-context.md` from [`templates/linear-context.md`](templates/linear-context.md), one section per ref.
4. Apply `ws-linear` skill conventions when reading team / label / status fields.

### Step 3 — Gate 1: improve the initial doc

1. Read `initial-doc.md` + `linear-context.md`.
2. Propose targeted improvements. Focus on:
   - Crucial points that are missing or vague
   - Mermaid diagrams that don't match the Linear context
   - Task breakdown gaps (tasks that are too big, missing parents, ambiguous wording)
   - Open questions surfaced by the Linear data
3. Show the user a unified diff of proposed changes.
4. **STOP. Ask the user to approve, edit, or reject.** Do not write anything until approval.
5. On approval, apply the diff to `initial-doc.md`.

### Step 4 — Gate 2: generate tech-docs

The four tech-doc templates are a menu, not a checklist. Pick the subset that matches the actual scope of the change — generating empty or irrelevant tech-docs creates noise the user has to delete and approve through this gate.

1. **Decide which tech-docs are relevant.** Infer scope from the approved `initial-doc.md` + `linear-context.md`:
   - `tech-constraints.md` — almost always include it (perf, security, dependencies, integrations apply to most changes).
   - `er-diagram.md` — include when there are schema changes, new tables/collections, or non-trivial data-model decisions. Skip for pure UI / pure logic changes.
   - `openapi.yaml` — include when the change adds or modifies an HTTP API surface (new endpoints, request/response shape changes, auth changes on routes). Skip for UI-only, internal-library, or async-only work.
   - `asyncapi.yaml` — include when the change involves events, queues, pub/sub, websockets, or other async messaging. Skip for purely synchronous HTTP or UI work.
2. **Tell the user which subset you plan to generate and why** (one short line per doc — "OpenAPI: new `/applications` endpoints", "AsyncAPI: skipped, no async messaging in scope"). If genuinely ambiguous, ask before generating.
3. Pre-fill the chosen tech-docs in `<dir>/tech-docs/` using the matching [`templates/tech-docs/*`](templates/tech-docs/) skeletons, populated from the approved discovery + Linear context. Do **not** create files for the skipped ones.
4. **STOP. Show each generated tech-doc to the user and ask for approval.** Approve all-or-nothing, or per-file — let the user choose. The user can also ask to add back a tech-doc you skipped, or drop one you generated.
5. On approval, persist. On request to revise, edit and re-show. Do not advance until every generated tech-doc is approved.
6. Optional but recommended, only for the docs you generated: run `npx -y @redocly/cli lint <dir>/tech-docs/openapi.yaml` and/or `npx -y @asyncapi/cli validate <dir>/tech-docs/asyncapi.yaml` and surface any errors before requesting approval.

### Step 5 — Generate task markdowns

1. Parse the task breakdown in `initial-doc.md`. Format:
   ```
   ## <PARENT-LINEAR-KEY>
   ### Tasks
   - [ ] Top-level task
     - [ ] sub-bullet
   ```
2. Skip any task already marked `[x]` — do not generate a markdown for completed work.
3. For each remaining top-level task, in document order, emit `tasks/<NN>-<PARENT>-<task-slug>.md` from [`templates/task.md`](templates/task.md):
   - `<NN>` is a zero-padded global index across all parents (`01`, `02`, ...).
   - `<task-slug>` is a short kebab-case version of the task title (≤ 50 chars).
   - Frontmatter: `linear_id: null`, `linear_team`, `parent_linear_key`, `title`, `labels: []`, `last_synced_at: null`, `content_hash: <sha256-of-body>`.
   - Body: title, parent link, description (expanded from the task line + Linear context), acceptance criteria (one per nested sub-bullet, plus any inferred from tech-docs), references to whichever tech-docs were generated in Step 4 (skip the ones that weren't), sub-items list.
4. Generate `<dir>/README.md` linking initial-doc, linear-context, tech-docs, and each task.

### Step 6 — Gate 3 (per task): create Linear tickets

For each task markdown in numeric order:
1. Show the task body to the user.
2. **STOP. Ask the user to approve creation of this task in Linear.**
3. On approval:
   - Call `mcp__claude_ai_Linear__save_issue` with title, description (markdown body minus frontmatter), team key, parent issue (`parent_linear_key`), and labels.
   - Apply `ws-linear` conventions for team selection, label set, and status.
   - Update task frontmatter: `linear_id: <new-id>`, `last_synced_at: <ISO-now>`. Recompute and store `content_hash` of the new body.
4. On reject, leave `linear_id` null and move to the next task.

## Re-invocation behavior — markdown-first sync

When the skill is invoked on an existing discovery dir (Step 1 detects the dir already exists):

1. Re-run **Step 2** (refresh `linear-context.md`).
2. For each `tasks/*.md`:
   - Recompute `content_hash` of the current body.
   - If `linear_id` is null → treat as new (Gate 3 to create).
   - If hash matches stored `content_hash` → no drift, skip.
   - If hash differs → **drift detected**. Show the user a diff of the markdown body vs. what the Linear ticket currently says. **STOP. Ask the user to approve pushing the markdown change to Linear.** On approval, call `mcp__claude_ai_Linear__save_issue` to update, then update `last_synced_at` and stored `content_hash`.
3. Markdown is source of truth. The skill never pulls from Linear into the markdown — if the Linear ticket diverged, the user fixes it by updating the markdown and re-running.

## Conventions

- Always defer to the `ws-linear` skill for team keys, labels, workflow states, and commit message format.
- Never edit a Linear ticket without first updating the corresponding task markdown.
- Never skip a gate. If the user wants to disable gates, they should explicitly say so per-invocation; do not encode a "no-gates" mode by default.
- `[x]` tasks in the initial doc are read for context but never written to Linear.
- Never write the Linear ticket back into the markdown content_hash without a user-approved push — that would mask drift.
