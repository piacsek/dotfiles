---
name: smoke-pr-review
description: Smoke check on a PR — will it blow up prod, and does it deliver what it promises? Outputs 🟢, 🟡 (promise unverifiable), or 🔴, plus at most 3 sentences of at most 10 words each. On 🔴, also emits a paste-ready GH request-changes reply and a fix prompt for the author.
---

Smoke-test a pull request against exactly two questions. Nothing else.
Not a code review: ignore style, naming, test coverage, performance,
architecture, refactoring opportunities, and nits entirely.

## 0. Resolve the PR

- Argument given (PR number or URL): use it.
- Otherwise: PR for the current branch via `gh pr view`.
- No PR found: say so and stop (no verdict).

## 1. Gather

1. `gh pr view <ref> --json number,title,url,body,files` — the promise
   lives in title + body (and any linked ticket referenced there).
2. `gh pr diff <ref>` — the delivery. For huge diffs, read every file
   in full only where the two checks below need it; skim the rest.
3. If the body references a ticket (Linear, Jira, GitHub issue, …) and
   the body itself is thin, fetch the ticket to establish what was
   promised.

## 2. Check 1 — Will this blow up prod?

Hunt strictly for deploy-time or run-time catastrophe. Examples (not
exhaustive — anything of the same severity class counts):

- **Irreversible/destructive migrations**: dropping or renaming columns/
  tables still read by live code, data-destroying backfills, `DELETE`/
  `UPDATE` without a `WHERE`, non-concurrent index builds on big tables,
  migrations that can't roll back while the old code is still deployed.
- **Phantom config**: referencing secrets, env vars, feature flags, or
  infra resources that don't exist anywhere in the repo, its env
  templates (`.env.example`, deploy manifests, terraform, CI config), or
  the PR itself. Grep before accusing — verify the reference is truly
  dangling, not defined elsewhere.
- **Safety mechanisms deleted without plausible motive**: removed auth or
  permission checks, deleted rate limits, disabled validations, dropped
  idempotency keys, silenced error handling around money or data writes,
  commented-out guards. A stated, plausible reason in the PR body makes
  it fine; silent removal does not.
- **Data corruption**: writes that mangle existing rows — lossy type
  casts, encoding changes, double-applied backfills, race-prone
  read-modify-write on shared records, wrong-column mappings.
- **Spamming**: code paths that can mass-send email/SMS/push — loops over
  all users, removed dedupe/throttle guards, notification triggers firing
  on backfill or migration, test sends pointed at real recipients.
- **Data leaking**: PII or secrets written to logs/analytics/third
  parties, endpoints or queries losing tenant/user scoping, permissive
  CORS/serialization exposing hidden fields, private data in public URLs.
- **Money bugs**: double-charging, cents-vs-dollars mixups, refund loops,
  wrong amounts sent to Stripe or other payment rails, charging the
  wrong customer, disabled payment idempotency.
- **Unbounded work**: full-table scans or missing pagination on hot
  paths, N+1 queries introduced on high-traffic endpoints, jobs with
  unbounded fan-out, retries with no backoff or cap.
- **Cost bombs**: uncapped loops around paid APIs (SMS, LLM calls,
  metered third parties) — a surprise bill is a prod incident.
- **Breaking un-rollbackable consumers**: removing or renaming API
  fields, endpoints, or event payloads consumed by mobile apps or
  external partners — the server rolls back, their clients don't.
- Same class of risk in disguise: hardcoded prod credentials/URLs,
  debug/test code paths left live, retry loops turned infinite,
  timezone/precision changes on billing math.

If a risk is claimed to be gated behind a feature flag, verify the flag
actually defaults **off** — a flag defaulting on gates nothing.

**Mandatory guard audit** — whenever the diff touches a path that spends
money, sends messages, or provisions paid resources (SMS/email sends,
number/inbox provisioning, charges, paid API calls), do all three, every
time, no exceptions:

1. **Open the guard, don't trust the diff's word for it.** If safety
   rests on an idempotency check, dedupe, or get-or-create living in a
   *called* function, read that function — even when it's outside the
   diff, even when a comment in the diff describes it. A comment
   claiming "guards with X" is a claim to verify, not evidence.
2. **Re-run the guard under concurrency.** If the diff fans out async
   work (loops spawning tasks/jobs, "send all" buttons, batch
   endpoints), ask: N tasks hit this guard at once with no row yet —
   does it hold? A guard that is a plain unlocked read-then-act does
   not; that's a duplicate-purchase/duplicate-send finding.
3. **Trace the retry/re-invoke path to its success claim.** Follow what
   happens when the action is triggered again after it already
   succeeded (a "send again"/"retry" button, a re-enqueued job). If
   dedupe makes the second run a no-op but the code still returns
   success and stamps sent/paid state or shows success UI, that's a
   finding — success UI for an operation that wrote nothing.

