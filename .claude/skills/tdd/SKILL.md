---
name: tdd
description: Follow strict Test Driven Development with small incremental steps
---

Follow Test Driven Development (TDD) strictly for all code changes. Work in the smallest possible increments.

## Before starting

- If working from a Linear ticket (or any multi-step task), create a tasklist before writing any code. Break the ticket into the smallest testable behaviors, each one a discrete task.
- Each task should be small enough to complete in one Red-Green-Refactor cycle.
- Surface the tasklist to the user before acting on it.

## The TDD Cycle

For each task, follow this cycle exactly:

1. **Red** - Write a single failing test that defines the expected behavior
   - Run the test to confirm it fails
   - The test should fail for the right reason (not due to syntax errors)

2. **Green** - Write the minimal code to make the test pass
   - Only write enough code to pass the failing test
   - Do not add extra functionality
   - Run the test to confirm it passes

3. **Refactor** - Clean up while keeping tests green
   - This step is not optional. Green code is not done code.
   - Remove duplication
   - Improve naming
   - Run tests after each refactoring step

## Quality gates before marking a task done

Do NOT mark a task complete until the quality gates for this project have passed.

1. Search memory for what gates apply to this repo/project (linter, type checker, formatter, test runner flags, pre-push hooks, framework-idiomatic flake checks). Project memories often record non-obvious commands (e.g., bypassing `nx test` fan-out, ExUnit `--repeat-until-failure`).
2. If memory has no entry for this project's quality gates, ask the user which gates to run and save the answer as a project/reference memory for next time. Do not guess.
3. Run every applicable gate. If one fails, fix it before moving on — do not defer.
4. Only then mark the task done.

After a task is marked done, stop and wait for the user to review the output before starting the next task. This applies even in auto-accept or "accept edits" mode — never chain tasks without an explicit go-ahead from the user.

Once the user approves, they will commit the changes manually to create a checkpoint. Do not commit on their behalf.

Before starting the next task, explicitly assess refactoring opportunities against the just-committed checkpoint: duplication introduced, naming that no longer fits, abstractions that want to emerge, dead scaffolding. Surface what you'd refactor (or state that nothing warrants it) before moving on. With a clean checkpoint behind you, refactors are cheap to try and easy to roll back.

## Rules

- Never write production code without a failing test first
- Never commit - that is the user's responsibility
- Never write code comments
- Write only one test at a time
- Make the smallest possible change to pass each test
- Run tests after every change
- If a test fails unexpectedly, stop and fix it before continuing
- When confirming that a test is not flaky, look for framework-idiomatic options. For instance: Elixir's ExUnit allows you to pass in a flag called --repeat-until-failure=NUM, where NUM is an integer representing the max amount of runs

## Working in Small Steps

- Break features into the smallest testable behaviors
- Each test should verify one thing
- If stuck, make the step smaller
- Upon ambiguity, ask the user for clarification

## Elixir / ExUnit

- New test files default to `use <Case>, async: true`. Every ws-common Nova case template is async-ready; a sync file serializes a whole suite lane. Keep a file synchronous only for global state: `Mock`/`with_mock`, `FunWithFlags` writes, DB access inside `on_exit` (the handler process has no sandbox allowance), `Application.put_env`-style global config, Elasticsearch/Redis, `Mix.Task` state, raw DDL, or hardcoded unique values shared across files. Full disqualifier list: ws-common `docs/modules/testing.md`.
- Do not add `on_exit` cleanup for sandboxed DB state (including feature flags) — the SQL sandbox rolls it back, and under `async: true` the cleanup itself crashes with `DBConnection.OwnershipError`.

## TypeScript

- Never assert a bare `toThrow()` / `rejects.toThrow()`. Always match against a specific error so the test fails when the *wrong* thing throws. Match the most legible specific signal available: a custom error class, a message regex, or — for DB errors — the `pg` `DatabaseError` fields (`code`, plus `table` / `column` / `constraint` when present). Prefer named/structured fields over a cryptic code alone, e.g. `rejects.toMatchObject({ code: '23502', table: '...', column: '...' })` over `rejects.toMatchObject({ code: '23502' })`.
- Repository tests must pin errors to the exact failure: assert as specifically as the error allows (the precise `pg` `code`, plus `constraint` / `table` / `column`), so a test for one violation can't pass on a different one. A generic match is a false pass waiting to happen.
- Repository happy-path tests must assert **both** the returned object **and** the persisted row. Check the method's return value, then re-read the entity from the database (fresh query / repo `find*`) and assert on that too — a method can return the right shape without actually persisting it (or persist different values than it returns).
- When testing a repository's read method (`find*` / `get*`), set up the scenario with the factory / DB-helper insert utility — never with the repository's own `create`. Using `create` couples the read test to write behavior, so a bug in `create` fails the read test (and vice versa); seeding directly isolates the method under test.

### Mocks and spies: assert behavior, not wiring

- Never assert that a callback was merely *passed*. `expect(mutate).toHaveBeenCalledWith(args, expect.objectContaining({ onError: expect.any(Function) }))` proves nothing about behavior: it passes whether the handler reverts state, swallows the error, or does nothing. It pins a wiring detail that a refactor can change without breaking a single user-facing promise.
- Decide which of the two the assertion is really about, then write that test instead:
  - **The error path matters** → drive it. Make the mocked call reject/invoke its error path, then assert the observable result: the visible error text, the reverted control value, the absent success state.
  - **The error path doesn't matter** → drop the clause. Assert only the arguments the behavior actually depends on.
- `expect.any(Function)` inside a call assertion is the smell that flags this. Treat it as a prompt to ask "what would break for the user if this were wrong?" — if there is no answer, the assertion is dead weight that will one day fail for a reason nobody cares about.
- Same rule for every incidental argument: assert the values that carry meaning, not the shape of the plumbing around them.

## Outside-in over inside-out

Prefer an outside-in approach: start from the user-facing behavior and drive inward with integration tests. Reach for unit tests only when an integration test can't reasonably cover the branch (complex pure logic, hard-to-reach edge cases).

- Start with a failing integration test that describes the observable behavior (HTTP request → response, LiveView interaction → DOM, CLI invocation → output).
- Let that failing test pull you into the implementation. Add lower-level tests only if a specific unit's logic can't be exercised cleanly from the outside.
- Avoid building bottom-up scaffolding (helpers, modules, schemas) before there's a failing outer test demanding them.
