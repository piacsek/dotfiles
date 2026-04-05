-- Enable bytecode cache for faster Lua module loading
vim.loader.enable()

-- <OPTIONS>
vim.g.have_nerd_font = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.termguicolors = true
vim.opt.swapfile = false
vim.opt.winborder = "rounded"
vim.opt.autoread = true
vim.opt.breakindent = true
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true
vim.opt.hlsearch = true
vim.opt.ignorecase = false
vim.opt.inccommand = "split"
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 999
vim.opt.shiftwidth = 2
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.smartcase = false
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.tabstop = 2
vim.opt.timeoutlen = 300
vim.opt.updatetime = 500
vim.opt.undofile = true

vim.diagnostic.config({
	virtual_text = {
		prefix = "●",
		spacing = 4,
		severity = { min = vim.diagnostic.severity.WARN },
	},
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
	severity_sort = true,
	update_in_insert = false,
})

-- </OPTIONS>

-- <COMMANDS>
-- Overriding the ones from https://github.com/neovim/nvim-lspconfig because they open on new tabs
vim.api.nvim_create_user_command("LspInfo", "vertical checkhealth vim.lsp", { desc = "Show LSP health check" })

vim.api.nvim_create_user_command("ClearOldfiles", function()
	vim.v.oldfiles = {}
	vim.cmd("wshada!")
	vim.notify("Oldfiles list cleared", vim.log.levels.INFO)
end, { desc = "Clear the oldfiles list" })

vim.api.nvim_create_user_command("LineNumbers", function()
	vim.opt.relativenumber = true
	vim.opt.number = true
end, { desc = "Force line numbers to appear" })

vim.api.nvim_create_user_command("VerboseModeEnable", function()
	vim.opt.verbose = 12
	vim.opt.verbosefile = "/tmp/nvim-verbose.log"
end, { desc = "Enable verbose mode and log to /tmp/nvim-verbose.log" })

vim.api.nvim_create_user_command("VerboseModeDisable", function()
	vim.opt.verbose = 0
	vim.opt.verbosefile = ""
end, { desc = "Disable verbose mode" })

vim.api.nvim_create_user_command("VerboseModeOpenFile", function()
	vim.cmd("e /tmp/nvim-verbose.log")
end, { desc = "Opens verbose mode log file" })

vim.api.nvim_create_user_command("VerboseModeDeleteFile", function()
	vim.cmd("!rm /tmp/nvim-verbose.log")
end, { desc = "Deletes verbose mode log file" })

vim.api.nvim_create_user_command("BufferStats", function()
	local buffers = vim.api.nvim_list_bufs()
	local loaded = 0
	local hidden = 0
	local modified = 0
	local with_lsp = 0
	local total_diagnostics = 0

	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buf) then
			loaded = loaded + 1

			-- Check if hidden
			local wins = vim.fn.win_findbuf(buf)
			if #wins == 0 then
				hidden = hidden + 1
			end

			-- Check if modified
			if vim.api.nvim_get_option_value("modified", { buf = buf }) then
				modified = modified + 1
			end

			-- Check LSP attachment
			local clients = vim.lsp.get_clients({ bufnr = buf })
			if #clients > 0 then
				with_lsp = with_lsp + 1
			end

			-- Count diagnostics
			local diag = vim.diagnostic.get(buf)
			total_diagnostics = total_diagnostics + #diag
		end
	end

	local msg = string.format(
		"Buffers:\n  Total loaded: %d\n  Hidden: %d\n  Modified: %d\n  With LSP: %d\n  Total diagnostics: %d",
		loaded,
		hidden,
		modified,
		with_lsp,
		total_diagnostics
	)
	vim.notify(msg, vim.log.levels.INFO)
end, { desc = "Show buffer statistics" })

vim.api.nvim_create_user_command("NotificationsHistory", function()
	require("snacks").notifier.show_history()
end, { desc = "Notification history" })

vim.api.nvim_create_user_command("NotificationsClear", function()
	require("snacks").notifier.hide()
end, { desc = "Clear all notifications" })

