vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "zaibatsu",
	desc = "Tone down zaibatsu's bright white statusline",
	callback = function()
		vim.api.nvim_set_hl(0, "StatusLine", { fg = "#d7d5db", bg = "#1f0a3a" })
		vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#878092", bg = "#170233" })
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
