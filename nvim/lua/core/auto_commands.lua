vim.filetype.add({
	filename = {
		[".tmux-sessionizer"] = "bash",
	},
	pattern = {
		["%.tmux%-sessionizer"] = "bash", -- match anywhere a file ends in .tmux-sessionizer
	},
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})
