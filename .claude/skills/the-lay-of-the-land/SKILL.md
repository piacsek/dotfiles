---
name: the-lay-of-the-land
description: Read a ticket (Linear, GitHub, Jira, or pasted text) and map it onto the current repo as an ordered table of the files to read before starting, with a two-sentence "why" per file. Also verifies that the ticket's dependencies really landed in code, not just in the tracker. Use when the user runs /the-lay-of-the-land, pastes a ticket and asks "which files do I need to look at", "lay the land", "where do I start on this", or asks to refresh that map after something merged.
---

# The lay of the land

Turn a ticket into a reading list for this repo: which files to read, in what order, and why. The output is orientation, not a plan or a diff. Don't edit code in this skill.

## Input

`ARGUMENTS` is a ticket URL or identifier, or empty. When it's empty, look for a ticket in the conversation, then in the branch name (`git branch --show-current`). If there's still nothing, ask once.

## 1. Gobble the ticket

1. Fetch the ticket with whatever tracker tool is connected (Linear MCP, `gh issue view`, a Jira MCP). Get the description, comments, relations (blocks, blocked by, related) and status.
2. Pull out of the ticket:
   - **Changes**: the numbered or bulleted asks. Each one needs a home in the table.
   - **Cited code**: every `path:line` the ticket mentions. Tickets go stale, so treat these as leads, not facts.
   - **Dependencies**: blocking tickets and PRs, and the behavior this ticket assumes they provide.
   - **Acceptance criteria**: these often name surfaces the changes list leaves out.
3. Read the repo's agent docs (`AGENTS.md`, `CLAUDE.md`, any module docs they point to) for invariants the work must respect, such as i18n, flags or banned libraries.

## 2. Map to files

1. `git fetch -q origin`. Read every file from `origin/<default-branch>` (`git show origin/main:<path>`), not the working tree, because local `main` may be behind.
2. For each change, grep for the symbols, endpoints, ids and strings the ticket names. **Search for every call site, not just the one the ticket cites.** Tickets often name one copy of logic that is duplicated elsewhere. Each extra copy is scope the ticket didn't count.
3. Record current line numbers. If the ticket's line numbers drifted, say so.
4. Find the tests that cover each file (`__tests__/`, `*.test.*`, `*_test.*`) and the locale or translation files if user-facing copy changes.
5. Mark new files the ticket implies as *(new)*.
6. Mark read-only context files, the ones to understand but not change, as such in the "why".

## 3. Verify dependencies in code

The tracker status of a blocking ticket isn't proof. For each dependency the work relies on:

1. Find the PR that closed it (`gh pr view`, or the ticket's attachments) and its merge commit.
2. Check the commit is on the default branch: `git merge-base --is-ancestor <sha> origin/main`.
3. **Check the behavior is still there.** Grep `origin/main` for the key symbols the PR introduced. A later merge can silently overwrite a merged PR, for example when a long-lived branch resolves a conflict to its stale side.
4. If it's missing, find the commit that removed it (`git log --oneline <sha>..origin/main -- <file>`, then inspect any merge commits on that path) and report the commit link. Don't guess at intent: say what the commit message claims and what the diff actually did.

## 4. Output

Lead with the first action, usually "read row 1" or a prerequisite like pulling `main`.

Then the table, ordered as the reader should read it: entry point first, then shared code, consumers, read-only context, tests, copy.

| # | File | Why |
|---|------|-----|
| 1 | `relative/path.ext:start-end` | At most two sentences: what lives here, and which ticket change touches it. |

After the table, a short list of only what changes the plan:

- Dependencies that are missing or not deployed, with commit links.
- Scope the ticket undercounts, like duplicate call sites.
- Uncommitted local changes in mapped files (`git status --short`) that the user shouldn't ship.
- Stale comments or docs in mapped files that contradict the ticket.
- Rough estimate in hours or days, with what drives it.

End with one next action that takes under two minutes, usually opening a specific `path:line`.

## Refresh mode

When the user asks to refresh after something merged or changed:

1. Re-fetch the ticket and its dependencies, and fetch `origin` again.
2. Re-derive line numbers from the new `origin/main`.
3. Open with a "what changed since the last pass" list, then print the full table again rather than a diff of it.

## Rules

- Read-only. No edits, commits, tracker updates or comments unless the user asks separately.
- Don't trust ticket line numbers or tracker statuses without checking the code.
- The table holds files only. Put caveats below it, not in the "why" column.
