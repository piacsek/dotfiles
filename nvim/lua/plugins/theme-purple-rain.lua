return {
	"yashranjan1/purple-rain.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("purple-rain").setup({
			transparent = false,
			terminal_colors = true,
		})
	end,
}
