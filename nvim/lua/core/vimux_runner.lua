-- Vimux names its runner pane once (`select-pane -T vimtest`), but with
-- tmux's allow-set-title on, zsh's per-command title escape overwrites it on
-- the first run. scripts/tmux-focus-test (tmux prefix C-f) finds the runner
-- by that title, so lock it: turn off allow-set-title for this pane only and
-- re-apply the name (which also heals a runner already renamed).
local M = {}

function M.open()
	vim.fn.VimuxOpenRunner()
	local id = vim.g.VimuxRunnerIndex
	if not id or id == "" then
		return
	end
	vim.fn.system({ "tmux", "set-option", "-p", "-t", id, "allow-set-title", "off" })
	vim.fn.system({ "tmux", "select-pane", "-t", id, "-T", vim.g.VimuxRunnerName })
end

return M
