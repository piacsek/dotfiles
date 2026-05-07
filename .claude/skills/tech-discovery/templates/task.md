---
linear_id: null                    # populated after Gate 3 creates the issue
linear_team: <team-key>            # e.g. LIC
parent_linear_key: <PARENT-KEY>
title: <short imperative title>
labels: []
last_synced_at: null               # ISO-8601 of last push to Linear
content_hash: null                 # sha256 of body — drift detection
---

# <Task title>

## Parent
- Parent ticket: [<PARENT-KEY>](<linear-url>)
- Discovery: [`../README.md`](../README.md)

## Description

What needs to be done. Small, self-contained, and parallelizable with the other tasks where possible.

## Acceptance criteria

- [ ] ...
- [ ] ...

## References

Only include the tech-docs that were generated for this discovery (see Step 4 in SKILL.md — OpenAPI/AsyncAPI/ER are conditional on scope). Drop the lines that don't apply.

- Constraints: [`../tech-docs/tech-constraints.md`](../tech-docs/tech-constraints.md)
- ER diagram: [`../tech-docs/er-diagram.md`](../tech-docs/er-diagram.md)
- OpenAPI: [`../tech-docs/openapi.yaml`](../tech-docs/openapi.yaml) — section `<path-or-anchor>`
- AsyncAPI: [`../tech-docs/asyncapi.yaml`](../tech-docs/asyncapi.yaml)
- User story: [<STORY-KEY>](<linear-url>)

## Sub-items

(populated from nested checkboxes in `initial-doc.md`)

- [ ] ...

## Implementation notes

<optional — anything the implementer should know>
