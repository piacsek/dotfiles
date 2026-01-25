return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"bash",
				"diff",
				"html",
				"lua",
				"luadoc",
				"javascript",
				"typescript",
				"tsx",
				"markdown",
				"markdown_inline",
				"vim",
				"vimdoc",
				"elixir",
				"heex",
				"eex",
				"json",
			},
			-- Disable nvim-treesitter's highlighting, we use native
			highlight = { enable = false },
			indent = { enable = false },
		})
	end,
}
