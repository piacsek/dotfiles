return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1002,
	opts = {},
	init = function()
		vim.cmd.colorscheme("tokyonight-moon")
		vim.cmd.hi("Comment gui=none")
	end,
	config = function()
		require("tokyonight").setup({
			on_colors = function(colors)
				colors.bg = "#000000"
			end,
		})
	end,
}