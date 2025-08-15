return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"jfpedroza/neotest-elixir",
	},
	config = function()
		require("neotest").setup({
			log_level = vim.log.levels.DEBUG,
			adapters = {
				require("neotest-elixir"),
			},
		})
	end,
}