vim.api.nvim_create_user_command("ThemeRandom", function()
	-- local all_colorschemes = vim.fn.getcompletion("", "color")
	local colorschemes = { "high-contrast", "evening", "moonfly", "cyberdream-light", "nordic", "rainbow12" }
	local random_colorscheme = colorschemes[math.random(#colorschemes)]
	vim.cmd.colorscheme(random_colorscheme)
	vim.notify(random_colorscheme)
end, { desc = "Assigns a random colorscheme" })

vim.api.nvim_create_user_command("ThemeDefault", function()
	vim.cmd.colorscheme(vim.g._default_colorscheme)
	vim.notify(vim.g._default_colorscheme)
end, { desc = "Assigns the default colorscheme" })

-- </COMMANDS>
-- <AUTO_COMMANDS>
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
-- </AUTO_COMMANDS>

local gh = function(x)
	return "https://github.com/" .. x
end

-- PLUGINS
vim.pack.add({
	-- Simple plugins
	gh("numToStr/Comment.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("echasnovski/mini.ai"),
	gh("echasnovski/mini.icons"),
	gh("windwp/nvim-ts-autotag"),
	{ src = gh("sontungexpt/url-open"), version = "mini" },
	gh("sotte/presenting.nvim"),
	gh("herisetiawan00/jtt.nvim"),
	gh("christoomey/vim-tmux-navigator"),

	-- Colorschemes
	gh("scottmckendry/cyberdream.nvim"),
	gh("piacsek/high-contrast.nvim"),
	gh("AlexvZyl/nordic.nvim"),
	gh("0Risotto/rainbow12"),
	gh("aisk/kukishinobu.vim"),
	gh("oxidescheme/oxide.nvim"),
	gh("dmkc/underwater-vim-theme"),
	gh("bluz71/vim-moonfly-colors"),

	-- LSP & tooling
	gh("mason-org/mason.nvim"),
	gh("neovim/nvim-lspconfig"),
	gh("folke/lazydev.nvim"),
	gh("lewis6991/gitsigns.nvim"),
	gh("stevearc/conform.nvim"),
	gh("nvim-treesitter/nvim-treesitter"),

	-- File navigation
	gh("stevearc/oil.nvim"),
	{ src = gh("ThePrimeagen/harpoon"), version = "harpoon2" },
	gh("nvim-lua/plenary.nvim"),
	gh("ibhagwan/fzf-lua"),

	-- Search & replace
	gh("nvim-pack/nvim-spectre"),
	gh("LintaoAmons/scratch.nvim"),

	-- Completion
	gh("hrsh7th/nvim-cmp"),
	gh("L3MON4D3/LuaSnip"),
	gh("saadparwaiz1/cmp_luasnip"),
	gh("hrsh7th/cmp-nvim-lsp"),
	gh("hrsh7th/cmp-path"),

	-- Testing
	gh("vim-test/vim-test"),
	gh("preservim/vimux"),

	-- UI
	gh("folke/snacks.nvim"),
}, { load = true })

-- Dev plugins
-- vim.opt.rtp:prepend(vim.fn.expand("~/projects/nvim-plugins/buddy.nvim"))

-- Plugin setup
require("nvim-autopairs").setup({})
require("mini.ai").setup({})
require("mini.icons").setup({})
require("nvim-ts-autotag").setup({})
require("url-open").setup({
	highlight_url = {
		cursor_move = {
			enabled = false,
		},
	},
})
require("presenting").setup({})
require("jtt").setup()
require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},
	current_line_blame = false,
	auto_attach = true,
	current_line_blame_opts = {
		delay = 0,
		virt_text = true,
		virt_text_pos = "eol",
	},
	on_attach = function(bufnr)
		vim.keymap.set("n", "<leader>u", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset git hunk", buffer = bufnr })
		vim.keymap.set(
			"n",
			"<leader>gb",
			"<cmd>Gitsigns toggle_current_line_blame<CR>",
			{ desc = "[G]it [B]lame toggle", buffer = bufnr }
		)
		vim.keymap.set(
			"n",
			"{",
			"<cmd>Gitsigns nav_hunk prev<CR>",
			{ desc = "Go to previous git hunk", buffer = bufnr }
		)
		vim.keymap.set("n", "}", "<cmd>Gitsigns nav_hunk next<CR>", { desc = "Go to next git hunk", buffer = bufnr })
	end,
})
require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗",
		},
	},
})
vim.keymap.set("", "<C-f>", function()
	require("conform").format({ async = true, lsp_fallback = true })
end, { desc = "[F]ormat buffer" })
require("conform").setup({
	notify_on_error = false,
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true, yaml = true, yml = true }
		return {
			timeout_ms = 3000,
			lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
		}
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
	},
})

-- Treesitter
vim.api.nvim_create_user_command("TSInstallParsers", function()
	require("nvim-treesitter").install({
		"bash",
		"diff",
		"html",
		"lua",
		"luadoc",
		"javascript",
		"typescript",
		"tsx",
		"markdown",
		"markdown_inline",
		"vim",
		"vimdoc",
		"elixir",
		"heex",
		"eex",
		"json",
	})
end, {})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"bash",
		"html",
		"lua",
		"javascript",
		"typescript",
		"markdown",
		"vim",
		"elixir",
		"heex",
		"eex",
		"json",
	},
	callback = function()
		vim.treesitter.start()
	end,
})

