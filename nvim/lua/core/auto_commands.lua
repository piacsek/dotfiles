local function tone_down_zaibatsu()
	vim.api.nvim_set_hl(0, "StatusLine", { fg = "#d7d5db", bg = "#1f0a3a" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#878092", bg = "#170233" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "zaibatsu",
	desc = "Tone down zaibatsu's bright white statusline",
	callback = tone_down_zaibatsu,
})

-- options.lua applies the colorscheme before this file loads, so the autocmd
-- above misses the initial load. Apply the override now if we're already on it.
if vim.g.colors_name == "zaibatsu" then
	tone_down_zaibatsu()
end

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
