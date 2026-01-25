return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	config = function()
		vim.api.nvim_create_user_command("TSInstallParsers", function()
			require("nvim-treesitter").install({
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
			})
		end, {})

		vim.api.nvim_create_autocmd("FileType", {
			pattern = {
				"bash",
				"html",
				"lua",
				"javascript",
				"typescript",
				"markdown",
				"vim",
				"elixir",
				"heex",
				"eex",
				"json",
			},
			callback = vim.treesitter.start,
		})
	end,
}
