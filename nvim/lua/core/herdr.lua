-- herdr glue: the vimux runner-pane workflow when nvim runs inside a herdr pane.
-- `active` is false under tmux and in a bare terminal, so nothing here changes
-- the tmux workflow. The pane work lives in scripts/herdr-vimtest.
local M = {}

M.active = vim.env.HERDR_ENV == "1" and (vim.env.TMUX == nil or vim.env.TMUX == "")

local script = vim.fn.expand("~/dotfiles/scripts/herdr-vimtest")

---Run `cmd` in the tab's "vimtest" pane (created below this pane on first use),
---clearing it first like vimux with test#preserve_screen=0.
---@param cmd string
function M.run(cmd)
	-- vimux keeps the last run here; <leader><BS> reads it back for both kinds.
	vim.g.VimuxLastCommand = cmd
	vim.fn.jobstart({ script, "run", cmd }, {
		on_exit = function(_, code)
			if code ~= 0 then
				vim.schedule(function()
					vim.notify("herdr-vimtest failed (exit " .. code .. ")", vim.log.levels.ERROR)
				end)
			end
		end,
	})
end

return M
