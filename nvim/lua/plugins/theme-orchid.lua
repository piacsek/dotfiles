return {
	"dark-orchid/neovim",
	priority = 1000,
	lazy = false,
	config = function()
		require("dark-orchid").setup()
	end,
}
