return {
	"folke/snacks.nvim",
	opts = {
		indent = { enabled = false },
	},
	keys = {
		{
			"<leader>gp",
			function()
				Snacks.picker.gh_pr()
			end,
			desc = "GitHub Pull Requests (open)",
		},
		{
			"<leader>g1",
			function()
				Snacks.git.blame_line()
			end,
			desc = "Git blame_line",
		},
	},
}
