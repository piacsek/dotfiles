vim.pack.add({
	"https://github.com/folke/snacks.nvim",
	"https://github.com/LintaoAmons/scratch.nvim",
})
require("snacks").setup({ picker = {} })

require("scratch").setup({
	scratch_file_dir = "~/scratch.nvim",
	window_cmd = "edit",
	filetypes = { "ex", "lua", "js", "sh", "ts", "json", "heex", "html", "sql", "md" },
})
