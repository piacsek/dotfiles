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
			"<leader>SW",
			function()
				require("spectre").open_visual({ select_word = true })
			end,
			desc = "Search current word",
		},
		{
			"<leader>SW",
			mode = "v",
			function()
				require("spectre").open_visual()
			end,
			desc = "Search current word",
		},
		{
			"<leader>S/",
			function()
				require("spectre").open_file_search({ select_word = true })
			end,
			desc = "Search in current file",
		},
	},
	opts = {},
}
