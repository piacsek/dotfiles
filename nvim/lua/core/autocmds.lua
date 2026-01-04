vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
	callback = function()
		if vim.bo.buftype == "" then
			vim.opt_local.scrolloff = 8
		end
	end,
})
