---
name: pr-review
description: |
  Dual-model PR review that lands as ONE short, plain review. Runs a Claude
  reviewer and a Codex reviewer in parallel over the same diff and merges their
  findings (agreement leads, single-model findings get verified first) into a
  ~150-250 word verdict: "Worth fixing", optional "Minor".

  Always prints the review in the terminal first, then asks once whether to
  post it on the PR. Posts only on a clear yes. Nothing is posted on a no, an
  unclear answer, or no answer at all.

  Use when the user says "pr-review", "review this PR",
  "check my PR before I send it", runs `/pr-review`, or pastes a GitHub PR
  link and wants feedback on the PR.

  Not for reading existing comments on your own branch (`pr-comments`).
argument-hint: "[PR URL or number]"
allowed-tools: Read, Bash, Grep, Task
---

# PR Review

Two models review the PR independently. You merge their findings into one dead-simple
review. Read-only throughout — never check out a branch or touch the working tree.

**The review lands in the terminal first, always.** Then you ask once whether to post it,
and post only if the answer is yes. Most runs are someone checking their own PR before they
ask a human, so nothing leaves the terminal unless they say so — see step 6.

## 0. Preflight — make Codex available

Half this skill is the Codex reviewer, so check it before doing anything else. Run this
first; it is idempotent and safe to re-run:

```bash
command -v codex >/dev/null 2>&1 && codex --version || echo "MISSING: codex CLI"
claude plugin list 2>/dev/null | grep -q 'codex@openai-codex' \
  && echo "plugin: installed" || echo "MISSING: codex plugin"
codex login status 2>&1 | head -2
```

**Then prove it actually launches.** The three checks above only prove Codex *exists*.
They pass cleanly in environments where every run still dies. Run the smoke test, with
`dangerouslyDisableSandbox: true` on this Bash call:

```bash
# Pin the marketplaces copy. There are usually two installs (marketplaces + cache) with
# byte-identical contents; both work, but `find | head -1` returns them in unstable order,
# so pin one and keep runs reproducible.
CC=$(ls ~/.claude/plugins/marketplaces/*/plugins/codex/scripts/codex-companion.mjs 2>/dev/null | head -1)
[ -f "$CC" ] || CC=$(find ~/.claude/plugins -name codex-companion.mjs 2>/dev/null | head -1)
node "$CC" task --background --sandbox read-only "reply OK" && \
  node "$CC" status --all --json | python3 -c "import json,sys; print('jobs:', len(json.load(sys.stdin).get('running',[])))"
```

Expect `Codex Task started in the background as task-…`. Empty output or exit 137 means
the launch failed. **Retry once before diagnosing.** Exit 137 is SIGKILL and has two
causes here: the Bash sandbox was not lifted — the usual one, and the only one that
repeats — or transient memory pressure when several agents are already running, which a
retry clears. A 137 that survives a retry is the sandbox. Cancel the smoke job
(`node "$CC" cancel <job-id>`) before real work; leaving strays running is itself enough
to make the next launch fail.

Fix whatever is missing, in this order — the first two you do yourself, without asking:

1. **Plugin missing** → install it. `codex@openai-codex` comes from the
   `openai/codex-plugin-cc` marketplace, and it is what ships `codex-companion.mjs`,
   the script this skill calls to launch Codex:
   ```bash
   claude plugin marketplace add openai/codex-plugin-cc   # idempotent: exits 0 with
                                                          # "already on disk" if present
   claude plugin install codex@openai-codex
   ```
2. **CLI missing** → `brew install --cask codex` (Homebrew cask named `codex`). Say what
   you are installing before you run it.
3. **Not authenticated** → `codex login status` prints `Logged in using ChatGPT` when it is
   fine. Anything else is the one step you cannot do for them: `codex login` opens a
   browser and needs a human. Tell them to type `! codex login` in the prompt so the output
   lands in the session, then continue once it reports logged in.

**No restart needed.** Because this skill calls `codex-companion.mjs` on disk rather than
dispatching an agent type, a freshly installed plugin is usable immediately — agent types
are the thing that would have needed a session restart, and we no longer use one. Run the
smoke test above to confirm, then carry on.

