---
name: tdd
description: Follow strict Test Driven Development with small incremental steps
---

Follow Test Driven Development (TDD) strictly for all code changes. Work in the smallest possible increments.

## The TDD Cycle

For each change, follow this cycle exactly:

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

## Rules

- Never write production code without a failing test first
- Never commit - that is the user's responsibility
- Write only one test at a time
- Make the smallest possible change to pass each test
- Run tests after every change
- If a test fails unexpectedly, stop and fix it before continuing

## Working in Small Steps

- Break features into the smallest testable behaviors
- Each test should verify one thing
- If stuck, make the step smaller
- Upon ambiguity, ask the user for clarification
