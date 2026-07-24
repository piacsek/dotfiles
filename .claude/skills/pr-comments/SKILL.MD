---
name: pr-comments
description: Fetch GitHub PR comments for the current branch, triage the actionable ones into a task list, and draft a reply for each
---

Fetch every comment on the GitHub pull request for the current branch, present them as
context, then turn the actionable ones into a task list with a drafted reply per item.

## 1. Fetch

1. `git branch --show-current` to get the branch.
2. General PR comments, review summaries, and requested reviewers:

   ```
   gh pr view --json number,title,url,comments,reviews,reviewRequests
   ```

3. **Inline review threads** — most actionable feedback lives here, and `gh pr view`
   cannot return it: there is no `reviewThreads` JSON field, so this GraphQL query is
   the only way to get inline comments *and* the only source of resolved/outdated state:

   ```
   gh api graphql -f query='
   query($owner:String!,$repo:String!,$number:Int!){
     repository(owner:$owner,name:$repo){
       pullRequest(number:$number){
         reviewThreads(first:100){
           nodes{
             isResolved isOutdated path line
             comments(first:20){nodes{author{login} body createdAt}}
           }
         }
       }
     }
   }' -F owner=<owner> -F repo=<repo> -F number=<n>
   ```

   Get `<owner>/<repo>` from `gh repo view --json owner,name`.

4. If no PR exists for the branch, say so and stop.

## 2. Triage

Classify every thread. **Skip** `isResolved: true` and `isOutdated: true` — report only
how many were skipped, so a resolved thread never becomes a task.

For the rest, decide actionable vs not:

- **Actionable** — requests a change, asks a question, raises a risk or concern, reports
  a bug, or asks you to justify a decision. A question is actionable even when phrased
  softly; the reply *is* the deliverable.
- **Not actionable** — praise, FYI, or an observation about something already done.

If the reviewer uses severity markers (🔴/🟡/🔵/🟢, or "blocker"/"worth fixing"/"nit"),
carry them into task ordering — most severe first. Do **not** treat a low-severity marker
as automatically non-actionable: a 🔵 or "nit" that asks a question or flags a real
trade-off still needs a decision and a reply. Conversely, never inflate praise into work.

When a thread has several comments, the **last** one is the current state of the ask.

## 3. Build the task list

`TaskCreate` one task per actionable thread — per thread, never per file, so two comments
on one file stay separately resolvable.

- **subject** — imperative and specific, ending in `path:line` (e.g.
  `Log the rethrown non-transition error in submit-personnel-review.use-case.ts:64`).
- **description** — the reviewer's login, the quoted ask (trimmed), what would actually
  resolve it, and the drafted reply from step 4.

Order most-severe first. If nothing is actionable, create no tasks and say so plainly
rather than inventing work.

## 4. Draft a reply per task, but do not post

For each actionable thread, draft a short reply that either commits to a change, answers
the question, or pushes back with a reason. Drafts go in the task description and the
report.

**Never post a reply, resolve a thread, or push a fix as part of this skill.** Posting is
outward-facing and needs explicit approval each time — present the drafts and let the user
choose which to send. Nothing here edits code either; this skill produces a plan, not a
diff.

Flag any comment you disagree with, with the reason, instead of silently drafting
agreement — a reviewer can be wrong, and a draft that concedes a bad point is worse than
one that argues.

## 5. Report

- PR title and URL, review decision, and who was asked to review.
- Review summaries by reviewer, with state (approved / changes requested / commented).
- A table of actionable threads: severity, `path:line`, reviewer, the ask in a few words.
- The non-actionable and skipped (resolved/outdated) counts — one line, not a list.
- The drafted replies.
