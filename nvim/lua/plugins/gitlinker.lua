return {
	"linrongbin16/gitlinker.nvim",
	cmd = "GitLink",
	opts = {},
	keys = {
		{ "<leader>gy", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "[Y]ank [g]it link" },
		{ "<leader>gw", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open [g]it link on the [w]eb browser" },
	},
}
