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
argument-hint: "<path to initial doc OR slug OR Linear key for inline mode>"
---

# Tech discovery

A 6-step discovery workflow. **Every gate stops and waits for user approval.** Gates sit in front of file generation and Linear ticket creation; the cost of asking is low, the cost of skipping is high. Do not "optimize" them away.

## When to invoke

- User asks to start a tech discovery, generate tech-docs from a discovery doc, or break a Linear story into ≤1-day tasks.
- `/tech-discovery <path>` — standard mode, path to an initial-doc markdown.
- `/tech-discovery <slug>` — resume / re-sync an existing discovery dir.
- `/tech-discovery <LINEAR-KEY>` — **inline mode**: bootstrap from a Linear parent, no initial-doc, no per-task markdowns.

## Modes

- **Standard**: initial-doc.md (from [`templates/initial-doc.md`](templates/initial-doc.md)) declares scope + task breakdown. Per-task markdowns are the source of truth and sync into Linear.
- **Inline**: parent Linear story + chat context drives sub-ticket drafts; tickets are drafted in the chat and created directly. No initial-doc, no per-task markdowns.

If the user has neither an initial doc nor a Linear parent ready, copy `templates/initial-doc.md` to a path they specify and pause.

## Outputs

Default location: `<repo-root>/.discoveries/<slug>/`. **Ask** before creating — some projects keep discoveries in a peer docs repo (e.g., `<sibling-repo>/.discoveries/<slug>/`).

```
.discoveries/<slug>/
├── README.md            # auto-generated index (standard mode only)
├── initial-doc.md       # standard mode only
├── linear-context.md    # standard mode only
├── tech-docs/           # subset relevant to this change (see Step 4)
│   ├── tech-constraints.md
│   ├── er-diagram.md
│   ├── openapi.yaml
│   └── asyncapi.yaml
├── diagrams/            # mermaid sequence / state / flow diagrams
└── tasks/               # standard mode only
    └── <NN>-<PARENT>-<slug>.md
```

## Workflow

For parsing, slug rules, and hashing, see [`ref/workflow.md`](ref/workflow.md).

### Step 1 — Set up discovery dir

1. Slug: `discovery:` frontmatter (standard) or lowercased Linear key (inline).
2. Resolve dir location. Default `<repo-root>/.discoveries/<slug>/`; ask if there's a project-specific convention.
3. Create dir; copy the initial doc in (standard mode).
4. If the dir already existed, jump to **Re-invocation behavior** below.

### Step 2 — Fetch Linear context

Parse refs (`linear_refs` in standard mode; parent key + siblings the user mentions in inline mode) and call the matching Linear MCP tool per ref type (`get_issue` / `get_project` / `get_initiative`). Standard mode writes `linear-context.md`; inline mode keeps the context in memory.

Defer to the `ws-linear` skill for team / label / status conventions.

### Step 3 — Gate 1: improve the initial doc (standard only)

Inline mode skips this gate (refinement is conversational).

Propose targeted improvements: missing crucial points, diagrams that don't match Linear, task-breakdown gaps, open questions surfaced by Linear data. Show a unified diff. **STOP for approval.** Apply on approval.

### Step 4 — Gate 2: generate tech-docs

Pick the subset that matches scope — generating empty/irrelevant docs creates rework.

| Doc | Include when |
| --- | --- |
| `tech-constraints.md` | Almost always (skip in inline mode unless asked) |
| `er-diagram.md` | Schema / data-model changes |
| `openapi.yaml` | HTTP API surface changes |
| `asyncapi.yaml` | Events / queues / pub-sub / websockets |
| `diagrams/*.mmd` (sequence / state / flow) | Multi-step interaction worth visualizing |

**OpenAPI extension**: when a sibling discovery owns a base contract for the same surface, this discovery's `openapi.yaml` extends it (header note pointing to the base) and documents only additions / changes. Don't duplicate the base.

State which docs you'll generate in one short line each. Pre-fill from [`templates/tech-docs/*`](templates/tech-docs/). **STOP for approval** (per-file or all-at-once, user's choice).

