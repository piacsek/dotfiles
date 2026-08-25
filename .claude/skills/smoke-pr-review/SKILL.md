---
name: smoke-pr-review
description: Smoke check on a PR — will it blow up prod, and does it deliver what it promises? Outputs 🟢, 🟡 (promise unverifiable OR safety unproven), or 🔴, plus at most 3 sentences of at most 10 words each. On 🔴, also emits a paste-ready GH request-changes reply and a fix prompt for the author.
---

Smoke-test a pull request against exactly two questions. Nothing else.
Not a code review: ignore style, naming, test coverage, performance,
architecture, refactoring opportunities, and nits entirely.

"Smoke test" bounds the SCOPE (two questions), never the DEPTH. On
Check 1 the depth budget is unlimited: read every callee, spawn every
skeptic, and take every pass the audits below demand. "It's just a
smoke test" is never a reason to skip an audit — the only shortcut this
skill permits is ignoring the nit categories above.

**Prime directive — the body is a suspect, not a checklist.** The PR
body's "invariants preserved" / "edge cases handled" lists tell you what
the author *thought about*. Verifying those claims and stopping is a
claims audit, not a review — the bug lives in the state the author never
listed. For every guard and invariant, you must generate at least one
scenario the body does NOT mention and run the code through it. If every
scenario you tested appears in the body or the PR's own tests, you have
not reviewed anything yet.

**Burden of proof.** On a high-risk path (money, messaging, data
deletion, auth/permissions), the diff is unsafe until proven safe. 🟢
is not "I found no findings" — it is "I completed every mandatory audit
below and each one affirmatively passed". If any audit cannot be
completed (missing context, unreadable callee, time), the verdict is
capped at 🟡 with the reason "safety unproven". A 🟢 you cannot back
with the completed audits is a lie, and a false 🟢 is strictly worse
than a false 🔴 — when torn between them, output 🔴.

**The PR's tests are claims, not evidence.** Tests written by the
author encode the author's same blind spots. Treat suspiciously
convenient fixtures as a smell to probe, not reassurance: amounts that
are clean multiples of the divisor, UTC-only dates, single-item lists,
periods with no DST or month-length variation. Ask of every fixture:
what ugly value would break this, and does the code survive it?

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
4. **Entry-point sweep.** For every changed function, grep the repo for
   all its callers and list every entry point that reaches the change:
   triggers, crons, endpoints, queue consumers, UI actions. The review
   covers the union of those paths, not just the caller the PR body
   discusses — a function safe when called from the unenroll modal may
   be lethal when the delete trigger calls it. Note: the branch may be
   ahead of your local checkout; when a symbol seems missing, check the
   PR head and remote main via `gh api` before concluding anything.
5. **Behavioral diff vs main.** Enumerate every externally visible
   action (charge, send, write, delete) that can happen after this diff
   that cannot happen on current main — including actions in states
   where main did nothing. Each new action needs an affirmative "this
   is correct because..." traced to code; "the body says it's intended"
   does not count. A diff that turns main's no-op into a charge or send
   is guilty until each such path is proven right.

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
actually defaults **off** — a flag defaulting on gates nothing. Also
check flag **symmetry**: if any related half of the feature (frontend,
sibling PR, same flag name elsewhere in the repo) is behind a flag, and
this diff's half runs unconditionally, that's a finding — the risky half
ships to every org with no kill switch while the safe half is gated.

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

**Mandatory state sweep** — whenever the diff branches on a mutable
field of a long-lived record (a timestamp, a status enum, a rolled-
forward date), do this before crediting the branch:

1. **List the record's lifecycle states.** Not the states the body
   names — all of them. For anything cron- or cycle-driven, that list
   always includes at least: before the cycle fires, mid-flight, and
   *after* the cycle fired and the fields rolled forward.
2. **Re-evaluate the guard predicate in each state.** A predicate like
   `dateSend > now` means different things before and after a send has
   rolled `dateSend` to the next cycle — same expression, opposite
   semantics. Ask in each state: the guard passes, then what fires,
   against which period/record, for whom?
3. **Compare each outcome against current `main`.** A path that today
   produces nothing and after this diff produces a charge, send, or
   write is a finding even when every state the body listed behaves.

The bug this exists to catch: a guard tested only in the author's
named scenario, passing in an unnamed lifecycle state and firing an
action against the wrong period or the wrong person.

**Mandatory money-math audit** — whenever the diff computes, scales, or
copies an amount that reaches an invoice, ledger, or payment rail, do
all three, every time:

1. **Verify the unit at the consumer, not the comment.** JSDoc, PR
   body, and variable names claiming cents/dollars are claims. Trace
   the value to the payment-rail call (`convertToCents`,
   `amount_in_cents`, Stripe params) and let the consumer tell you the
   unit. Any rounding step (`Math.round`, integer division) is wrong
   until you have proven which unit it rounds in.
2. **Trace every sibling field the transform copies through.** Scaling
   `amount` but spreading the rest of the item (`...item`) carries
   `discounts`, `tax`, `fees` through unscaled — and any `total`
   computed nearby may disagree with how the rest of the system
   computes totals (discount-inclusive vs exclusive). Check what the
   stored record says versus what the rail actually charges; a
   permanent mismatch (a balance that never clears) is a finding.
