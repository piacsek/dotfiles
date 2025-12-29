return {
	"LintaoAmons/scratch.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "ibhagwan/fzf-lua" },
	},
	config = function()
		require("scratch").setup({
			scratch_file_dir = "~/scratch.nvim",
			window_cmd = "edit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
			file_picker = "fzflua", -- "fzflua" | "telescope" | "snacks" | nil
			filetypes = { "ex", "lua", "js", "sh", "ts", "json", "heex", "html", "sql", "md" },
		})
	end,
	keys = {
		{ "<leader>fs", ":ScratchOpen<CR>", mode = "n", desc = "[J]ump to [S]cratch" },
		{ "<leader>n", ":Scratch<CR>", mode = "n", desc = "[N]ew scratch" },
	},
}
