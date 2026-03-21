---
name: linear-context
description: Fetch Linear ticket context from the current git branch
---

Infer the Linear ticket the user is working on and fetch its full context.

## Steps

1. Run `git branch --show-current` to get the current branch name
2. Extract the ticket ID from the branch name - the format is `TICKETID/slug` (e.g. `MP-5051/fl-early-learning-add-photo-editing`)
3. Use Linear's MCP `search_issues` tool to find the ticket by its ID
4. Use Linear's MCP `get_issue` tool to fetch the full ticket details
5. Present a summary of the ticket including:
   - Title
   - Status
   - Assignee
   - Description
   - Any sub-issues or related issues if present