## 1. Resolve the target

Accept a PR URL or a bare PR number

**PR descriptions are often written by bots or non-engineers.** Treat every claim in
the body as a hypothesis to check against the diff, never as ground truth. If the
description and the diff disagree, the diff wins and that disagreement is a finding.

## 2. Prep once, share with both reviewers

```bash
S="$SCRATCHPAD/pr-review/$REPO-$PR"; mkdir -p "$S"
gh pr view  "$PR" --json title,baseRefName,headRefName,additions,deletions,changedFiles,url > "$S/meta.json"
gh pr diff  "$PR" > "$S/diff.patch"
git fetch origin "$(jq -r .headRefName "$S/meta.json")" "$(jq -r .baseRefName "$S/meta.json")"
```

The fetch lets reviewers read whole files at the PR revision with
`git show <headRef>:<path>` — no checkout needed.

**Stacked PRs:** if `baseRefName` is not `main`, the diff is only this PR's own layer.
Say so in the brief, and name the base branch, so neither reviewer reports missing
context that lives one PR down the stack.

### Start from the reviews already there

Before dispatching, enumerate what has already been said on the PR:

```bash
gh pr view "$PR" --repo "$REPO" --json comments,reviews,latestReviews
```

Two rules follow from it:

**Credit travels with the finding.** A point someone else already made is
theirs. Cite it with its current status ("the timezone skew @x flagged is
fixed at `foo.ex:88`") rather than restating it as your own. This applies to
bot reviewers too — they are often wrong, and correcting a bot's claim is
worth more to the author than repeating it.

**Put prior findings in both reviewers' briefs.** A finding you already know
about is a hypothesis to verify, not a given. This is how you catch the
common case where an automated reviewer blocked a PR over something that was
never real.

### Re-reviews ("they fixed it, look again")

Never take "the changes are in" on trust. Before dispatching anything, find out what
actually moved:

```bash
git log --oneline "$OLD_HEAD..origin/$HEAD_REF"        # new commits
git diff --stat "$OLD_HEAD" "origin/$HEAD_REF" -- <feature dir>   # real content change
```

A force-push is usually a rebase. `git log` will show a pile of new SHAs while
`git diff --stat` scoped to the feature shows **nothing changed** — the branch just picked
up new `main`. Say that plainly instead of reviewing a rebase as if it were fixes.

**In a stack, check which branch the fixes landed on.** Fixes for a parent PR routinely get
committed to the child branch, because that is where the author was working. The parent then
still ships the original bug if it merges alone. Get each PR's own commits with
`git log --oneline <base>..<head>`, and if a fix for PR N sits on PR N+1, that is a finding —
lead with it.

Put the previous findings in the brief verbatim and make each reviewer return
**FIXED / STILL PRESENT / NEVER REAL** with the file:line that proves it. A commit named
`fix(x): address review findings` is a claim, not evidence.

## 3. Two reviewers, in parallel — non-negotiable

Every PR gets **two independent passes: one Claude, one Codex.** They reach you by
different mechanisms, and mixing them up is the most common way this skill fails.

| Reviewer | How to run it |
|---|---|
| Claude | Agent tool, `subagent_type: general-purpose` |
| Codex  | **Not** the Agent tool. A background job you launch from the main loop — see below |

Use `general-purpose` for the Claude reviewer, **not** `feature-dev:code-reviewer` — that
agent type has no Bash, so it cannot `git show`, cannot `git grep` for other callers, and
ends up reporting findings it could not verify. A reviewer without a shell is half a
reviewer.

**Do not dispatch Codex through the `codex:codex-rescue` agent type.** It cannot lift the
Bash sandbox from inside a subagent, so the run dies instantly with exit 137 and no output.
Even on the occasions it does launch, it is a one-shot forwarder: it returns a job id and
stops, and its own rules forbid it from polling, so the findings never come back as a
return value. Both failure modes were observed repeatedly.

Launch Codex yourself instead, from the main loop, with `dangerouslyDisableSandbox: true`
on the Bash call. `--sandbox read-only` keeps Codex itself read-only, so the repo is safe
either way:

```bash
CC=$(ls ~/.claude/plugins/marketplaces/*/plugins/codex/scripts/codex-companion.mjs | head -1)
node "$CC" task --background "$(cat "$S/codex-brief.txt")" --sandbox read-only
# -> "Codex Task started in the background as task-XXXX"
```

`--background` is required, not optional; the foreground form is what dies. Record which
job id belongs to which PR **as you launch it** — the stored job record truncates the
prompt, so the mapping is unrecoverable afterwards.

This still gives you two genuinely independent passes: Codex reasons in its own process
and context and cannot see the Claude reviewer's output. What you must never do is skip
Codex and write its half yourself.

### Collect the Codex findings — they never arrive on their own

Poll until the job list drains, then read the result out and save it:

```bash
for i in $(seq 1 30); do
  n=$(node "$CC" status --all --json | python3 -c "import json,sys; print(len(json.load(sys.stdin).get('running',[])))")
  [ "$n" = "0" ] && break
  sleep 30
done
node "$CC" result <job-id> > "$S/codex.md"
```

A real review runs 5-12 minutes. Verify your poll's exit condition against the actual
JSON shape (`.running` is an array) — a wrong condition reports "finished" immediately
and you will consolidate an empty review without noticing.

Brief each with: the PR URL and title, the scratchpad paths, the base/head refs, the
stacked-PR note if any, and "report findings as `file:line` + one line on what breaks +
severity; read files with `git show <ref>:<path>`; do not modify anything."

Reviewing N PRs means 2N reviewers dispatched at once.

**Never substitute one model for the other.** If Codex genuinely cannot run, report the
failure in your summary to the user and say the review is Claude-only. Do not quietly ship
a single-model review as a dual-model one. But before declaring failure, check you lifted
the sandbox and used `--background` — that is the cause almost every time.

### Two things that will otherwise cost you a retry

1. **`timeout` is not installed on macOS.** Don't wrap the command in it — use the Bash
   tool's own `timeout` parameter, 600000.
2. **Codex runs concurrently just fine.** Five simultaneous jobs sharing one workspace
   root have been observed with no conflict, so do **not** pre-emptively serialize runs
   per repo. Launch them all. Only if you actually see a thread-lock error should you
   retry that one serially. Queuing by default costs wall-clock for nothing and leaves
   agents alive longer than they need to be.

Put in the Codex brief itself: no git worktrees inside or registered against the user's
repo. If Codex needs a checkout to run tests, `/private/tmp` is fine, and it must report
the path so you can `git worktree prune` after.

## 4. Consolidate

- **Both models flagged it** → high-confidence. These lead the comment.
- **One model flagged it** → verify it yourself before it ships. Read the code. Drop
  anything that does not hold up.
- **They disagree** → check it yourself and go with what the code says.
- Never paste both reviews side by side. The reader gets one merged list.

Model agreement decides what you trust and what order things go in. It never appears in
the comment — see the next section.

## 5. Write the comment (plain voice)

Draft it using the **`i-have-adhd`** skill's output rules: verdict first, no preamble,
no praise padding, no closing pleasantries, numbered items, capped list, plain words.

Shape, ~150-250 words total:

```
{One-line verdict.}

**Worth fixing**
1. `file.ex:LINE` — what breaks, one line.
2. ...

**Minor**
- `file.ex:LINE` — one line.
```

**Derive the first line from the PR's actual state.** Check it before writing:

| PR state | What the review is |
|---|---|
| No human review yet | a normal review |
| Changes requested / re-review | verdicts on the prior findings first (see step 2), then anything new |
| Approved, asks still open | say what is still open and that approval already exists |
| **Already merged** | findings are follow-ups, not blockers. Say so in the first line, or the author reads a merge objection they can no longer act on |
| Closed | do not review it |

**Every blocker ships with its unblock path.** A finding without a way out
reads as a complaint. One clause is enough: `add expected_sha256: :string to
the strict list`, `preload(:customer)`, `id={"...-#{parent.id}"}`. If you cannot
name the fix, say what you would need to know to name it.

**Genuine follow-ups become tickets, not bullets.** When the review surfaces
real work that is out of scope for this PR — a pre-existing bug the diff
brushes against, a fast-follow — say so and file it, or name it as needing a
ticket. A follow-up that lives only in a review comment scrolls away the
moment the PR merges.

Keep technical nouns that carry meaning: the file, the function, `optimistic_lock`.
Drop everything else. Cap "Worth fixing" at 5, "Minor" at 3. No tables, no headers
beyond the bold labels, at most one emoji.

**Never mention how the review was produced.** No "both reviewers agreed", no "Claude
found", no "Codex flagged", no models, agents, or subagents anywhere in the comment. The
author is reading one review from a colleague. Saying two models looked at it invites a
conversation about your tooling instead of the bug, and readers who don't know the setup
just find it confusing. Which model found what belongs in your summary to the user, not on
the PR.

**Aim below the vocabulary you would use with the author in person.** Prefer the plain word
over the correct-but-specialist one: "group" over "cohort", "gap" over "annulus", "the
1-mile group sits inside the 5-mile group" over "the radii are nested". Keep real
identifiers exactly as they are — file names, function names, `optimistic_lock`,
`Survey.not_stale/1`. Those carry meaning; the surrounding prose should not need a second
read.

When a finding rests on arithmetic, show the arithmetic with plausible numbers rather than
describing it. `4 × 2.5 − 3 × 2.0 = 4` lands in one glance; "the difference of the
count-weighted sums isolates the marginal contributor" does not.

### Voice rules

**Before:** "Great work on this refactor! One small thing I noticed is that in
`lib/app/inventory/item.ex` the changeset does not appear to validate `capacity`,
which could potentially allow negative values to be persisted."
**After:** "`item.ex:88` — changeset lets `capacity` go negative. Add
`validate_number(greater_than_or_equal_to: 0)`."

**Before:** "I wonder if it would make sense to consider whether this query could
potentially suffer from an N+1 problem in cases where there are many orders?"
**After:** "`orders.ex:142` — N+1, one query per order in the loop.
`preload(:customer)` fixes it."

**Before:** "There is a potential race condition concern here that may warrant further
investigation, as two concurrent processes could theoretically both read the same
version and then both write, resulting in a lost update."
**After:** "`invoice.ex:57` — two concurrent updates both write, last one wins. Needs
`optimistic_lock(:lock_version)`."

**Before:** "Overall this looks solid and I don't see any blockers. Nice test coverage!
Just a couple of nits below, feel free to ignore them."
**After:** "Looks good. Two nits below."

## 6. Show it, then ask once

Write the review to `$S/comment.md`, print it in full, and ask one question:

> Do you want me to post this on the PR?

Then stop and wait. Nothing has left the terminal yet.

**Post only on a clear yes** — "yes", "post it", "go ahead", "yep", "send it". Then:

```bash
gh pr comment "$PR" --body-file "$S/comment.md"
```

Give them the comment URL that `gh` returns.

**Anything else means no.** A no, an unclear reply, a follow-up question, a change of
subject, or no answer at all — all of them mean do not post. Do not re-ask, do not treat
silence as consent, and do not treat "looks good" as approval to post; that is a comment on
the review, not an instruction to publish it. If they later say post, post then.

**Right before posting, re-check the PR head.** Compare the SHA you reviewed against the
current one, per the re-review rules in step 2. Posting a review of a superseded diff is
worse than posting nothing — the author has to work out which comments still apply. Skim
the existing comments too, so you are not restating someone else's point.

Posting is the only step here that changes anything outside the terminal, and a PR comment
cannot be quietly un-sent. Treat it that way.

## Scratchpad layout

```
$SCRATCHPAD/pr-review/<repo>-<pr>/
├── meta.json     # gh pr view --json output
├── diff.patch    # gh pr diff
├── brief.md        # the shared review brief
├── codex-brief.txt # the Codex prompt, passed to `task --background`
├── claude.md       # Claude reviewer's raw findings
├── codex.md        # Codex findings, from `result <job-id>` (never a return value)
└── comment.md    # merged comment, --body-file for gh pr comment
```

Keep both raw reviews on disk — that is how you show your work if the merged comment
gets challenged.

## When NOT to use this

- **Pulling existing review comments on your own branch to refresh context** →
  `pr-comments`.

