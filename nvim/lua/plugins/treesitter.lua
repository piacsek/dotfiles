return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
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
}
