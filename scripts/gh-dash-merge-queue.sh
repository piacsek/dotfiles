#!/usr/bin/env bash
# Show a repo's REAL GitHub merge queue (not a search proxy).
# Usage: gh-dash-merge-queue.sh owner/name [branch]   (branch defaults to main)
# Wired to the `Q` keybinding in gh-dash's prs view.
set -euo pipefail

repo="${1:?usage: gh-dash-merge-queue.sh owner/name [branch]}"
branch="${2:-main}"
owner="${repo%%/*}"
name="${repo##*/}"

json=$(gh api graphql \
  -f query='query($owner:String!,$name:String!,$branch:String!){repository(owner:$owner,name:$name){mergeQueue(branch:$branch){entries(first:50){totalCount nodes{position state enqueuedAt pullRequest{number title author{login}}}}}}}' \
  -F owner="$owner" -F name="$name" -F branch="$branch")

mq=$(printf '%s' "$json" | jq '.data.repository.mergeQueue')
if [ "$mq" = "null" ]; then
  echo "No merge queue on $branch (queue not enabled for $owner/$name)."
  exit 0
fi

count=$(printf '%s' "$json" | jq '.data.repository.mergeQueue.entries.totalCount')
echo "Merge queue — $owner/$name @ $branch: $count entr$([ "$count" = "1" ] && echo y || echo ies)"
if [ "$count" = "0" ]; then
  echo "(empty)"
else
  printf '%s' "$json" | jq -r '.data.repository.mergeQueue.entries.nodes[]
    | "#\(.position)  PR #\(.pullRequest.number)  [\(.state)]  \(.pullRequest.title)  (@\(.pullRequest.author.login))  enqueued \(.enqueuedAt)"'
fi
