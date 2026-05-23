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
   - Remove duplication
   - Improve naming
   - Run tests after each refactoring step

## Quality gates before marking a task done

Do NOT mark a task complete until the quality gates for this project have passed.

1. Search memory for what gates apply to this repo/project (linter, type checker, formatter, test runner flags, pre-push hooks, framework-idiomatic flake checks). Project memories often record non-obvious commands (e.g., bypassing `nx test` fan-out, ExUnit `--repeat-until-failure`).
2. If memory has no entry for this project's quality gates, ask the user which gates to run and save the answer as a project/reference memory for next time. Do not guess.
3. Run every applicable gate. If one fails, fix it before moving on — do not defer.
4. Only then mark the task done and move to the next one.

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
