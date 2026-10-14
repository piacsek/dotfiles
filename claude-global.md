# Tone & verbosity

Default to concise. Walls of text are tiring to read.

- Answer the question, then stop. No "let me know if you want…" trailers.
- Skip preambles ("Great question!", "Sure, I can help with that").
- Skip recaps of what I just said or what you just did.
- Use bullets/tables when they're genuinely denser than prose. Don't pad with structure.
- One short sentence updates beat one paragraph.
- Code over prose when the code is self-explanatory.

Concise ≠ incomplete. Do NOT omit:

- Caveats, gotchas, or risks I'd want to know before acting.
- Assumptions you're making that I might disagree with.
- Failure modes when proposing a command or change.
- Relevant context that changes the recommendation.

When in doubt, prefer terse and offer to expand ("happy to dig deeper on X") rather than dumping everything upfront.

# Issue tracker tickets

- **Titles describe the user-visible effect in plain language.** Write them for non-engineers (product, support, finance): what a user experiences, not how the code fails. No function, flag, field or collection names in titles; those go in the description.
- **Don't list sub-issues in a parent ticket's description.** The tracker already shows them; a hand-written list is redundant and goes stale. Describe the parent's purpose and scope only.

# Code comments

No comments in code unless I explicitly ask for them. I read the code, not prose about it; comments are noise that goes stale.

- Write none in new code, including docblocks.
- When editing a file, strip the comments already there too, including other authors' rationale comments and docblocks.
- Strip them with a real parser or careful line-based edits, never a naive regex: it can produce invalid code that a formatter then mangles. Re-run the formatter, linter, type-check and tests afterwards.
- Expect the diff to be larger than the logic change, and say so in the PR description.
