vim.pack.add({
	"https://github.com/LintaoAmons/scratch.nvim",
})

vim.keymap.set("n", "<leader>fs", ":ScratchOpen<CR>", { desc = "[J]ump to [S]cratch" })
vim.keymap.set("n", "<leader>n", ":Scratch<CR>", { desc = "[N]ew scratch" })
require("scratch").setup({
	scratch_file_dir = "~/scratch.nvim",
	window_cmd = "edit",
	file_picker = "fzflua",
	filetypes = { "ex", "lua", "js", "sh", "ts", "json", "heex", "html", "sql", "md" },
})

-- nvim-cmp
local cmp = require("cmp")
local luasnip = require("luasnip")
luasnip.config.setup({})
require("luasnip.loaders.from_lua").load({ paths = vim.fn.stdpath("config") .. "/snippets" })

cmp.setup({
	view = {
		docs = {
			auto_open = false,
		},
	},
	window = {
		completion = {
			winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
			col_offset = -3,
			side_padding = 0,
			max_width = 60,
			max_height = 15,
		},
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	mapping = cmp.mapping.preset.insert({
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-b>"] = cmp.mapping.scroll_docs(-4),
		["<C-f>"] = cmp.mapping.scroll_docs(4),
		["<C-k>"] = cmp.mapping(function()
			if cmp.visible_docs() then
				cmp.close_docs()
			else
				cmp.open_docs()
			end
		end),
		["<C-y>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
	},
})

-- vim-test
vim.keymap.set("n", "<leader>tt", "<cmd>TestNearest<cr>", { desc = "Test nearest" })
vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<cr>", { desc = "Test file" })
vim.keymap.set("n", "<leader>td", function()
	local snacks = require("snacks")
	local test_root = vim.g._root_test_dir or "test"
	local test_dirs = vim.fn.globpath(test_root, "*", false, true)
	local items = {}

	for _, path in ipairs(test_dirs) do
		if vim.fn.isdirectory(path) == 1 then
			table.insert(items, { text = path, file = path })
		end
	end

	if #items == 0 then
		vim.notify("No directories found under " .. test_root .. "/", vim.log.levels.WARN)
		return
	end

	snacks.picker({
		source = "test_dirs",
		items = items,
		layout = "select",
		actions = {
			confirm = function(picker, item)
				picker:close()
				local sel = picker:selected()
				local paths = {}

				if #sel > 0 then
					for _, s in ipairs(sel) do
						table.insert(paths, vim.fn.fnameescape(s.text))
					end
				elseif item then
					table.insert(paths, vim.fn.fnameescape(item.text))
				end

				if #paths > 0 then
					vim.cmd("TestSuite " .. table.concat(paths, " "))
				else
					vim.notify("No items selected", vim.log.levels.WARN)
				end
			end,
		},
	})
end, { desc = "Test directories" })
vim.keymap.set("n", "<leader>tm", function()
	local test_root = vim.g._root_test_dir or "test"
	local output = vim.fn.systemlist("git diff --relative --name-only main -- " .. test_root)

	if vim.v.shell_error ~= 0 or #output == 0 then
		vim.notify("No modified test files found vs main", vim.log.levels.WARN)
		return
	end

	local paths = {}
	for _, file in ipairs(output) do
		table.insert(paths, vim.fn.fnameescape(file))
	end

	vim.cmd("TestSuite " .. table.concat(paths, " "))
end, { desc = "[T]est [M]odified (vs main)" })
vim.keymap.set("n", "<leader><BS>", function()
	if vim.bo.buftype == "" then
		vim.cmd("w")
	end
	vim.cmd("TestLast")
end, { desc = "Save and run last test" })
vim.g["test#strategy"] = "vimux"
vim.g["test#preserve_screen"] = 0
vim.g["test#echo_command"] = 0
vim.g["test#neovim#term_position"] = "topleft vsplit"
vim.g["test#neovim_sticky#kill_previous"] = 1

-- Snacks
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

vim.keymap.set("n", "<leader>jp", function()
	Snacks.explorer({ position = "right" })
end, { desc = "Filetree" })
vim.keymap.set("n", "<leader>jn", function()
	Snacks.notifier.show_history()
end, { desc = "Jump to notifications" })
vim.keymap.set("n", "<leader>gp", function()
	Snacks.picker.gh_pr()
end, { desc = "GitHub Pull Requests (open)" })
vim.keymap.set("n", "<leader>gw", function()
	Snacks.gitbrowse()
end, { desc = "Open current file on GitHub" })
vim.keymap.set({ "n", "v" }, "<leader>gyy", function()
	Snacks.gitbrowse({
		notify = false,
		branch = "main",
		open = function(url)
			vim.fn.setreg("+", url)
			vim.notify("GitHub URL copied (main)", vim.log.levels.INFO)
		end,
	})
end, { desc = "Copy GitHub URL to clipboard (main branch)" })
vim.keymap.set({ "n", "v" }, "<leader>gyc", function()
	Snacks.gitbrowse({
		notify = false,
		open = function(url)
			vim.fn.setreg("+", url)
			vim.notify("GitHub URL copied (current branch)", vim.log.levels.INFO)
		end,
	})
end, { desc = "Copy GitHub URL to clipboard (current branch)" })
vim.keymap.set("n", "<leader>gh", function()
	Snacks.picker.git_log_file()
end, { desc = "Git history for current file" })
vim.keymap.set("n", "<leader>gd", function()
	local file = vim.fn.expand("%")
	Snacks.terminal.open("git diff origin/main -- " .. vim.fn.shellescape(file), {
		win = { style = "float", width = 0.9, height = 0.9 },
	})
end, { desc = "Diff current file vs origin/main" })
vim.keymap.set("n", "<leader>gg", function()
	local file_dir = vim.fn.expand("%:p:h")
	if file_dir == "" then
		file_dir = vim.fn.getcwd()
	end
	local git_root = vim.fs.root(file_dir, ".git")
	Snacks.lazygit({ cwd = git_root, win = { width = 0.9, height = 0.9 } })
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>N", function()
	Snacks.win({
		file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
		width = 0.6,
		height = 0.6,
		wo = { spell = false, wrap = false, signcolumn = "yes", statuscolumn = " ", conceallevel = 3 },
	})
end, { desc = "Neovim News" })

-- fzf-lua
local fzf = require("fzf-lua")

local function open_commit_on_browser(selected)
	if not selected or #selected == 0 then
		return
	end
	local commit = selected[1]:match("^(%S+)")
	if commit then
		require("snacks").gitbrowse({ commit = commit })
	end
end

local fzf_config = {
	winopts = {
		height = 0.4,
		width = 0.5,
		row = 0.5,
		col = 0.5,
		preview = {
			hidden = "hidden",
		},
	},
	keymap = {
		fzf = {
			true,
			["ctrl-q"] = "select-all+accept",
		},
	},
	git = {
		bcommits = { actions = { ["ctrl-w"] = open_commit_on_browser } },
		commits = { actions = { ["ctrl-w"] = open_commit_on_browser } },
	},
}

local cwd = vim.fn.getcwd()
local local_config_path = cwd .. "/piacsek/fzf.lua"

if vim.fn.filereadable(local_config_path) == 1 then
	local ok, local_config = pcall(dofile, local_config_path)
	if ok and local_config then
		fzf_config = vim.tbl_deep_extend("force", fzf_config, local_config)
	end
end

fzf.setup(fzf_config)
fzf.register_ui_select()

local grep_winopts = {
	height = 0.9,
	width = 0.9,
	preview = { hidden = "nohidden" },
}

function vim.getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg("v")
	vim.fn.setreg("v", {})
	text = string.gsub(text, "\n", "")
	return #text > 0 and text or ""
end

local function run_script_picker()
	local entries = vim.g._available_scripts
	if entries == nil then
		vim.notify("No available scripts configured. Please set vim.g._available_scripts", vim.log.levels.ERROR)
		return
	end

	fzf.fzf_exec(function(fzf_cb)
		for _, entry in ipairs(entries) do
			fzf_cb(entry)
		end
		fzf_cb()
	end, {
		prompt = "Scripts> ",
		winopts = { height = 0.4, width = 0.5 },
		actions = {
			["default"] = function(selected)
				if selected and #selected == 1 then
					vim.fn.system(selected[1])
				end
			end,
			["ctrl-w"] = function(selected)
				if selected and #selected == 1 then
					vim.fn.system(string.format("tmux new-window '%s';", selected[1]))
				end
			end,
			["ctrl-s"] = function(selected)
				if selected and #selected == 1 then
					vim.fn.system(string.format("tmux split-window -v -p 50 '%s';", selected[1]))
				end
			end,
			["ctrl-v"] = function(selected)
				if selected and #selected == 1 then
					vim.fn.system(string.format("tmux split-window -h -p 50 '%s';", selected[1]))
				end
			end,
		},
	})
end

-- Script runner
vim.keymap.set("n", "<leader>r", run_script_picker, { desc = "[R]un script" })

-- Find files
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "[F]ind [F]iles" })
vim.keymap.set("n", "<leader>fh", fzf.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>ft", fzf.colorschemes, { desc = "[F]ind [T]heme" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>F", fzf.resume, { desc = "Resume last search" })
vim.keymap.set("n", "<leader><leader>", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "[F]ind [O] files" })