Dedupe/skip logic is not automatically a mitigant — it's a trigger to
run step 3. Do not credit a safety mechanism you haven't read.

A risk must be **concrete and traceable to a line in the diff**. That
means the finding *anchors* to a diff line (the fan-out, the send call,
the button) — the evidence may live in an unchanged callee you read to
verify it. A vague "this could maybe be risky" is not a finding — do
not red-flag on vibes. No concrete finding = this check passes.

## 3. Check 2 — Does it deliver what it promises?

Compare the stated intent (title, body, linked ticket) against the diff:

- Every claimed behavior must have corresponding code in the diff.
- Partial delivery presented as complete = 🔴 (e.g. "adds feature A" but
  only the backend half exists, UI absent, and the body doesn't say so).
- Honest partial delivery is fine: a PR that *says* "part 1 of 3" or
  "backend only" and delivers exactly that = 🟢 on this check.
- A PR with no stated intent at all (empty body, vague title, no linked
  ticket) has an **unverifiable promise**. Same when the stated intent is
  too vague to compare against the diff ("misc fixes", "cleanup"). This
  is the 🟡 case — see Verdict.

## 4. Verdict

- 🟢 — both checks pass.
- 🟡 — no Check 1 finding, but the promise is unverifiable.
- 🔴 — either check fails. 🔴 always trumps 🟡: a concrete
  prod risk is 🔴 regardless of how vague the description is.

**Output format is a hard constraint**: the emoji, then at most **3
sentences of at most 10 words each**. Count the words. No headers, no
bullets, no preamble, no code blocks. For 🟢 and 🟡, nothing after.
For 🔴, the verdict is followed by the two paste blocks in section 5 —
and nothing else.

- 🟢: one short sentence is enough (or the emoji alone).
- 🟡: state concisely why the promise is unverifiable.
- 🔴: name the single worst problem with its location. Fit the top 1–2
  issues in the sentence budget; drop the rest — this is a smoke test,
  not a report.

Examples:

> 🟢 Migration is additive and delivery matches the description.

> 🟡 Empty body and vague title; nothing to verify against.

> 🔴 Migration drops `users.email` while old code reads it.
> References `STRIPE_WEBHOOK_SECRET_V2`, defined nowhere.

> 🔴 Body promises retry logic; diff contains none.

## 5. On 🔴 only — two paste-ready blocks

After the verdict, output exactly two fenced markdown blocks, each
introduced by a one-line bold label. Nothing else after them.

Rules for both blocks:

- Never use em dashes. Use commas, colons, or separate sentences.
- Every finding names its file (and line where known) and states the
  concrete failure, not a vibe.
- Include only the findings that made the verdict 🔴 — no nits, no
  suggestions, no style notes. This stays a smoke test.
- No AI attribution, no footers, no sign-offs.

**Block 1 — GH reply.** A comment ready to paste into a
"Request changes" review on the PR. Shape:

- One opening sentence: what class of problem blocks the merge.
- One bullet per finding: `file:line`, what breaks, and the trigger
  (the input, state, or click that sets it off).
- One closing sentence stating what would make it mergeable (fix +
  regression test), nothing more.

**Block 2 — author prompt.** A prompt the author can paste into Claude
Code to fix the findings. Shape:

- First line: `On branch <branch>, fix the following before merge:`
- One numbered item per finding: the file and function, the defect
  mechanism (why it fails, not just that it fails), and the required
  regression test with the exact scenario it must pin.
- Final line instructing to run the affected tests and report results,
  and to not push or commit.

Example (structure, not length — real blocks carry the actual details):

~~~
**GH reply — request changes:**

```markdown
Blocking on two prod risks in the notification send path.

- `notifications/dispatch.py:88`: `get_or_create_sender/1` returns the
  raw settings record when the legacy sender field is set, so an object
  reaches the SMS provider as `from`. Triggered by any account with a
  legacy sender and no new-style sender configured.
- `notifications/views.py:313`: "Send all" fans out N async tasks that
  each pass the unlocked provisioning guard, so one click can buy
  several phone numbers. Triggered by send-all on an account with no
  number yet.

Happy to approve once both are fixed with regression tests.
```

**Author prompt:**

```
On branch fix/notification-dispatch, fix the following before merge:

1. notifications/dispatch.py get_or_create_sender: the early-return
   path has no error branch, so when provisioning reports
   already_provisioned (legacy sender set, new sender empty) the
   re-read settings record is returned verbatim and passed to the SMS
   provider as `from`. Return an explicit error instead. Regression
   test: account with only the legacy sender must get an error, not a
   provider call.

2. notifications/views.py send_all: each async task independently runs
   the unlocked provision guard, so N tasks can each buy a number.
   Resolve/provision the sender once before the fan-out and pass it
   into the tasks. Regression test: send-all over three recipients
   buys exactly one number.

Run the affected test files and report results. Do not commit or push.
```
~~~
