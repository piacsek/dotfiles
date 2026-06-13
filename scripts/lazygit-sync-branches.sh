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

# Delete branches already integrated into main, by two methods:
#
#   1. True merge / fast-forward: branch tip is an ancestor of main.
#      `git branch -d` is the safe gate here -- git refuses to delete
#      anything not reachable from main, so nothing is lost.
#
#   2. Squash / rebase merge: the branch tip is NOT an ancestor (squashing
#      makes a new commit), but main contains an equivalent *patch*. We
#      collapse the branch into a single commit on its merge-base, then ask
#      `git cherry` whether main already has that patch-id. A match means the
#      branch's content is in main even though its commits aren't. This needs
#      `git branch -D` (force) -- `-d` would refuse -- so we only force-delete
#      after the patch-id check confirms equivalence.
if [ -n "$main" ]; then
  git for-each-ref --format='%(refname:short)' refs/heads |
  while read -r local; do
    [ "$local" = "$main" ] && continue
    [ "$local" = "$current" ] && continue

    if git merge-base --is-ancestor "$local" "$main"; then
      git branch -d "$local" --quiet 2>/dev/null && echo "deleted: $local (merged into $main)"
      continue
    fi

    base=$(git merge-base "$main" "$local") || continue
    squashed=$(git commit-tree "$(git rev-parse "$local^{tree}")" -p "$base" -m _) || continue
    case "$(git cherry "$main" "$squashed")" in
      "-"*) git branch -D "$local" --quiet && echo "deleted: $local (squash-merged into $main)" ;;
    esac
  done
fi
