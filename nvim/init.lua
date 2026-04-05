vim.pack.add({
	"https://github.com/folke/snacks.nvim",
	"https://github.com/LintaoAmons/scratch.nvim",
})
require("snacks").setup({
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

						picker:close()

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
})

require("scratch").setup({
	scratch_file_dir = "~/scratch.nvim",
	window_cmd = "edit",
	file_picker = "fzflua",
	filetypes = { "ex", "lua", "js", "sh", "ts", "json", "heex", "html", "sql", "md" },
})

vim.keymap.set("n", "<leader>fs", ":ScratchOpen<CR>", { desc = "[J]ump to [S]cratch" })
vim.keymap.set("n", "<leader>n", ":Scratch<CR>", { desc = "[N]ew scratch" })
