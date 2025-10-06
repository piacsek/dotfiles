return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	lazy = false,
	opts = {
		width = 120,
		autocmds = {
			enableOnVimEnter = true,
		},
		buffers = {
			right = { enabled = false },
			bo = { filetype = "no-neck-pain" },
		},
	},
	keys = {
		{ "<leader>z", "<cmd>NoNeckPain<cr>", desc = "Toggle NoNeckPain" },
	},
}
