#!/usr/bin/env bash
set -euo pipefail

Q='query($q:String!){search(query:$q,type:ISSUE,first:100){nodes{... on PullRequest{number title url isDraft updatedAt author{login} repository{nameWithOwner} headRefName reviewDecision mergeable additions deletions reviewRequests{totalCount} reviewThreads(first:100){nodes{isResolved isOutdated}} commits(last:1){nodes{commit{statusCheckRollup{state}}}}}}}}'

me=$(gh api user --jq .login)

for role in author assignee; do
  gh api graphql -f query="$Q" -f q="is:pr is:open archived:false $role:@me" \
    | jq --arg role "$role" '[.data.search.nodes[] | . + {role: $role}]'
done | jq -s --arg me "$me" 'add | group_by(.url) | map(.[0] + {roles: map(.role)}) | map({
  repo: .repository.nameWithOwner, number, title, url, branch: .headRefName,
  roles, author: .author.login,
  owned: (.author.login == $me or (.author.login | test("bot"; "i"))),
  draft: .isDraft, review: .reviewDecision, mergeable,
  ci: (.commits.nodes[0].commit.statusCheckRollup.state // "NONE"),
  threads: ([.reviewThreads.nodes[] | select((.isResolved or .isOutdated) | not)] | length),
  requested: .reviewRequests.totalCount, updated: .updatedAt,
  idle_days: ((now - (.updatedAt | fromdateiso8601)) / 86400 | floor),
  size: "+\(.additions)/-\(.deletions)"
}) | sort_by(.updated)'
