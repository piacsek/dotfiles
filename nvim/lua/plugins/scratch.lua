return {
	"LintaoAmons/scratch.nvim",
	event = "VeryLazy",
	dependencies = {
		{ "ibhagwan/fzf-lua" },
		{ "nvim-telescope/telescope.nvim" },
	},
	config = function()
		require("scratch").setup({
			scratch_file_dir = "~/scratch.nvim",
			window_cmd = "rightbelow vsplit", -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
			file_picker = "fzflua", -- "fzflua" | "telescope" | "snacks" | nil
			filetypes = { "lua", "js", "sh", "ts", "json", "ex", "heex", "html", "sql" },
		})
	end,
}
