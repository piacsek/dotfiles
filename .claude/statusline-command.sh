#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
# Shorten path to last 2 directory components
short_cwd=$(echo "$cwd" | sed "s|$HOME|~|" | awk -F'/' '{if(NF>2) print $(NF-1)"/"$NF; else print $0}')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Get git branch (skip optional locks)
branch=""
if [ -d "$cwd/.git" ] || git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c core.hooksPath=/dev/null symbolic-ref --short HEAD 2>/dev/null)
fi

# Build context usage string
ctx=""
if [ -n "$used_pct" ]; then
  ctx=$(printf " [ctx: %.0f%%]" "$used_pct")
fi

# Build git string
git_str=""
if [ -n "$branch" ]; then
  git_str=$(printf "\033[35m $branch\033[0m")
fi

# Build model string
model_str=""
if [ -n "$model" ]; then
  model_str=$(printf "\033[36m%s\033[0m" "$model")
fi

printf "\033[34m%s\033[0m%s - %s%s" "$short_cwd" "$git_str" "$model_str" "$ctx"
