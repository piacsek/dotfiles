vim.filetype.add({
	filename = {
		[".tmux-sessionizer"] = "bash",
	},
})

-- JSON indents with 2 spaces, not tabs. expandtab is off globally (tabs
-- elsewhere), and the LSP formatter derives insertSpaces from it — so without
-- this, jsonls formats JSON with tabs.
vim.api.nvim_create_autocmd("FileType", {
	desc = "Use 2 spaces for JSON",
	group = vim.api.nvim_create_augroup("json-indent", { clear = true }),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.bo.expandtab = true
		vim.bo.shiftwidth = 2
		vim.bo.tabstop = 2
		vim.bo.softtabstop = 2
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
