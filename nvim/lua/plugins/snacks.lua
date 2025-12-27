return {
	"folke/snacks.nvim",
	opts = {
		indent = { enabled = false },
		notifier = {},
		picker = {
			sources = {
				explorer = {
					actions = {
						run_test_file = function(picker)
							local item = picker:current()
							if not item or not item.file then
								vim.notify("Nothing selected", vim.log.levels.WARN)
								return
							end

							vim.cmd("TestSuite " .. vim.fn.fnameescape(item.file))
						end,
					},
					win = {
						list = {
							keys = {
								["<leader>tt"] = "run_test_file",
							},
						},
					},
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
