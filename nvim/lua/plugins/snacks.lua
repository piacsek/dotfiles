return {
	"folke/snacks.nvim",
	opts = {
		indent = { enabled = false },
		notifier = {},
		explorer = {
			keys = {
				["<leader>tt"] = {
					action = function(item)
						vim.cmd("TestSuite " .. item.path)
					end,
					desc = "Run test file",
				},
			},
		},
	},
	keys = {
		{
			"<leader>jp",
			function()
				Snacks.explorer()
			end,
			desc = "Filetree",
		},
		{
			"<leader>jn",
			function()
				Snacks.notifier.show_history()
			end,
			desc = "Jump to notifications",
		},
		{
			"<leader>gp",
			function()
				Snacks.picker.gh_pr()
			end,
			desc = "GitHub Pull Requests (open)",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
	},
}
