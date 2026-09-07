# herdr-automatic-rename — tab label = "<dir › branch › program>" (or the agent's
# current task), no "[N]" jump numbers. Manual renames
# (prefix+, / prefix+shift+t) win, like tmux rename-window. Full option list:
# https://github.com/qu8n/herdr-automatic-rename/blob/main/config.example.sh
AUTO_INDEX=0
# Explicit per-kind zeros also strip "[N] " prefixes already on rows.
AUTO_INDEX_WORKSPACES=0
AUTO_INDEX_TABS=0
AUTO_INDEX_AGENTS=0
# Directory (or ssh host) and non-trunk branch in front: "ws-common › MC-123 › nvim".
TAB_CONTEXT=1
# Name an agent tab after the task it reports in its terminal title.
AGENT_TITLES=1
# Nerd Font glyph before the name (FiraCode Nerd Font is installed).
ICONS_ENABLED=1
