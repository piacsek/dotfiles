vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Reset &background to dark before any colorscheme loads. Light schemes
-- (e.g. catppuccin-latte) set background=light themselves and still override
-- this; &background-adaptive schemes like `default` would otherwise inherit a
-- stale "light" and render their washed light variant (which ghostty-mirror
-- then faithfully mirrors). Baseline-dark keeps the dark variant after a light
-- scheme.
vim.api.nvim_create_autocmd("ColorSchemePre", {
	desc = "Default &background to dark so adaptive schemes don't inherit a stale light",
	group = vim.api.nvim_create_augroup("background-baseline-dark", { clear = true }),
	callback = function()
		vim.o.background = "dark"
	end,
})
