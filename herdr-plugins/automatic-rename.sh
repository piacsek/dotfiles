# herdr-automatic-rename — tmux `#W` parity: tab label = foreground program name,
# no "[N]" jump numbers, no directory/branch context. Manual renames
# (prefix+, / prefix+shift+t) win, like tmux rename-window. Full option list:
# https://github.com/qu8n/herdr-automatic-rename/blob/main/config.example.sh
AUTO_INDEX=0
# Explicit per-kind zeros also strip "[N] " prefixes already on rows.
AUTO_INDEX_WORKSPACES=0
AUTO_INDEX_TABS=0
AUTO_INDEX_AGENTS=0
TAB_CONTEXT=0
# 1 would name a claude tab after its current task instead of "claude".
AGENT_TITLES=0
