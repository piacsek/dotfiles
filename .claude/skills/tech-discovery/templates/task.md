---
linear_id: null                    # populated after Gate 3 creates the issue
linear_team: <team-key>            # e.g. LIC
parent_linear_key: <PARENT-KEY>
title: <short imperative title>
labels: []
last_synced_at: null               # ISO-8601 of last push to Linear
content_hash: null                 # sha256 of body — drift detection
---

<!--
Delete this block before saving to Linear.
See SKILL.md → "Linear ticket conventions" for the full rules. Highlights:
- Narrow scope. No alternatives unless they explain the chosen path. No conversation recap.
- No "Parent story: …" line — Linear renders parent-child natively.
- Discovery artifacts by layer (DB → ER; API → ER + OpenAPI; UI → OpenAPI + UI diagrams).
- Tests default to integration (`*.ispec.ts`).
- Doc references as clickable links.
- Tables: top-level only, never under a bullet. Bold-in-cell needs ZWSP (U+200B) inside closing `**`.
- Read before write: `get_issue` before any `save_issue` on an existing ticket.
-->

# <Task title>

One sentence on what this ticket does. Skip the conversation history.

## Acceptance criteria

- [ ] ...
- [ ] ...
- [ ] Integration tests (`*.ispec.ts`) cover: <variants>

## Open questions

(optional — only implementer-blocking unknowns; omit the section if none)

* ...

## Discovery artifacts

Keep only the lines that apply to this ticket's layer. Drop the rest.

- ER diagram: [`../diagrams/er.mmd`](../diagrams/er.mmd)
- API contract: [`../tech-docs/openapi.yaml`](../tech-docs/openapi.yaml) — `<SchemaName>` / `<path>`
- UI diagram(s): [`../diagrams/<flow-name>.mmd`](../diagrams/<flow-name>.mmd)
- AsyncAPI: [`../tech-docs/asyncapi.yaml`](../tech-docs/asyncapi.yaml)
- Constraints: [`../tech-docs/tech-constraints.md`](../tech-docs/tech-constraints.md)

## References

Only cross-references Linear doesn't auto-render. Drop the section if none.

- Depends on: <SIBLING-KEY> — short reason
- Extends: <SIBLING-KEY> — short reason
