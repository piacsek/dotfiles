return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	opts = {
		width = 120,
		buffers = {
			right = { enabled = false },
			bo = {
				filetype = "no-neck-pain",
			},
		},
	},
	keys = {
		{ "<leader>z", "<cmd>NoNeckPain<cr>", desc = "Toggle NoNeckPain" },
	},
}
