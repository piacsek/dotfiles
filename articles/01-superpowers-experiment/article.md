---
title: A stab at superpowers
published: true
description: A small experiment comparing my current bespoke AI workflow against an industry-wide used methodology
tags: ai, claude, superpowers, rust, tui
cover_image: https://github.com/piacsek/dotfiles/blob/main/articles/01-superpowers-experiment/cover.png?raw=true
published_at: 2026-11-15 03:15 +0000
---

I've been using AI workflows to build applications for a little over one year now. I decided, for the first time, to use a pre-baked industry methodology: [superpowers](https://github.com/obra/superpowers).

Superpowers caught my attention because it resembles how I currently work with AI. I plan my work and chunk it down into smaller deliverables, which I execute through tdd.

I have a few dimensions I wanna assess out of this experiment:
- the end result feature correctness and UX;
- the generated code;
- cost, both time and tokens;
- ergonomics: how I feel about this workflow;

### Running the experiment

I used my agentic hobby project, [conveyor](https://github.com/piacsek/conveyor/), as the guinea pig for this. Conveyor is a [TUI](https://en.wikipedia.org/wiki/Text-based_user_interface) that lets me see which stage of the [SDLC](https://en.wikipedia.org/wiki/Systems_development_life_cycle) my iterations are: Pull Request, merge queue, merged or deployed. A feature it lacks is tabs. I wanna be able to cycle through PRs I wrote and PRs I need to review, for instance.

To keep it simple, this iteration focused on adding tabs just for the PRs column. 

I gave two distinct Claude Code sessions running Sonnet 5.5 on `medium` the same initial prompt:

> Let's plan a feature: tabs. Right now each column shows a fixed view based on its config. I would like to add the ability of having multiple configs for each column, and you'd cycle through them by pressing a key that defaults to <Tab>. I'm ok breaking the current tab behaviour. I envision these tabs appearing at the top of the column. The currently selected one gets a visible highlight.

Both got the PR through the automatic review cycle without any further interaction with me, and in about 40 minutes I had two working versions of the same feature. I was excited to try them out!

### Artifacts & Results


| Artifact | Current workflow | Superpowers |
|:---      | :---             | :---        |
| Issue/plan   | https://github.com/piacsek/conveyor/issues/79     | https://github.com/piacsek/conveyor/issues/80 |
| Pull request | https://github.com/piacsek/conveyor/pull/82 | https://github.com/piacsek/conveyor/pull/81   |
| Screenshot   | ![Current workflow screenshot](https://github.com/user-attachments/assets/9efa4a74-0049-4997-81d7-3648d2c8a5fb) | ![Superpowers screenshot](https://github.com/user-attachments/assets/ec2852a1-da67-4ca0-ac48-477c706e189b) |


| Cost                      | Current workflow   | Superpowers |
|:---                       | :---               | :---        |
| Build wall time           | 41min              | 42min       |
| Token cost - main session | 196.7k             | 104.9k      |
| Token cost - subagents    | 1.28M              | 483k        |
| Token cost - total        | 1.477M             | 587.9k      |

### My thoughts

Both implementations worked first time! And both of them kept retrocompatibility with the existing configuration schema.

However, I must say that I'm intrigued. My current workflow beat superpowers in all the dimensions I was interested in analysing: it basically took the same time for almost a third of the token cost to produce an outcome I enjoyed more. 

- UI: I don't like the tab number showing up, it's confusing since it's so close to the PR count above;
- Code: I prefer the `Tab` abstraction over the `View` one - it clicks faster in my mind;
- Ergonomics: To my surprise, my current workflow asked me more questions than superpower's `brainstorming` skill: 5x1 - I felt more in the loop;

I wasn't expecting such one-sided result. If you've used superpowers, please comment how you operate it! I'm interested in experimenting more with it.

Thank you for reading, have a great day!

