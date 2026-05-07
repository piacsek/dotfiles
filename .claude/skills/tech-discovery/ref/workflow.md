# tech-discovery — workflow reference

Long-form details for the agent. Loaded only when needed; the main `SKILL.md` keeps the high-level recipe.

## Slug resolution

Order of preference for `<slug>`:

1. `discovery:` field in `initial-doc.md` frontmatter, kebab-case validated.
2. First entry of `linear_refs[].key`, lowercased, with `:` and `/` replaced by `-` (e.g. `LIC-322` → `lic-322`).
3. If neither is present, ask the user.

Slug must match `^[a-z0-9][a-z0-9-]{1,63}$`. Reject anything else and ask the user to rename.

## Repo-root detection

```bash
git -C "$PWD" rev-parse --show-toplevel
```

If that fails (no git repo), ask the user where to put the discovery dir before continuing. Do not silently create it under `$HOME` or `/tmp`.

## Linear refs parsing

Frontmatter shape:

```yaml
linear_refs:
  - key: LIC-322
    type: issue
  - key: LIC-300
    type: project
```

`type` values map to MCP tools:

| type        | MCP tool                                          |
|-------------|---------------------------------------------------|
| issue       | `mcp__claude_ai_Linear__get_issue`                |
| epic        | `mcp__claude_ai_Linear__get_issue` (epics are issues) |
| project     | `mcp__claude_ai_Linear__get_project`              |
| initiative  | `mcp__claude_ai_Linear__get_initiative`           |

Validate `key` against `^[A-Z]{2,5}-\d+$` for issue/epic. Project/initiative IDs are UUIDs in Linear — accept either the human-readable key or a UUID.

## Task-breakdown parser

Recognized structure inside `initial-doc.md`:

```
## <PARENT>
### Tasks
- [ ] Top-level task title
  - [ ] sub-bullet
  - [ ] sub-bullet
- [x] Completed top-level task — skip
- [ ] Next top-level task
```

Rules:
- A `## <KEY>` heading whose next non-empty heading is `### Tasks` opens a task group bound to that parent.
- Each top-level checkbox under `### Tasks` is one task.
- Nested checkboxes (indented) are sub-items of the preceding top-level task.
- `[x]` at the top level → skip entirely (no markdown emitted, no Linear ticket).
- `[x]` on a nested sub-item → keep, but render as completed in the task body.

## Task slug + filename

```
tasks/<NN>-<PARENT>-<task-slug>.md
```

- `<NN>` = zero-padded global index across all parents (`01`, `02`, ... `99`). Order is document order.
- `<task-slug>` = lowercase the title, drop punctuation, replace whitespace with `-`, truncate at 50 chars on a word boundary.
- Example: task 3, parent `LIC-322`, title `"Adjustment in the upload endpoint to enable the upload of the fingerprint screenshot"`:
  → `tasks/03-LIC-322-adjustment-in-the-upload-endpoint-to-enable.md`

## Content hash

```python
hashlib.sha256(body_without_frontmatter.encode("utf-8")).hexdigest()
```

- `body_without_frontmatter` is the markdown body after the closing `---` of YAML frontmatter, stripped of trailing whitespace.
- Store as the `content_hash:` frontmatter value.
- Recompute on every re-invocation. Compare to stored value to detect drift.

## Linear ticket creation

`mcp__claude_ai_Linear__save_issue` payload:

```json
{
  "title": "<task title from frontmatter>",
  "description": "<markdown body without frontmatter>",
  "team": "<linear_team from frontmatter>",
  "parentId": "<resolved Linear UUID for parent_linear_key>",
  "labels": ["<label>", ...]
}
```

To resolve `parent_linear_key` → Linear UUID, call `get_issue` once and cache for the duration of the run.

After creation, re-read the new issue to confirm assignment, status, and final ID, then update task frontmatter.

## Drift handling

On re-invocation:

```
for each tasks/*.md:
  current_hash = sha256(body_without_frontmatter)
  if frontmatter.linear_id is null:
    → run Gate 3 (create)
  elif current_hash == frontmatter.content_hash:
    → no drift, skip
  else:
    → drift detected
    → fetch current Linear ticket via get_issue(linear_id)
    → diff Linear description vs markdown body
    → STOP. Ask user to approve push markdown→Linear.
    → on approval: save_issue(...), update last_synced_at + content_hash
```

The skill never reads Linear and writes to the markdown — that would mask divergent edits made directly in the markdown.

## Optional schema linting (recommended)

Before Gate 2 approval, only for the tech-docs you actually generated in Step 4 (some changes don't need OpenAPI or AsyncAPI — see the scope-decision rules in the main SKILL.md):

```bash
# only if openapi.yaml was generated
npx -y @redocly/cli lint <dir>/tech-docs/openapi.yaml

# only if asyncapi.yaml was generated
npx -y @asyncapi/cli validate <dir>/tech-docs/asyncapi.yaml
```

Surface errors inline in the gate; do not auto-fix. The user decides whether to revise before approving.

## ws-linear conventions

When creating or updating Linear tickets, defer to the `ws-linear` skill for:
- Team key selection (e.g. `LIC` for licensing work)
- Label set (existing labels only — do not invent new ones)
- Workflow state mapping
- Parent / child relationships
- Commit message format `[TICKET] Description`

If a discovery references multiple teams (e.g. `LIC-322` and `MP-5500`), tasks inherit their team from the parent ticket, not from a global default.

## README.md (per discovery)

Auto-generated at the discovery root. Shape:

```markdown
# <Discovery title>

- Initial doc: [`initial-doc.md`](initial-doc.md)
- Linear context: [`linear-context.md`](linear-context.md)
- Tech docs (only list the ones generated for this discovery — see Step 4 in SKILL.md):
  - [`tech-docs/tech-constraints.md`](tech-docs/tech-constraints.md)
  - [`tech-docs/er-diagram.md`](tech-docs/er-diagram.md)        # if schema/data model changes
  - [`tech-docs/openapi.yaml`](tech-docs/openapi.yaml)          # if HTTP API surface changes
  - [`tech-docs/asyncapi.yaml`](tech-docs/asyncapi.yaml)        # if events/queues/pub-sub involved
- Tasks:
  - [`tasks/01-<PARENT>-<slug>.md`](tasks/01-...) — <title> — <linear_id or "not yet created">
  - ...
```

Regenerate at the end of every run (cheap, keeps the index in sync).
