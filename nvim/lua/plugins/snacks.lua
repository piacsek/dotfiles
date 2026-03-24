return {
	"folke/snacks.nvim",
	opts = {
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
						search_in_dir = function(picker)
							local item = picker:current()
							if not item then
								vim.notify("Nothing selected", vim.log.levels.WARN)
								return
							end

							-- Get directory path: use item.file if directory, otherwise parent dir
							local dir_path
							if item.file then
								if vim.fn.isdirectory(item.file) == 1 then
									dir_path = item.file
								else
									dir_path = vim.fn.fnamemodify(item.file, ":h")
								end
							else
								dir_path = vim.fn.getcwd()
							end

							-- Close the explorer picker
							picker:close()

							-- Open fzf-lua live_grep in the directory
							require("fzf-lua").live_grep({
								cwd = dir_path,
								winopts = {
									height = 0.9,
									width = 0.9,
									preview = {
										hidden = "nohidden",
									},
								},
							})
						end,
					},
					win = {
						list = {
							keys = {
								["<leader>tt"] = "run_test_file",
								["<leader>ss"] = "search_in_dir",
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
				Snacks.explorer({ position = "right" })
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
			"<leader>gyy",
			mode = { "n", "v" },
			function()
				Snacks.gitbrowse({
					notify = false,
					branch = "main",
					open = function(url)
						vim.fn.setreg("+", url)
						vim.notify("GitHub URL copied (main)", vim.log.levels.INFO)
					end,
				})
			end,
			desc = "Copy GitHub URL to clipboard (main branch)",
		},
		{
			"<leader>gyc",
			mode = { "n", "v" },
			function()
				Snacks.gitbrowse({
					notify = false,
					open = function(url)
						vim.fn.setreg("+", url)
						vim.notify("GitHub URL copied (current branch)", vim.log.levels.INFO)
					end,
				})
			end,
			desc = "Copy GitHub URL to clipboard (current branch)",
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
				-- Get current file's directory, fallback to CWD if no file
				local file_dir = vim.fn.expand("%:p:h")
				if file_dir == "" then
					file_dir = vim.fn.getcwd()
				end

				-- Find git root from current file's directory
				local git_root = vim.fs.root(file_dir, ".git")

				Snacks.lazygit({ cwd = git_root, win = { width = 0.9, height = 0.9 } })
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
