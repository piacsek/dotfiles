-- singleton_term.lua (or put in your keymaps.lua)
local M = {}

-- opts:
--   key   (string) unique id for this terminal
--   open  (function) called when we need to create it (should create a terminal and leave you in it)
--   desc  (string) optional description
function M.make(opts)
	vim.validate({
		key = { opts.key, "string" },
		open = { opts.open, "function" },
	})

	local gkey = "__singleton_term_bufnr_" .. opts.key
	local bmark = "__singleton_term_mark_" .. opts.key

	return function()
		local bufnr = vim.g[gkey]

		if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
			if vim.b[bufnr][bmark] and vim.bo[bufnr].buftype == "terminal" then
				vim.cmd("buffer " .. bufnr)
				return
			end
		end

		for _, b in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(b) and vim.b[b][bmark] and vim.bo[b].buftype == "terminal" then
				vim.g[gkey] = b
				vim.cmd("buffer " .. b)
				return
			end
		end

		opts.open()
		local newb = vim.api.nvim_get_current_buf()
		vim.b[newb][bmark] = true
		vim.g[gkey] = newb
	end
end

return M
