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
DRAFTING NOTES (delete before saving to Linear — these don't belong in the ticket body):
- Narrow scope. Build instructions only. No alternatives-considered, no soft-dep coordination, no conversation recap.
- NO "Parent story: …" line. Linear renders parent-child natively.
- Discovery artifacts: link only the docs that apply to this ticket's layer
  (DB → ER only; API → ER + OpenAPI; UI → OpenAPI + UI diagrams; async → AsyncAPI ± ER).
- Tests: default to "Integration tests (`*.ispec.ts`) cover: …" — not unit tests.
- Doc references: clickable markdown links, never bare paths.
- Tables: top-level `##` section, never indented under a bullet. Bold-in-cell needs a U+200B ZWSP inside the closing `**`.
- Read the existing Linear ticket before any update (`get_issue` before `save_issue`).
-->

# <Task title>

One-sentence statement of what this ticket does and why it exists. Skip the conversation history.

## Acceptance criteria

- [ ] ...
- [ ] ...
- [ ] Integration tests (`*.ispec.ts`) cover: <variants the test must exercise>

## Open questions

(optional — list anything the implementer must resolve before coding. Omit the section if none.)

* ...

## Discovery artifacts

Pick the subset that matches the ticket's layer. Drop the lines that don't apply.

- ER diagram: [`../diagrams/er.mmd`](../diagrams/er.mmd)
- API contract: [`../tech-docs/openapi.yaml`](../tech-docs/openapi.yaml) — `<SchemaName>` / `<path>`
- UI diagram(s): [`../diagrams/<flow-name>.mmd`](../diagrams/<flow-name>.mmd)
- AsyncAPI: [`../tech-docs/asyncapi.yaml`](../tech-docs/asyncapi.yaml)
- Constraints: [`../tech-docs/tech-constraints.md`](../tech-docs/tech-constraints.md)

## References

Only cross-references Linear doesn't auto-render. Drop the section entirely if none apply.

- Depends on: <SIBLING-KEY> — short reason
- Extends: <SIBLING-KEY> — short reason
