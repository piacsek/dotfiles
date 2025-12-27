return {
	"folke/snacks.nvim",
	opts = {},
	keys = {
		{
			"<leader>gp",
			function()
				Snacks.picker.gh_pr()
			end,
			desc = "GitHub Pull Requests (open)",
		},
	},
}