vim.keymap.set("v", "<leader>ff", function()
	local text = vim.getVisualSelection()
	fzf.files({ query = text })
end, { noremap = true, silent = true, desc = "[F]ind [F]files with selected text" })

vim.keymap.set("n", "<leader>fp", function()
	fzf.files({ cwd = vim.fn.getcwd() .. "/piacsek" })
end, { desc = "[F]ind [P]iacsek files" })

vim.keymap.set("n", "<leader>fd", function()
	fzf.files({ cwd = "~/dotfiles" })
end, { desc = "[F]ind [D]otfiles" })

vim.keymap.set("v", "<leader>fm", function()
	local text = vim.getVisualSelection()
	fzf.git_status({ query = text })
end, { noremap = true, silent = true, desc = "[F]ind [M]odified git files with selection" })

-- Search
vim.keymap.set("v", "<leader>ss", function()
	local text = vim.getVisualSelection()
	fzf.live_grep({ search = text, winopts = grep_winopts })
end, { desc = "[G]rep selected" })

vim.keymap.set("n", "<leader>ss", function()
	fzf.live_grep({ winopts = grep_winopts })
end, { desc = "[F]ind by [G]rep" })

vim.keymap.set("n", "<leader>sc", function()
	fzf.live_grep({ cwd = "~/dotfiles", winopts = grep_winopts })
end, { desc = "Grep config files" })

