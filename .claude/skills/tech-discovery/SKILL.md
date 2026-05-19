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
argument-hint: "<path to initial doc OR slug of existing discovery OR Linear key for inline mode>"
---

# Tech discovery

This skill encodes a 6-step discovery workflow. **Every gate stops and waits for user approval before continuing** — gates exist because the next step has a permanent or expensive side effect (file generation, Linear ticket creation). Do not "optimize" gates away; they are the point.

> Convention note: existing skills like `initiative` say *"Never gate progress."* This skill is intentionally the opposite. Each gate sits in front of an action that is hard or annoying to reverse, so the cost of asking is low and the cost of skipping is high.

## When to invoke

- User asks to start a tech discovery, generate tech-docs from a discovery doc, or break a Linear story into ≤1-day tasks.
- User says `/tech-discovery <path>` with a path to an initial-doc markdown.
- User says `/tech-discovery <slug>` to resume / re-sync an existing discovery dir.
- User says `/tech-discovery <LINEAR-KEY>` to run **inline mode** — bootstrap directly from a Linear parent story, no initial-doc, no per-task markdowns.

## Inputs

Two supported input shapes:

1. **Standard mode** — initial-doc markdown the user filled in from [`templates/initial-doc.md`](templates/initial-doc.md). The path is the skill argument, or the user is prompted for it. The doc must declare at least one Linear ref in its frontmatter (`linear_refs`).
2. **Inline mode** — a Linear parent key (e.g. `LIC-607`). No initial-doc, no per-task markdowns. The parent story plus conversation provides scope; sub-ticket bodies are drafted in chat and approved one-by-one before creation. Use this when the user has a parent story already authored in Linear and wants to skip the markdown round-trip.

If the user has neither, copy `templates/initial-doc.md` to a path they specify and ask them to fill it in. Do not proceed until you have either a populated initial doc OR a Linear parent key plus enough conversation context to draft tickets.

## Outputs (per discovery)

Default location is `<repo-root>/.discoveries/<slug>/`, where repo root is the nearest ancestor containing `.git`. **Some projects keep discoveries in a peer docs repo** (e.g., `<sibling-repo>/.discoveries/<slug>/`) — ask the user if there's a project-specific convention before creating the dir.

Standard-mode layout:

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
├── diagrams/            # optional mermaid diagrams (sequence, state, flow, …)
└── tasks/
    ├── 01-<PARENT>-<slug>.md
    ├── 02-<PARENT>-<slug>.md
    └── ...