3. **Check the time basis of any day/period arithmetic.** Day counts
   taken in UTC against timestamps produced in an org's local timezone
   (or vice versa) shift `periodDays`/`daysAttended` by one across DST
   and month boundaries. Mixed time bases in billing math is a
   finding; do not wave it off as an edge case (see severity rule).

**Severity rule for wrong amounts**: on a billing path, *systematically
wrong* beats *slightly wrong*. A bug that misbills every invoice by a
few dollars is catastrophe class — same as the money-bug bullet above —
regardless of per-invoice magnitude. Before dismissing anything as "a
rounding edge", quantify it: which invoices does it hit, how often, and
in whose favor? If the answer is "every prorated/affected invoice", it
is a finding, full stop. Noticing an issue and dismissing it without
that quantification is the exact failure this rule prohibits.

**Independent skeptic pass** — mandatory whenever the diff touches a
high-risk path (money, messaging, data deletion, auth). Your own pass
carries your own blind spots; buy independent ones. Spawn 2–3 read-only
subagents in parallel (Explore or general-purpose), each with ONE lens
and one job — construct a single concrete scenario where this diff
misfires in production:

- **Lifecycle lens**: "Here are the changed guards. Walk the mutated
  record through every lifecycle state (pre-cycle, mid-flight,
  post-cycle with rolled-forward dates, re-entry/undo). Find one state
  where a guard passes and fires against the wrong period, amount, or
  person. Report the exact state and file:line, or 'none constructed'."
- **Math/units lens**: "Here are the changed amount computations. Prove
  the unit of every amount at its final consumer, chase every sibling
  field through every transform, and try ugly values: non-divisible
  amounts, 31-day months, DST boundaries, discounts, zero and negative.
  Report one concrete wrong-amount scenario with numbers, or 'none
  constructed'."
- **Downstream lens**: "Here are the fields this diff writes or scales.
  Find every reader of those fields outside the diff and report one
  reader that now misbehaves (stored record vs charged amount mismatch,
  status never cleared, balance never clearing), or 'none constructed'."

Give each skeptic the diff location, branch name, and the instruction
to default toward reporting a scenario when uncertain. Then verify
their scenarios yourself against the code — a skeptic's claim is a
lead, not a verdict. 🟢 requires every skeptic scenario to be refuted
with file:line evidence you actually read; any scenario you cannot
refute is a finding. Skipping this pass on a high-risk path caps the
verdict at 🟡.

**Prosecution pass** — always, last, before any verdict. Write (in your
reasoning) the strongest concrete 🔴 case against this PR: the single
most damaging scenario you can construct, with the state, trigger, and
file:line it would flow through. Then refute it with code you have
actually read — if the refutation rests on a function you haven't
opened, open it. If you cannot refute it, it is a finding. If your
strongest case is weak and refuted, say why in one line of reasoning;
only then is 🟢 on the table.

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

**Pre-🟢 gate** — before outputting 🟢, answer these in your reasoning
(not in the output); if any answer is no, go back and do the work; if
the work cannot be done, the verdict is 🟡 "safety unproven", never 🟢:

1. Did I test at least one scenario per guard that the PR body and its
   tests do NOT mention? Name it.
2. Did I enumerate every entry point that reaches the changed code and
   every action possible after this diff that main cannot do — and
   prove each such action correct?
3. If amounts are touched: did I prove the unit at the payment-rail
   consumer, trace copied sibling fields (discounts/totals), and check
   the time basis of period math?
4. If the diff branches on mutable timestamps/status: did I run the
   guard in the post-cycle state where the dates have rolled forward?
5. On a high-risk path: did the independent skeptic pass run, and did I
   refute every scenario the skeptics constructed with file:line
   evidence I read myself?
6. Did I run the prosecution pass and refute my own strongest 🔴 case?
7. Did I dismiss anything as minor without quantifying which records it
   hits and how often?

A 🟢 that only re-verified the author's own claims is void. A false 🟢
is worse than a false 🔴 — under residual doubt on a high-risk path,
downgrade.

- 🟢 — both checks pass AND every mandatory audit completed and passed.
- 🟡 — no Check 1 finding, but either the promise is unverifiable OR a
  mandatory audit could not be completed ("safety unproven" — say which
  audit and why in the sentence budget).
- 🔴 — either check fails. 🔴 always trumps 🟡: a concrete
  prod risk is 🔴 regardless of how vague the description is.

**Output format is a hard constraint**: the emoji, then at most **3
sentences of at most 10 words each**. Count the words. No headers, no
bullets, no preamble, no code blocks. For 🟢 and 🟡, nothing after.
For 🔴, the verdict is followed by the two paste blocks in section 5 —
and nothing else.

- 🟢: one short sentence is enough (or the emoji alone).
- 🟡: state concisely why — unverifiable promise, or which audit is
  incomplete and what blocked it.
- 🔴: name the single worst problem with its location. Fit the top 1–2
  issues in the sentence budget; drop the rest — this is a smoke test,
  not a report.

Examples:

> 🟢 Migration is additive and delivery matches the description.

> 🟡 Empty body and vague title; nothing to verify against.

> 🟡 Safety unproven: could not read the charge callee.

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
```
~~~
