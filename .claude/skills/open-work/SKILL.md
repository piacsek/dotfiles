---
name: open-work
description: Show every open GitHub PR the user authored or is assigned to as one dense assessment table, bucketed by what needs doing next, and turn each PR into a task on the Claude task list. Use when the user runs /open-work, asks "what's my open work", "what should I work on", "triage my PRs", or asks to refresh that view ("/open-work refresh").
---

# Open work

Turn the user's open PRs into one table and one task list. The task list then drives the session: one PR at a time, most urgent first. This skill only reads GitHub.

## 1. Fetch

Run the bundled script. It searches `is:pr is:open archived:false` for both `author:@me` and `assignee:@me` across all orgs, dedupes by URL, and prints a JSON array:

```bash
~/.claude/skills/open-work/fetch.sh
```

Each row has: `repo number title url branch roles author owned draft review mergeable ci threads requested updated idle_days size`.

- `roles` is `["author"]`, `["assignee"]` or both.
- `owned` is true when the user wrote it or a bot did (bot PRs assigned to the user are the user's to land).
- `threads` counts review threads that are neither resolved nor outdated.
- `ci` is the head commit's check rollup: `SUCCESS`, `FAILURE`, `ERROR`, `PENDING`, `EXPECTED` or `NONE`.
- `mergeable` can be `UNKNOWN` right after a push. Treat it as not conflicting.

If the script fails, show the error and stop. Don't fall back to a partial list.

## 2. Assess

Give each PR exactly one bucket, the first that matches:

| Bucket | Condition | Next action |
|---|---|---|
| 1 Broken | `owned`, and `ci` is `FAILURE`/`ERROR` or `mergeable` is `CONFLICTING` | Fix CI (`gh pr checks <n>`) or rebase |
| 2 Feedback | `owned`, and `review` is `CHANGES_REQUESTED` or `threads > 0` | `/pr-comments` on the branch |
| 3 Ship | `owned`, `review` is `APPROVED`, `ci` is `SUCCESS`, not draft | Merge |
| 4 Finish | `owned`, draft, `ci` is `SUCCESS` | Reviewer pass on the diff, then mark ready |
| 5 Someone else's | not `owned` | `/pr-review`, or ask the author what the assignment means |
| 6 Waiting | everything else (CI pending, awaiting review) | Nothing now. Nudge reviewers if `idle_days > 3` |

Within a bucket, oldest `updated` first.

For bucket 1 CI failures, run `gh pr checks <n> --repo <repo>` and name the failing check in the Next column. Don't dig into logs yet; that's the task's work.

## 3. Table

One line of totals first, e.g. `13 open: 2 broken, 3 feedback, 0 ship, 2 finish, 1 someone else's, 5 waiting.`

Then one table, rows in bucket order, with the bucket number as the first column so groups stay visible:

| B | PR | Title | Role | Draft | CI | Review | Thr | Idle | Size | Next |
|---|----|-------|------|-------|----|--------|-----|------|------|------|
| 1 | [ws-common#8875](url) | Pin rebar3 for Nova builds | A | | ❌ | 👀 | 0 | 0d | +42/-18 | Fix `nova-build` |

- PR: short repo name plus number, linked.
- Title: at most ~50 chars, cut at a word boundary.
- Role: `A` author, `As` assignee, `A+As` both.
- Draft: `✎` or blank.
- CI: ✅ success, ❌ failure/error, ⏳ pending/expected, — none. Append `⚔` for conflicts.
- Review: ✅ approved, 🔁 changes requested, 👀 review required, — none.
- Next: at most ~6 words, a verb first.

No prose between rows. After the table, list only what changes priorities: a PR idle over 7 days, a huge diff (over 1000 changed lines) that is probably a bad base, an assignment that looks wrong. At most 3 lines.

## 4. Tasks

1. `TaskList` first. A task whose description contains a PR's URL is that PR's task: `TaskUpdate` its subject and description instead of creating a duplicate. Mark tasks whose PR is no longer in the list `completed`.
2. `TaskCreate` one task per remaining PR, in table order.
   - **subject**: `<Next action> <repo>#<n>: <short title>`, e.g. `Fix nova-build CI ws-common#8875: pin rebar3`.
   - **description**: URL, branch, bucket, the row's signals in one line, and the exact skill or command to start with.
3. Mark the first task `in_progress`.

## 5. Hand-off

End with one line naming task 1 and its first command, then stop. Don't start working the task until the user says go.

When the user moves on to a task, run its mapped skill or command on that PR's branch. When a task's PR is done (merged, pushed fix with green CI, replies drafted), mark it `completed` and name the next task.

## Refresh mode

When the user runs `/open-work refresh` or asks to refresh:

1. Fetch again.
2. Open with a short "changed since last pass" list: new PRs, PRs that left (merged or closed), PRs that moved buckets.
3. Print the full table again, not a diff of it.
4. Reconcile tasks as in step 4.

## Rules

- Read-only on GitHub. No merges, comments, reviews, label changes, ready-for-review or rebases inside this skill. Each of those needs the user's explicit yes when the task is worked.
- Never invent a status. If a field is missing, show `—`.
