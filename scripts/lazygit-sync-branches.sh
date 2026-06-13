#!/usr/bin/env bash
# Fast-forward every local branch that tracks an upstream, except the
# checked-out one (git refuses to move it; pull it normally), then delete
# any branch already merged into main.
set -uo pipefail

git fetch --all --prune --quiet

current=$(git branch --show-current)

# Pick the main branch ref (prefer local main, fall back to master).
main=""
for cand in main master; do
  if git show-ref --verify --quiet "refs/heads/$cand"; then
    main="$cand"
    break
  fi
done

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

# Delete branches fully merged into main. `-d` is the safe gate: git refuses
# to delete anything not reachable from its target, so this never drops work.
if [ -n "$main" ]; then
  git for-each-ref --format='%(refname:short)' refs/heads |
  while read -r local; do
    [ "$local" = "$main" ] && continue
    [ "$local" = "$current" ] && continue

    if git merge-base --is-ancestor "$local" "$main"; then
      git branch -d "$local" --quiet 2>/dev/null && echo "deleted: $local (merged into $main)"
    fi
  done
fi
