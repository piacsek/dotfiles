#!/bin/bash

set -e

echo "=== Review Commit Push Workflow ==="
echo ""

# Step 1: Open lazygit for staging
echo "Step 1: Opening lazygit for staging changes..."
echo "Press 'space' to stage/unstage files, then 'q' to quit when done."
echo ""
lazygit --filter=staged

# Check if there are staged changes
if ! git diff --cached --quiet; then
    echo ""
    echo "Step 2: Generating commit message with Claude..."

    # Get git diff and recent commits for context
    DIFF=$(git diff --cached)
    LOG=$(git log --oneline -5)

    # Create a prompt for Claude
    PROMPT="Based on the following git diff of staged changes, generate a single-sentence commit message in this format: MOST_MEANINGFUL_WORD: summary of changes

The MOST_MEANINGFUL_WORD should be a single word (like 'feat', 'fix', 'refactor', 'docs', 'config', 'chore', etc.) that best captures the nature of the change.

Recent commits for style reference:
$LOG

Staged changes:
$DIFF

Please respond with ONLY the commit message in the format 'WORD: summary', nothing else."

    # Call Claude CLI to generate commit message
    COMMIT_MSG=$(echo "$PROMPT" | claude 2>/dev/null | tr -d '\n\r' | sed 's/[[:space:]]\+/ /g' | xargs)

    # Fallback if Claude fails or returns empty
    if [[ -z "$COMMIT_MSG" || "$COMMIT_MSG" == *"error"* ]]; then
        echo "Claude failed to generate commit message, using fallback"
        COMMIT_MSG="chore: manual commit - $(date '+%Y-%m-%d %H:%M:%S')"
    fi

    echo ""
    echo "Commit message: $COMMIT_MSG"
    echo ""

    # Step 3: Commit
    echo "Step 3: Committing changes..."
    git commit -m "$COMMIT_MSG"

    # Step 4: Pull and push
    echo "Step 4: Pulling and pushing to current branch..."
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    git pull origin "$CURRENT_BRANCH" --rebase || true
    git push origin "$CURRENT_BRANCH"

    echo ""
    echo "✓ Workflow completed successfully!"
else
    echo "No changes staged. Exiting."
    exit 1
fi
