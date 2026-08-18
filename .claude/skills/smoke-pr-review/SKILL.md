---
name: smoke-pr-review
description: Smoke check on a PR — will it blow up prod, and does it deliver what it promises? Outputs 🟢, 🟡 (promise unverifiable), or 🔴, plus at most 3 sentences of at most 10 words each.
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
3. If the body references a Linear ticket and the body itself is thin,
   fetch the ticket to establish what was promised.

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

A risk must be **concrete and traceable to a line in the diff**. A vague
"this could maybe be risky" is not a finding — do not red-flag on vibes.
No concrete finding = this check passes.

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
bullets, no preamble, no code blocks, nothing after.

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
