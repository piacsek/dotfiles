return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	lazy = false,
	opts = {
		debug = true,
		width = 120,
		autocmds = {
			enableOnVimEnter = false,
			skipEnteringNoNeckPainBuffer = true,
		},
		buffers = {
			right = { enabled = false },
			bo = { filetype = "no-neck-pain" },
		},
	},
	config = function(_, opts)
		require("no-neck-pain").setup(opts)
	end,
	keys = {
		{ "<leader>z", "<cmd>NoNeckPain<cr>", desc = "Toggle NoNeckPain" },
	},
}