vim.keymap.set("v", "<leader>sc", function()
	local text = vim.getVisualSelection()
	fzf.live_grep({ cwd = "~/dotfiles", search = text, winopts = grep_winopts })
end, { desc = "[G]rep selected" })

vim.keymap.set("n", "<leader>/", function()
	fzf.blines()
end, { desc = "[/] Fuzzily search in current buffer" })

vim.keymap.set("v", "<leader>/", function()
	local text = vim.getVisualSelection()
	fzf.blines({ query = text })
end, { desc = "[/] Fuzzily search in current buffer" })

-- Git
vim.keymap.set("n", "<leader>gh", fzf.git_bcommits, { desc = "[G]it [H]istory" })
vim.keymap.set("n", "<leader>fm", fzf.git_status, { desc = "[F]ind [M]odified git files" })
vim.keymap.set("n", "<leader>gsm", function()
	fzf.git_commits({
		cmd = "git log --color --pretty=format:'%C(yellow)%h%Creset %Cgreen(%><(12)%cr%><|(12))%Creset %s %C(blue)<%an>%Creset' main",
	})
end, { desc = "[G]it [S]earch [M]ain branch commits" })

-- Colorscheme
-- vim.g._default_colorscheme = "moonfly"
vim.g._default_colorscheme = "high-contrast"
-- vim.g._default_colorscheme = "oxide"
vim.cmd.colorscheme(vim.g._default_colorscheme)

vim.notify = require("snacks").notifier.notify

require("core.lsp")
local home_init = vim.fn.expand("$HOME/init.lua")
if vim.fn.filereadable(home_init) == 1 then
	dofile(home_init)
end

local local_init = vim.fn.getcwd() .. "/piacsek/init.lua"
if vim.fn.filereadable(local_init) == 1 then
	dofile(local_init)
end