-- Oil
vim.keymap.set("n", "<leader>o", ":Oil<CR>", { desc = "Open Oil" })
require("oil").setup({
	view_options = { show_hidden = true },
	keymaps = {
		["<CR>"] = { "actions.select" },
		["-"] = { "actions.parent", mode = "n" },
		["_"] = { "actions.open_cwd", mode = "n" },
		["<leader>tt"] = {
			callback = function()
				local oil = require("oil")
				local entry = oil.get_cursor_entry()

				if not entry then
					vim.notify("No file under cursor", vim.log.levels.WARN)
					return
				end

				local dir = oil.get_current_dir()
				local filepath = dir .. entry.name

				vim.cmd("TestSuite " .. filepath)
			end,
			desc = "Run test file under cursor",
		},
		["<leader>x"] = {
			callback = function()
				local oil = require("oil")
				local entry = oil.get_cursor_entry()

				if not entry then
					vim.notify("No file under cursor", vim.log.levels.WARN)
					return
				end

				local filepath = oil.get_current_dir() .. entry.name

				vim.fn.system("chmod +x " .. vim.fn.shellescape(filepath))
				vim.notify("Made executable: " .. entry.name, vim.log.levels.INFO)
			end,
			desc = "Make file executable (chmod +x)",
		},
	},
	use_default_keymaps = false,
})

-- Harpoon
local harpoon = require("harpoon")
harpoon:setup()

vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<leader>A", function()
	harpoon:list():clear()
	harpoon:list():add()
end)
vim.keymap.set("n", "<M-j>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<M-k>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<M-l>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<M-;>", function()
	harpoon:list():select(4)
end)
vim.keymap.set("n", "<M-'>", function()
	harpoon:list():select(5)
end)
vim.keymap.set("n", "<M-e>", function()
	harpoon.ui:toggle_quick_menu(require("harpoon"):list())
end)

