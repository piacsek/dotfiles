return {
	"nvim-pack/nvim-spectre",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<leader>S",
			function()
				require("spectre").toggle()
			end,
			desc = "Toggle Spectre",
		},
		{
			"<leader>S",
			mode = "v",
			function()
				require("spectre").open_visual()
			end,
			desc = "Search current word",
		},
	},
	opts = {},
}