Optional but recommended on the generated docs:
- `npx -y @redocly/cli lint <dir>/tech-docs/openapi.yaml`
- `npx -y @asyncapi/cli validate <dir>/tech-docs/asyncapi.yaml`

### Step 5 — Generate task markdowns (standard only)

Inline mode drafts each ticket in chat right before Gate 3 instead.

1. Parse `## <PARENT-LINEAR-KEY>` → `### Tasks` → `- [ ] …` blocks in `initial-doc.md`.
2. Skip `[x]` tasks.
3. For each remaining task, emit `tasks/<NN>-<PARENT>-<task-slug>.md` from [`templates/task.md`](templates/task.md). `<NN>` is a global zero-padded index. Frontmatter: `linear_id: null`, `linear_team`, `parent_linear_key`, `title`, `labels: []`, `last_synced_at: null`, `content_hash: <sha256-of-body>`.
4. Generate `<dir>/README.md` linking everything.

### Step 6 — Gate 3 (per task): create Linear tickets

For each task:
1. Show body to user. Inline mode: draft it in chat first using the **Linear ticket conventions** below.
2. **STOP for approval.**
3. On approval: `mcp__claude_ai_Linear__save_issue` with title, description, team, parent issue, labels. Apply `ws-linear` conventions for team / labels / status. Standard mode: update frontmatter `linear_id` + `last_synced_at` + `content_hash`.
4. On reject: skip, move on.

## Linear ticket conventions

Apply to every ticket body you draft or update — task markdowns and inline drafts alike.

### Content

- **Narrow scope.** Build instructions only. A one-sentence "why this exists" is fine; multi-paragraph rationale belongs in the parent story.
- **Less is more.** Mention alternatives considered only when the rejected path explains the chosen one. Skip soft-dependency coordination, conversation recaps, and "things we ruled out but might revisit."
- **No "Parent story: …" line.** Linear renders parent-child natively. The References section is only for cross-references Linear doesn't auto-render (sibling deps, "extends", related-but-not-parent).
- **Integration tests by default.** AC test wording: `Integration tests (\`*.ispec.ts\`) cover: …`. Unit tests only for genuinely pure modules.
- **Doc references as clickable links.** Never bare paths. product-docs URLs: `https://docs.wonderschool.io/<path-without-content-prefix>`.

### Discovery artifact references by layer

| Ticket layer | Link |
| --- | --- |
| DB / migration / repository | ER only |
| API / use-case / endpoint | ER + OpenAPI |
| UI / React | OpenAPI + UI diagrams; skip ER unless touching persistence |
| Async / queue / event | AsyncAPI ± ER |

### Linear renderer quirks

- **Tables can't be indented under bullets.** The parser mangles cells. Put tables in their own top-level `##` section and reference from bullets.
- **Bold-in-table-cell coercion.** `**identifier**` in a cell becomes `` `identifier` `` (backticks) when the content looks like a code token. HTML `<strong>` renders literally. **Workaround:** ZWSP (U+200B) inside the closing `**` — `**identifier​**`.
- Preserve image embeds (`![…](https://uploads.linear.app/…)`) on re-save.

### Read-before-write

**Always `get_issue` before `save_issue` on an existing ticket.** Users make manual edits between AI updates; blind overwrites destroy them silently. On unexplained edits, ask before overwriting.

## Re-invocation behavior (standard mode)

Inline mode has no markdown source of truth; re-invoking just refreshes Linear context.

For an existing standard-mode dir:
1. Re-run Step 2 (refresh `linear-context.md`).
2. For each `tasks/*.md`: recompute `content_hash`.
   - `linear_id` null → Gate 3 to create.
   - Hash matches → skip.
   - Hash differs → **drift**. `get_issue` first, show diff vs Linear, **STOP for approval**, then `save_issue`, update `last_synced_at` + `content_hash`.
3. Markdown is source of truth. The skill never pulls Linear → markdown.

## Conventions

- Defer to `ws-linear` for team keys, labels, workflow states, commit message format.
- Apply **Linear ticket conventions** above to every ticket draft/update.
- Read before write, always.
- Never skip a gate.
- `[x]` tasks are read for context, never written to Linear.
- Never write the Linear ticket body back into the markdown `content_hash` without user-approved push — that masks drift.
