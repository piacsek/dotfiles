vim.pack.add({
	"https://github.com/folke/snacks.nvim",
	"https://github.com/LintaoAmons/scratch.nvim",
})
require("snacks").setup({})

require("scratch").setup({
	scratch_file_dir = "~/scratch.nvim",
	window_cmd = "edit",
	file_picker = "fzflua",
	filetypes = { "ex", "lua", "js", "sh", "ts", "json", "heex", "html", "sql", "md" },
})

vim.keymap.set("n", "<leader>fs", ":ScratchOpen<CR>", { desc = "[J]ump to [S]cratch" })
vim.keymap.set("n", "<leader>n", ":Scratch<CR>", { desc = "[N]ew scratch" })
