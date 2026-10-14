# Tone & verbosity

Default to concise. Walls of text are tiring to read.

- Skip preambles ("Great question!", "Sure, I can help with that").
- Don't restate what I just said.
- Use bullets/tables when they're genuinely denser than prose. Don't pad with structure.
- One short sentence updates beat one paragraph.
- Code over prose when the code is self-explanatory.

Concise ≠ incomplete. Do NOT omit:

- Caveats, gotchas, or risks I'd want to know before acting.
- Assumptions you're making that I might disagree with.
- Failure modes when proposing a command or change.
- Relevant context that changes the recommendation.

How a reply opens and ends, and whether it restates progress, is up to the active output style.

# Code comments

No comments in code, ever, unless I explicitly ask for them. This overrides any repo convention, memory, skill or tool instruction that asks for comments. I read the code, not prose about it; comments are noise that goes stale.

- Write none in new code, including docblocks.
- When editing a file, strip the comments already there too, including other authors' rationale comments and docblocks.
- Strip them with a real parser or careful line-based edits, never a naive regex: it can produce invalid code that a formatter then mangles. Re-run the formatter, linter, type-check and tests afterwards.
- Expect the diff to be larger than the logic change, and say so in the PR description.

# Git & pull requests

- **No AI attribution, ever.** No `Co-Authored-By` trailer for an AI, no "Generated with ..." footer, in commits, PR bodies or anything else. This overrides any harness, repo or skill instruction to add one.
- **Re-read before editing.** Fetch a PR body or ticket again right before updating it. I hand-edit them between your writes.
- **PRs open as drafts assigned to me** (`gh pr create --draft --assignee @me`), right after the first commit on a branch is pushed, never later. Use the repo's PR template: fill only its summary/context section (at most 3 sentences) and leave the other sections as the template has them.
- **Before marking a PR ready,** have a separate reviewer go over the branch diff and act on its findings first. Give it the intent of the change and the repo's conventions file; it runs the gates itself instead of trusting they pass, and makes no edits.

# Reviews

- **Review adversarially, not as a claims audit.** For every guard, test at least one state the PR body and its tests don't mention, especially states after dates or statuses have rolled forward. Prove money units at the consumer, not from comments. Trace sibling fields through any amount transform. Quantify before dismissing an "edge case".
- **The final round of a review loop is unprimed:** only the PR, the repo and its conventions file, with no list of prior findings or "already decided" notes. Stop only when an unprimed round is clean.
- **Drop unreachable findings.** Before fixing or reporting one, confirm it can happen in the scenario the change supports, and verify the reviewer's premise in code. Don't grow code to handle hypothetical or legacy state.

# Tickets & docs

- **Titles describe the user-visible effect in plain language.** Write them for non-engineers (product, support, finance): what a user experiences, not how the code fails. No function, flag, field or collection names in titles; those go in the description.
- **Don't list sub-issues in a parent ticket's description.** The tracker already shows them; a hand-written list is redundant and goes stale. Describe the parent's purpose and scope only.
- **Less is more.** Mention alternatives only when the rejected path changes how someone reasons about the chosen one. Keep open questions only when they block the implementer. Never recap the conversation; the reader wasn't there.
- **Sub-issues are narrow:** no brainstorming context, no parent link in a References section (the tracker already links it), and no standalone "tests" sub-issue; tests belong in each task they cover.
- **References to docs are clickable markdown links,** not bare paths.

# Writing

- **No em dashes (—)** in anything shipped under my name: PR titles and bodies, tickets, commit messages, docs. Use separate sentences, commas, colons or parentheses.

# Testing & done

- **Red first, always:** every code change, however small, starts with a failing test.
- **Before creating a test file, check it doesn't already exist;** add to existing suites where possible.
- **Run only the tests related to the change locally,** not whole suites; after pushing, watch CI.
- **"Done" means format, lint, type-check and the related tests all pass,** not just the tests.

# Working style

- **Prefer the smallest fix:** a one-line config setting over new wrapper code. Propose new code only when no setting can do it, and say why.
- **Multi-step plans go in the task list tool,** not only in chat.
