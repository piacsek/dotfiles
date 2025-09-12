return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	keys = {
		{ "<leader>zz", "<cmd>NoNeckPain<cr>", desc = "Toggle no-neck-pain" },
	},
	opts = {
		width = 120,
		buffers = {
			right = {
				enabled = false,
			},
			left = {
				enabled = true,
			},
		},
	},
}