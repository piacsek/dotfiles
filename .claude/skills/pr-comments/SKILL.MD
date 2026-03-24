---
name: pr-comments
description: Fetch GitHub PR comments for the current branch to refresh context
---

Fetch all comments on the GitHub pull request associated with the current branch and present them as context.

## Steps

1. Run `git branch --show-current` to get the current branch name
2. Run `gh pr view --json number,title,url,comments,reviews,reviewRequests --jq '.'` to get the PR details and comments for the current branch
3. Present a summary including:
   - PR title and URL
   - Review requests (who has been asked to review)
   - Review comments (from `reviews`), grouped by reviewer, including:
     - Reviewer name
     - Review state (approved, changes requested, commented)
     - Review body if present
   - General PR comments (from `comments`), each showing:
     - Author
     - Timestamp
     - Comment body
4. If no PR exists for the current branch, inform the user
