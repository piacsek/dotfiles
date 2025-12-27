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
			"<leader>gw",
			function()
				Snacks.gitbrowse()
			end,
			desc = "Open current file on GitHub",
		},
		{
			"<leader>gy",
			function()
				Snacks.gitbrowse({
					notify = false,
					open = function(url)
						vim.fn.setreg("+", url)
						vim.notify("URL copied to clipboard: " .. url, vim.log.levels.INFO)
					end,
				})
			end,
			desc = "Copy GitHub URL to clipboard",
		},
		{
			"<leader>gh",
			function()
				Snacks.picker.git_log_file()
			end,
			desc = "Git history for current file",
		},
		{
			"<leader>gd",
			function()
				Snacks.picker.git_log_file({ base = "origin/main" })
			end,
			desc = "Git history for file vs origin/main",
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
