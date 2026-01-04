return {
	"nvim-pack/nvim-spectre",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<leader>SS",
			function()
				require("spectre").toggle()
			end,
			desc = "Toggle Spectre",
		},
		{
			"<leader>SS",
			mode = "v",
			function()
				require("spectre").open_visual()
			end,
			desc = "Toggle Spectre w/ selection",
		},
		{
			"<leader>SB",
			mode = "v",
			function()
				require("spectre").open_visual()
			end,
			desc = "Toggle Spectre w/ selection",
		},
		{
			"<leader>SB",
			mode = "v",
			function()
				require("spectre").open_visual()
			end,
			desc = "Toggle Spectre w/ selection",
		},
	},
	opts = {},
}
