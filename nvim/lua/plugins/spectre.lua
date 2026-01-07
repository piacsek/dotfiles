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
			mode = "n",
			function()
				require("spectre").toggle({ path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.") })
			end,
			desc = "Toggle Spectre for current buffer",
		},
		{
			"<leader>SB",
			mode = "v",
			function()
				require("spectre").open_visual({ path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.") })
			end,
			desc = "Toggle Spectre w/ selection for current buffer",
		},
	},
	opts = {
		open_cmd = function()
			vim.cmd("noautocmd new")
			vim.api.nvim_win_set_config(0, {
				relative = "editor",
				width = math.floor(vim.o.columns * 0.8),
				height = math.floor(vim.o.lines * 0.8),
				row = math.floor(vim.o.lines * 0.1),
				col = math.floor(vim.o.columns * 0.1),
				style = "minimal",
				border = "rounded",
			})
		end,
	},
}