```

Inline-mode layout drops `initial-doc.md` and `tasks/`. `tech-docs/` and `diagrams/` still apply.

## Workflow

For long-form details on parsing, slug rules, and hashing, see [`ref/workflow.md`](ref/workflow.md).

### Step 1 — Set up discovery dir

1. Resolve `<slug>`:
   - Standard mode: from the initial-doc frontmatter `discovery:` field; if absent, derive from the first `linear_refs[].key`.
   - Inline mode: lowercased Linear parent key (`LIC-607` → `lic-607`).
2. Resolve dir location. Default `<repo-root>/.discoveries/<slug>/`. **Ask** if there's a project-specific convention (peer docs repo, etc.) before creating.
3. Create the dir if it doesn't exist.
4. Standard mode: copy the user's initial doc into `<dir>/initial-doc.md` if it isn't already there.
5. If the dir already existed, this is a re-invocation — jump to **Re-invocation behavior** at the bottom of this file.

### Step 2 — Fetch Linear context

1. Parse Linear refs:
   - Standard mode: `linear_refs` frontmatter in `initial-doc.md`.
   - Inline mode: the parent key passed as the argument, plus any related sibling tickets the user mentions in chat.
2. For each ref, call the matching Linear MCP tool:
   - `type: issue` → `mcp__claude_ai_Linear__get_issue`
   - `type: epic` → `mcp__claude_ai_Linear__get_issue` (epics are issues)
   - `type: project` → `mcp__claude_ai_Linear__get_project`
   - `type: initiative` → `mcp__claude_ai_Linear__get_initiative`
3. Standard mode: render `<dir>/linear-context.md` from [`templates/linear-context.md`](templates/linear-context.md), one section per ref. Inline mode: keep the context in working memory only — no file written.
4. Apply `ws-linear` skill conventions when reading team / label / status fields.

### Step 3 — Gate 1: improve the initial doc (standard mode only)

Inline mode skips this gate. Refinement happens conversationally against the Linear parent story.

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

1. **Decide which tech-docs are relevant.** Infer scope from the parent context (initial-doc + linear-context in standard mode; Linear parent + chat in inline mode):
   - `tech-constraints.md` — almost always include it (perf, security, dependencies, integrations apply to most changes). Skip in inline mode unless the user explicitly asks.
   - `er-diagram.md` (`.mmd`) — include when there are schema changes, new tables/collections, or non-trivial data-model decisions. Skip for pure UI / pure logic changes.
   - `openapi.yaml` — include when the change adds or modifies an HTTP API surface (new endpoints, request/response shape changes, auth changes on routes). Skip for UI-only, internal-library, or async-only work.
   - `asyncapi.yaml` — include when the change involves events, queues, pub/sub, websockets, or other async messaging. Skip for purely synchronous HTTP or UI work.
   - **Sequence / state / flow diagrams** (`.mmd` under `<dir>/diagrams/`) — include when the change has a multi-step interaction worth visualizing (UI ↔ API ↔ DB, finite state machine, async hand-off). Useful even when scope is mostly UI.
2. **OpenAPI extension pattern**: when a sibling discovery already owns a base OpenAPI contract for the surface you're touching, this discovery's `openapi.yaml` should explicitly extend it (header note pointing to the base file) and document only the additions / response-shape changes. Don't duplicate the full base spec.
3. **Tell the user which subset you plan to generate and why** (one short line per doc — "OpenAPI: new `/applications` endpoints", "AsyncAPI: skipped, no async messaging in scope"). If genuinely ambiguous, ask before generating.
4. Pre-fill the chosen tech-docs in `<dir>/tech-docs/` (and any diagrams in `<dir>/diagrams/`) using the matching [`templates/tech-docs/*`](templates/tech-docs/) skeletons. Do **not** create files for the skipped ones.
5. **STOP. Show each generated tech-doc to the user and ask for approval.** Approve all-or-nothing, or per-file — let the user choose. The user can also ask to add back a tech-doc you skipped, or drop one you generated.
6. On approval, persist. On request to revise, edit and re-show. Do not advance until every generated tech-doc is approved.
7. Optional but recommended, only for the docs you generated: run `npx -y @redocly/cli lint <dir>/tech-docs/openapi.yaml` and/or `npx -y @asyncapi/cli validate <dir>/tech-docs/asyncapi.yaml` and surface any errors before requesting approval.

### Step 5 — Generate task markdowns (standard mode only)

Inline mode skips this step. Task drafting happens in chat right before each Gate 3 approval (see Step 6).

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
   - Body: title, description (expanded from the task line + Linear context), acceptance criteria, references to whichever tech-docs were generated in Step 4 *and apply to this ticket's layer* (see Linear ticket conventions below), sub-items list.
   - **Do NOT include a "Parent story" line in the body** — Linear renders parent-child natively.
4. Generate `<dir>/README.md` linking initial-doc, linear-context, tech-docs, and each task.

### Step 6 — Gate 3 (per task): create Linear tickets

For each task (markdown in standard mode, drafted-in-chat in inline mode), in order:

1. Show the task body to the user. In inline mode, draft it in the chat first using the **Linear ticket conventions** below.
2. **STOP. Ask the user to approve creation of this task in Linear.**
3. On approval:
   - Call `mcp__claude_ai_Linear__save_issue` with title, description (markdown body minus frontmatter in standard mode; drafted body in inline mode), team key, parent issue (`parent_linear_key`), and labels.
   - Apply `ws-linear` conventions for team selection, label set, and status.
   - Standard mode: update task frontmatter `linear_id: <new-id>`, `last_synced_at: <ISO-now>`. Recompute and store `content_hash` of the new body.
4. On reject, leave the markdown (if any) un-synced and move to the next task.

## Linear ticket conventions

These conventions apply to **every** ticket body you draft or update — both per-task markdowns and inline-mode drafts. They encode hard-learned quirks of Linear's renderer + the team's review preferences. Skipping any of them generates predictable rework.

### Body content

- **Narrow scope.** Sub-issues are build instructions, not design history. Skip alternatives-considered, soft-dependency coordination, and recaps of conversation that led to the design. A one-sentence "why this ticket exists" is fine; multi-paragraph rationale belongs in the parent story (or a DB ticket's "Design rationale" section when load-bearing).
- **Don't restate the parent.** Never include a "Parent story: …" line — Linear renders parent-child links natively. The References section is only for cross-references Linear doesn't auto-render (sibling deps, "extends", related-but-not-parent).
- **Prefer integration tests.** AC test wording defaults to `Integration tests (\`*.ispec.ts\`) cover: …`. Reach for unit tests only for genuinely pure modules; even then, an integration test through the caller usually wins.
- **Doc references as clickable links.** Never bare paths like `content/foo/bar.md`. Use full markdown links — for product-docs, the URL is `https://docs.wonderschool.io/<path-without-content-prefix>`.

### Discovery artifact references by layer

When listing `## Discovery artifacts` in a sub-ticket, scope by the ticket's layer:

| Ticket type | Link |
| --- | --- |
| DB / migration / repository | ER diagram only |
| API / use-case / endpoint | ER diagram **and** OpenAPI (the OpenAPI's join shape matters to the implementer) |
| UI / React | OpenAPI **and** UI-side diagrams (sequence, state). Skip ER unless reasoning about persistence |
| Async / queue / event | AsyncAPI, plus ER if the consumer touches storage |

Cross-linking every artifact from every ticket is noise — implementers stop reading.

### Linear renderer quirks

- **Tables can't be indented under bullets.** Linear's parser mangles cell contents (backticks get eaten, columns truncate). Put tables in their own top-level `##` section and reference them from bullets ("see the table above").
- **Bold-in-table-cell coercion.** `**identifier**` in a single table cell gets silently rewritten to `` `identifier` `` (backticks) when the content looks like a code token. HTML `<strong>` renders literally (visible tags). **Workaround:** append a zero-width space (U+200B) inside the closing `**` — `**identifier​**`. The ZWSP breaks the heuristic; renders as bold with no visible artifact.
- **Image embeds survive saves.** If the user adds a screenshot to a ticket, preserve the `![…](https://uploads.linear.app/…)` line on re-save.

### Read-before-write

**Always `get_issue` before `save_issue` on an existing ticket.** Users routinely make manual edits between AI updates — blind overwrites silently destroy them. On unexplained edits, ask before overwriting (or merge in the user's changes). Only skip the read when creating a brand-new ticket.

### Iteration / drift

Tickets evolve after creation — review cycles surface drift between parent AC and sub-issues, label/numbering renames cascade across siblings, OpenAPI shapes change. Treat sub-issue creation as the start, not the end, of the drafting work. Re-sweep affected tickets when scope shifts.

## Re-invocation behavior — markdown-first sync (standard mode)

Inline mode has no markdown source of truth, so there's nothing to re-sync — re-invoking just refreshes the Linear context in working memory.

When the skill is invoked on an existing standard-mode discovery dir (Step 1 detects the dir already exists):

1. Re-run **Step 2** (refresh `linear-context.md`).
2. For each `tasks/*.md`:
   - Recompute `content_hash` of the current body.
   - If `linear_id` is null → treat as new (Gate 3 to create).
   - If hash matches stored `content_hash` → no drift, skip.
   - If hash differs → **drift detected**. **Re-read the Linear ticket first** (`get_issue`). Show the user a diff of the markdown body vs. what the Linear ticket currently says. **STOP. Ask the user to approve pushing the markdown change to Linear.** On approval, call `mcp__claude_ai_Linear__save_issue` to update, then update `last_synced_at` and stored `content_hash`.
3. Markdown is source of truth. The skill never pulls from Linear into the markdown — if the Linear ticket diverged, the user fixes it by updating the markdown and re-running.

## Conventions

- Always defer to the `ws-linear` skill for team keys, labels, workflow states, and commit message format.
- Apply all rules in **Linear ticket conventions** above when drafting or updating any ticket body.
- Never edit a Linear ticket without first reading it (read-before-write).
- In standard mode, never edit a Linear ticket without first updating the corresponding task markdown.
- Never skip a gate. If the user wants to disable gates, they should explicitly say so per-invocation; do not encode a "no-gates" mode by default.
- `[x]` tasks in the initial doc are read for context but never written to Linear.
- Never write the Linear ticket back into the markdown content_hash without a user-approved push — that would mask drift.
