#!/usr/bin/env bash
# Fast-forward every local branch that tracks an upstream, except the
# checked-out one (git refuses to move it; pull it normally).
set -uo pipefail

git fetch --all --prune --quiet

current=$(git branch --show-current)

git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads |
while read -r local upstream; do
  [ -n "$upstream" ] || continue
  [ "$local" = "$current" ] && continue

  if git fetch . "refs/remotes/$upstream:refs/heads/$local" --quiet 2>/dev/null; then
    echo "ff: $local <- $upstream"
  else
    echo "skipped: $local (diverged or up to date)"
  fi
done
