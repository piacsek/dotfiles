return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		ensure_installed = {
			"bash",
			"diff",
			"html",
			"lua",
			"javascript",
			"typescript",
			"tsx",
			"luadoc",
			"markdown",
			"vim",
			"vimdoc",
			"elixir",
			"heex",
			"eex",
			"json",
		},
		auto_install = true,
		highlight = {
			enable = true,
			disable = { "oil", "notify" },
		},
		indent = {
			enable = true,
			disable = { "oil", "notify" },
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.install").prefer_git = true
		require("nvim-treesitter.configs").setup(opts)
	end,
}
