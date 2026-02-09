return {
	"yashranjan1/purple-rain.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		require("purple-rain").setup({
			transparent = false,
			terminal_colors = true,
			on_highlights = function(hl, c)
				hl.NormalFloat = { bg = c.bg }
				hl.FloatBorder = { bg = c.bg, fg = c.border }
			end,
		})
	end,
}
