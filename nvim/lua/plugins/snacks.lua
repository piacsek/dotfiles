return {
	"folke/snacks.nvim",
	opts = {
		notifier = {},
		picker = {
			sources = {
				explorer = {
					actions = {
						run_test_file = function(picker)
							-- Get all selected items, or current item if none selected
							local items = picker:selected()
							if not items or #items == 0 then
								local current = picker:current()
								if current then
									items = { current }
								end
							end

							if not items or #items == 0 then
								vim.notify("Nothing selected", vim.log.levels.WARN)
								return
							end

							-- Collect all file paths
							local files = {}
							for _, item in ipairs(items) do
								if item.file then
									table.insert(files, vim.fn.fnameescape(item.file))
								end
							end

							if #files == 0 then
								vim.notify("No files selected", vim.log.levels.WARN)
								return
							end

							vim.cmd("TestSuite " .. table.concat(files, " "))
						end,
					},
					win = {
						list = {
							keys = {
								["<leader>tt"] = {
									action = "run_test_file",
									mode = { "n", "v" },
								},
							},
						},
					},
				},
			},
		},
		bigfile = { enabled = false },
		bufdelete = { enabled = false },
		dashboard = { enabled = false },
		debug = { enabled = false },
		dim = { enabled = false },
		git = { enabled = false },
		indent = { enabled = false },
		input = { enabled = false },
		profiler = { enabled = false },
		quickfile = { enabled = false },
		rename = { enabled = false },
		scope = { enabled = false },
		scroll = { enabled = false },
		statuscolumn = { enabled = false },
		toggle = { enabled = false },
		words = { enabled = false },
		zen = { enabled = false },
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
				local file = vim.fn.expand("%")
				Snacks.terminal.open("git diff origin/main -- " .. vim.fn.shellescape(file), {
					win = {
						style = "float",
						width = 0.9,
						height = 0.9,
					},
				})
			end,
			desc = "Diff current file vs origin/main",
		},
		{
			"<leader>gg",
			function()
				Snacks.lazygit()
			end,
			desc = "Lazygit",
		},
		{
			"<leader>N",
			desc = "Neovim News",
			function()
				Snacks.win({
					file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
					width = 0.6,
					height = 0.6,
					wo = {
						spell = false,
						wrap = false,
						signcolumn = "yes",
						statuscolumn = " ",
						conceallevel = 3,
					},
				})
			end,
		},
	},
}