-- Spectre
vim.keymap.set("n", "<leader>SS", function()
	require("spectre").toggle()
end, { desc = "Toggle Spectre" })
vim.keymap.set("v", "<leader>SS", function()
	require("spectre").open_visual()
end, { desc = "Toggle Spectre w/ selection" })
vim.keymap.set("n", "<leader>SB", function()
	require("spectre").toggle({ path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.") })
end, { desc = "Toggle Spectre for current buffer" })
vim.keymap.set("v", "<leader>SB", function()
	require("spectre").open_visual({ path = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:.") })
end, { desc = "Toggle Spectre w/ selection for current buffer" })
require("spectre").setup({
	open_cmd = function()
		vim.cmd("noautocmd new")
		vim.api.nvim_win_set_config(0, {
			relative = "editor",
			width = math.floor(vim.o.columns * 0.8),
			height = math.floor(vim.o.lines * 0.8),
			row = math.floor(vim.o.lines * 0.1),
			col = math.floor(vim.o.columns * 0.1),
			style = "minimal",
			border = "rounded",
		})
	end,
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

-- <KEYMAPS>
local arrow_disabling_opts = { noremap = true, silent = true }
vim.keymap.set({ "n", "i", "v", "c" }, "<Up>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Down>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Left>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Right>", "<Nop>", arrow_disabling_opts)

vim.keymap.set(
	{ "n" },
	"<M-r>",
	":mksession! Session.vim | restart source Session.vim <CR>",
	{ desc = "[R]estarts nvim" }
)
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "[Y]ank to system clipboard" })
vim.keymap.set("n", "<leader>yp", function()
	vim.fn.setreg('"', vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:."))
end, { desc = "Yank current file path" })

vim.keymap.set("n", "<leader>yb", ":%yank <CR>", { desc = "[Y]ank [B]uffer" })
vim.keymap.set("n", "<leader>YB", ":%yank +<CR>", { desc = "[Y]ank [B]uffer to system clipboard" })
vim.keymap.set("n", "<leader>YP", function()
	vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Yank current file path" })

vim.keymap.set("n", "<C-g>", "#*viw", { desc = "Multiple cursor replacement" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search results highlights" })

vim.keymap.set("n", "<C-Esc>", "<cmd>hide<CR>", { desc = "Hide buffer" })
vim.keymap.set("n", "<leader>bc", "<cmd>CleanHiddenBuffers<CR>", { desc = "[B]uffer [C]lean hidden" })
vim.keymap.set("n", "<leader>bs", "<cmd>BufferStats<CR>", { desc = "[B]uffer [S]tats" })
vim.keymap.set("n", "Y", "y$", { desc = "[Y]ank till the end of the line" })
vim.keymap.set("n", "V", "v$", { desc = "[V]isually select till the end of the line" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Avoiding Q" })

-- Quickfix
vim.keymap.set("n", "<leader>jq", ":copen<CR>", { desc = "[J]ump to the quickfix list" })
vim.keymap.set("n", "<M-n>", ":cnext<CR>", { desc = "Go to the [n]ext item in the quickfix list" })
vim.keymap.set("n", "<M-p>", ":cprev<CR>", { desc = "Go to the [p]revious item in the quickfix list" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Pastes content without losing current "0 contents' })

vim.keymap.set("n", "[", vim.diagnostic.get_next, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]", vim.diagnostic.get_prev, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set({ "n", "v" }, "<C-s>", ":w<CR>", { desc = "[S]ave" })

vim.keymap.set("n", "<C-.>", ":horizontal resize +5<CR>", { desc = "Increase window horizontal size" })
vim.keymap.set("n", "<C-,>", ":horizontal resize -5<CR>", { desc = "Decrease window horizontal size" })

vim.keymap.set("n", ">", ":vertical resize +5<CR>", { desc = "Increase window vertical size" })
vim.keymap.set("n", "<", ":vertical resize -5<CR>", { desc = "Decrease window vertical size" })

vim.keymap.set("t", "<C-o>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>i", ":Inspect<CR>", { desc = "[I]nspect" })
vim.keymap.set("i", "<C-p>", function()
	vim.cmd.normal("p")
end, { desc = "[P]aste in insert mode" })

vim.keymap.set("n", "g<Enter>", "gF", { desc = "Go to file with line number support" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })

-- Plugin keymaps
vim.keymap.set("n", "<leader>jw", "<esc>:URLOpenUnderCursor<cr>", { desc = "[J]ump to [W]eb browser" })
vim.keymap.set("n", "<leader>jt", "<cmd>JumpTest<CR>", { desc = "[J]ump to [T]est" })

-- </KEYMAPS>
-- ----------------------------------------------------- <LSP> -----------------------------------------------------

-- Cache for elixir-ls root directory lookups to avoid expensive filesystem searches
local elixir_root_cache = {}

-- Load project-specific elixir root if configured
local project_elixir_root = nil
local project_lsp_config = vim.fn.getcwd() .. "/piacsek/lsp.lua"
if vim.fn.filereadable(project_lsp_config) == 1 then
	local ok, config = pcall(dofile, project_lsp_config)
	if ok and type(config) == "table" and config.elixir_root then
		project_elixir_root = config.elixir_root
	end
end

vim.lsp.config["elixir_ls"] = {
	cmd = { "elixir-ls" },
	filetypes = { "elixir", "eelixir", "heex", "surface" },
	root_dir = function(bufnr, on_dir)
		if project_elixir_root then
			on_dir(project_elixir_root)
			return
		end

		local fname = vim.api.nvim_buf_get_name(bufnr)

		if elixir_root_cache[fname] then
			on_dir(elixir_root_cache[fname])
			return
		end

		local parent_dir = vim.fn.fnamemodify(fname, ":h")
		if elixir_root_cache[parent_dir] then
			elixir_root_cache[fname] = elixir_root_cache[parent_dir]
			on_dir(elixir_root_cache[parent_dir])
			return
		end

		local matches = vim.fs.find({ "mix.exs" }, {
			upward = true,
			limit = 2,
			path = fname,
			stop = vim.env.HOME,
		})

		local child_or_root_path, maybe_umbrella_path = unpack(matches)
		local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

		if root_dir then
			elixir_root_cache[fname] = root_dir
			elixir_root_cache[parent_dir] = root_dir
		end

		on_dir(root_dir)
	end,
	settings = {
		elixirLS = {
			dialyzerEnabled = false,
			fetchDeps = false,
			enableTestLenses = false,
			suggestSpecs = false,
			mixEnv = "dev",
		},
	},
}

local emmet_config = vim.lsp.config["emmet_ls"] or {}
emmet_config.filetypes = vim.list_extend(emmet_config.filetypes or {}, { "heex", "eelixir" })
vim.lsp.config["emmet_ls"] = emmet_config

vim.lsp.enable("lua_ls")
vim.lsp.enable("vimls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("html")
vim.lsp.enable("emmet_ls")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("jsonls")
vim.lsp.enable("yamlls")
vim.lsp.enable("elixir_ls")

vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd.edit(vim.lsp.log.get_filename())
end, { desc = "Show LSP health check" })
-- </LSP>

local home_init = vim.fn.expand("$HOME/init.lua")
if vim.fn.filereadable(home_init) == 1 then
	dofile(home_init)
end

local local_init = vim.fn.getcwd() .. "/piacsek/init.lua"
if vim.fn.filereadable(local_init) == 1 then
	dofile(local_init)
end
