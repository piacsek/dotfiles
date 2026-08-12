local gh = function(x)
	return "https://github.com/" .. x
end

vim.pack.add({
	gh("JoosepAlviste/nvim-ts-context-commentstring"),
	gh("windwp/nvim-autopairs"),
	gh("echasnovski/mini.ai"),
	gh("echasnovski/mini.surround"),
	-- Queries only (textobjects.scm) — mini.ai reads them, nothing else here
	-- uses this plugin's own module. Must track `main` to match nvim-treesitter.
	{ src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },
	gh("echasnovski/mini.icons"),
	gh("echasnovski/mini.hipatterns"),
	gh("windwp/nvim-ts-autotag"),
	{ src = gh("sontungexpt/url-open"), version = "mini" },
	gh("sotte/presenting.nvim"),
	gh("herisetiawan00/jtt.nvim"),
	gh("christoomey/vim-tmux-navigator"),
	gh("mason-org/mason.nvim"),
	gh("neovim/nvim-lspconfig"),
	gh("folke/lazydev.nvim"),
	gh("lewis6991/gitsigns.nvim"),
	gh("stevearc/conform.nvim"),
	gh("nvim-treesitter/nvim-treesitter"),
	gh("stevearc/oil.nvim"),
	{ src = gh("ThePrimeagen/harpoon"), version = "harpoon2" },
	gh("ThePrimeagen/99"),
	gh("nvim-lua/plenary.nvim"),
	gh("ibhagwan/fzf-lua"),
	gh("MagicDuck/grug-far.nvim"),
	gh("LintaoAmons/scratch.nvim"),
	gh("hrsh7th/nvim-cmp"),
	gh("L3MON4D3/LuaSnip"),
	gh("saadparwaiz1/cmp_luasnip"),
	gh("hrsh7th/cmp-nvim-lsp"),
	gh("hrsh7th/cmp-path"),
	gh("vim-test/vim-test"),
	gh("preservim/vimux"),
	gh("folke/snacks.nvim"),
	-- live-server is a hard dependency of markdown-preview (same author) — its
	-- init.lua requires live_server.server. Not directly used; don't prune.
	gh("selimacerbas/live-server.nvim"),
	gh("selimacerbas/markdown-preview.nvim"),
	gh("piacsek/ghostty-mirror.nvim"),
	gh("smjonas/inc-rename.nvim"),
	gh("folke/trouble.nvim"),
	gh("stevearc/aerial.nvim"),
	gh("axkirillov/hbac.nvim"),
	gh("nvim-lualine/lualine.nvim"),
	-- Debugging (DAP). nvim-nio is a hard dependency of nvim-dap-ui.
	gh("mfussenegger/nvim-dap"),
	gh("nvim-neotest/nvim-nio"),
	gh("rcarriga/nvim-dap-ui"),
	gh("theHamsta/nvim-dap-virtual-text"),
	-- Colorschemes
	gh("piacsek/high-contrast.nvim"),
	gh("piacsek/scintilla.nvim"),
	gh("piacsek/stargum.nvim"),
	gh("AlexvZyl/nordic.nvim"),
	gh("0Risotto/rainbow12"),
	gh("aisk/kukishinobu.vim"),
	gh("oxidescheme/oxide.nvim"),
	gh("dmkc/underwater-vim-theme"),
	gh("bluz71/vim-moonfly-colors"),
	gh("DRoma82/add-subtract-ex.nvim"),
}, { load = true })

require("add-subtract-ex").setup({})
-- Dev plugins
-- vim.opt.rtp:prepend(vim.fn.expand("~/projects/nvim-plugins/buddy.nvim")) Plugin setup
require("markdown_preview").setup({
	instance_mode = "takeover",
	port = 0, -- 0 = auto (8421 for takeover, OS-assigned for multi)
	open_browser = true,
	debounce_ms = 300,
})
require("inc_rename").setup({
	post_hook = function()
		vim.cmd("silent! wall")
	end,
})
require("nvim-autopairs").setup({})
-- mini.ai: treesitter-backed textobjects for whole constructs. Overriding `f`
-- costs the default function-CALL object, so that moves to `F`.
--   vaf / dif  function definition (also one Elixir def/defp clause)
--   vac / dic  class / module body
--   vao / dio  conditional or loop block
--   vaF / diF  function call (mini.ai's old `f`)
local ai_ts = require("mini.ai").gen_spec.treesitter
require("mini.ai").setup({
	-- Default is 50, which silently fails to find `af`/`ac` on anything longer
	-- — i.e. exactly the long use-case methods and class bodies where a
	-- whole-construct textobject earns its keep.
	n_lines = 500,
	custom_textobjects = {
		f = ai_ts({ a = "@function.outer", i = "@function.inner" }),
		c = ai_ts({ a = "@class.outer", i = "@class.inner" }),
		o = ai_ts({
			a = { "@conditional.outer", "@loop.outer" },
			i = { "@conditional.inner", "@loop.inner" },
		}),
		F = require("mini.ai").gen_spec.function_call(),
	},
})

-- mini.surround: sa add / sd delete / sr replace, all dot-repeatable. This
-- takes over `s` as a prefix (built-in `s` is just `cl`); set
-- `mappings = { add = "gsa", ... }` to reclaim it.
require("mini.surround").setup({
	custom_surroundings = {
		-- `sdf` unwraps a call: `await getConfig().url` -> its argument.
		f = { input = require("mini.ai").gen_spec.function_call() },
	},
})
require("mini.icons").setup({})
-- Inline preview of #rrggbb color codes: a swatch next to the code.
local hipatterns = require("mini.hipatterns")
hipatterns.setup({
	highlighters = {
		hex_color = hipatterns.gen_highlighter.hex_color({ style = "inline" }),
	},
})
require("nvim-ts-autotag").setup({})
require("ghostty-mirror").setup({
	manage_background = true,
	overrides = {
		["scintilla-sapphire"] = { selection_background = "#d700ff" },
	},
	sync_on_startup = true,
	sync_on_focus = true,

	tmux = {
		enabled = true,
		-- Copy-mode selection mirrors nvim's Visual highlight (its default), so a
		-- drag in a tmux pane matches a Visual selection in the editor per-theme.
		selection_hl = "Visual",
		overrides = {
			["scintilla-amethyst"] = { accent = "#d700ff", bar = "#3a0054" },
			-- accent kept just under 0.5 luminance so ghostty-mirror's readable_on
			-- picks the light fg (white text) for the active window / status-right.
			["stargum"] = { accent = "#c24e8e", bar = "#3a0026" },
			-- stargum-light is itself a light scheme, so ghostty-mirror sees
			-- &background=light and appends light_variant_suffix, resolving the
			-- theme name to "stargum-light-light" — that's the key it looks up.
			["stargum-light"] = { accent = "#d61f8f", bar = "#f7d4e8" },
			["stargum-light-light"] = { accent = "#d61f8f", bar = "#f7d4e8" },
			["scintilla-ruby"] = { accent = "#ff3b2e", bar = "#bd1424" },
			-- Default jade accent is Type's light #a0e6c0, so readable_on picks
			-- dark pill text. A deep jade green (luminance ~0.11) flips it to
			-- white text on the active window / status-right, matching sapphire.
			["scintilla-jade"] = { accent = "#0f6b3f", bar_blend = 0.4 },
			["scintilla-diamond-light"] = { accent = "#1840d8", bar = "#fbfcff" },
			["high-contrast"] = { accent = "#8547ff", bar_blend = 0.3 },
			["scintilla-sapphire"] = { accent = "#2e4eb2", bar_blend = 0.4 },
			blue = { accent = "#5ff" },
		},
	},
})
-- Mirror the colorscheme into k9s too (ghostty-mirror only covers Ghostty/tmux).
require("core.k9s_mirror").setup()
require("url-open").setup({
	highlight_url = {
		cursor_move = {
			enabled = false,
		},
	},
})
require("presenting").setup({})
require("jtt").setup({
	languages = {
		javascript = {
			mode = "suffix",
			test = ".spec",
			ext = ".\\{js,ts,jsx,tsx\\}",
			source_ext = ".\\{js,ts,jsx,tsx\\}",
		},
		typescript = {
			mode = "suffix",
			test = ".spec",
			ext = ".\\{ts,js,tsx,jsx\\}",
			source_ext = ".\\{ts,js,tsx,jsx\\}",
		},
		typescriptreact = {
			mode = "suffix",
			test = ".spec",
			ext = ".\\{tsx,jsx,ts,js\\}",
			source_ext = ".\\{tsx,jsx,ts,js\\}",
		},
		javascriptreact = {
			mode = "suffix",
			test = ".spec",
			ext = ".\\{jsx,tsx,js,ts\\}",
			source_ext = ".\\{jsx,tsx,js,ts\\}",
		},
	},
})
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

-- Source of truth for mason-installed tools. Mason itself keeps no manifest,
-- so on a fresh machine `:MasonInstallTools` installs whatever is missing.
-- Add an entry when wiring up a new LSP server (core/lsp.lua) or formatter
-- (conform, below) — an absent formatter falls back to LSP formatting silently
-- (notify_on_error = false), and an absent server just never attaches.
local mason_tools = {
	-- LSP servers
	"bash-language-server",
	"dexter",
	"emmet-ls",
	"html-lsp",
	"json-lsp",
	"lua-language-server",
	"tailwindcss-language-server",
	"typescript-language-server",
	"vim-language-server",
	"yaml-language-server",
	-- Formatters
	"prettierd",
	"stylua",
	-- Debug adapters (see plugins/dap.lua)
	"js-debug-adapter",
}

vim.api.nvim_create_user_command("MasonInstallTools", function()
	-- snacks' notifier draws nothing without a UI, so fall back to print under
	-- `nvim --headless` (how SETUP_MACOS.md drives this).
	local report = function(msg)
		if #vim.api.nvim_list_uis() == 0 then
			print(msg)
		else
			vim.notify(msg, vim.log.levels.INFO)
		end
	end

	local registry = require("mason-registry")
	-- Blocking refresh (no callback) so this also works headless, where a
	-- deferred callback would never run before qall.
	registry.refresh()
	local missing = vim.tbl_filter(function(tool)
		return not registry.is_installed(tool)
	end, mason_tools)
	if vim.tbl_isempty(missing) then
		report("mason: all " .. #mason_tools .. " tools already installed")
		return
	end
	report("mason: installing " .. table.concat(missing, ", "))
	vim.cmd("MasonInstall " .. table.concat(missing, " "))
end, { desc = "Install any missing mason tools" })

require("conform").setup({
	notify_on_error = false,
	-- Lowest-priority default: filetypes with no configured formatter still get
	-- LSP formatting. Filetype-level settings below outrank it.
	default_format_opts = { lsp_format = "fallback" },
	format_on_save = function(bufnr)
		local disable_filetypes = { c = true, cpp = true, yaml = true }
		if disable_filetypes[vim.bo[bufnr].filetype] then
			return { timeout_ms = 3000, lsp_format = "never" }
		end
		-- Deliberately no lsp_format here. conform fills only nil keys when
		-- merging, and options passed at format time outrank filetype ones —
		-- so returning "fallback" unconditionally silently overrode elixir's
		-- `lsp_format = "prefer"` and ran mix on every save.
		return { timeout_ms = 3000 }
	end,
	formatters_by_ft = {
		lua = { "stylua" },
		-- dexter formats over LSP in-process; `mix format` pays Elixir/Mix
		-- startup on every save. lsp_format = "prefer" uses dexter when it is
		-- attached and falls back to mix when it isn't (no project index,
		-- server crashed, non-project file).
		-- heex/eelixir stay on mix: its formatter handles them through the
		-- Phoenix formatter plugins, and dexter's handling there is unverified.
		elixir = { "mix", lsp_format = "prefer" },
		eelixir = { "mix" },
		heex = { "mix" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
	},
})

require("plugins.aerial")
require("plugins.nine")
require("plugins.dap")
require("plugins.lualine")
require("trouble").setup({})

-- hbac: auto-close least-recently-used buffers beyond the threshold
-- hbac has no exclude option, so terminals are kept safe two ways: pinned on
-- open (pins are never autoclose candidates), plus a hard guard in close_command.
require("hbac").setup({
	autoclose = true,
	threshold = 10,
	count_pinned = false,
	close_buffers_with_windows = false,
	close_command = function(bufnr)
		if vim.bo[bufnr].buftype == "terminal" then
			return
		end
		vim.api.nvim_buf_delete(bufnr, {})
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("hbac_pin_terminals", { clear = true }),
	callback = function(ev)
		require("hbac.state").set_pin(ev.buf, true)
	end,
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
		"sql",
	})
end, {})

-- Start treesitter for any filetype with an installed parser, instead of a
-- hardcoded list (which silently missed typescriptreact/javascriptreact — no
-- highlighting, injections, or autotag in .tsx). pcall: start() errors when
-- no parser exists for the filetype; that's the no-op path, not a failure.
vim.api.nvim_create_autocmd("FileType", {
	callback = function()
		pcall(vim.treesitter.start)
	end,
})

-- JSX/TSX-aware commentstring for built-in gcc/gc
vim.g.skip_ts_context_commentstring_module = true
require("ts_context_commentstring").setup({ enable_autocmd = false })

local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
	return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
		or get_option(filetype, option)
end

-- Oil
require("oil").setup({
	view_options = { show_hidden = true },
	keymaps = {
		["<CR>"] = { "actions.select" },
		["-"] = { "actions.parent", mode = "n" },
		["_"] = { "actions.open_cwd", mode = "n" },
		["~"] = { "<cmd>edit $HOME<CR>", desc = "Open home directory", mode = "n" },
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
		["<leader>ss"] = {
			callback = function()
				local dir = require("oil").get_current_dir()
				require("fzf-lua").live_grep({
					cwd = dir,
					winopts = { height = 0.9, width = 0.9, preview = { hidden = "nohidden" } },
				})
			end,
			desc = "Grep in current Oil directory",
			mode = "n",
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

require("grug-far").setup({})

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
luasnip.filetype_extend("typescriptreact", { "typescript" })
luasnip.filetype_extend("javascript", { "typescript" })
luasnip.filetype_extend("javascriptreact", { "typescript" })

cmp.setup({
	view = {
		docs = {
			auto_open = false,
		},
	},
	window = {
		completion = {
			winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
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
		["<C-y>"] = cmp.mapping(function()
			if cmp.visible() then
				cmp.confirm({ select = true })
			else
				cmp.complete()
			end
		end, { "i", "s" }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "path" },
	},
})

-- vim-test
vim.g["test#filename_modifier"] = ":p"
vim.g["test#strategy"] = "vimux"
vim.g["VimuxRunnerName"] = "vimtest"
vim.g["test#preserve_screen"] = 0
vim.g["test#echo_command"] = 0
vim.g["test#neovim#term_position"] = "topleft vsplit"
vim.g["test#neovim_sticky#kill_previous"] = 1
-- playwright-bdd (.feature) runner, defined in autoload/test/javascript/playwrightbdd.vim
vim.g["test#custom_runners"] = { JavaScript = { "PlaywrightBdd" } }

-- Snacks
--

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
	bigfile = { enabled = true },
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

vim.notify = require("snacks").notifier.notify

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
		-- Results in blines/grep/lines are treesitter-highlighted, and the
		-- default match color is "-1:reverse" — it inverts each matched
		-- substring, turning the token's *foreground* syntax color into the
		-- match *background*. That reads fine on dark variants but produces
		-- garish syntax-colored blocks with near-invisible text on light
		-- themes (scintilla-diamond). Replace the reverse trick with a single
		-- bold accent foreground, sourced from FzfLuaFzfMatch (links to
		-- Special) so it stays theme-aware across variants. Must live in THIS
		-- setup call: fzf-lua's setup() resets all prior config unless told to
		-- merge, so a separate earlier setup({winopts...}) would be wiped here.
		treesitter = {
			fzf_colors = {
				["hl"] = { "fg", "FzfLuaFzfMatch", "bold" },
				["hl+"] = { "fg", "FzfLuaFzfMatch", "bold" },
			},
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
	if ok and local_config and local_config.file_ignore_patterns then
		fzf_config.files = vim.tbl_deep_extend(
			"force",
			fzf_config.files or {},
			{ file_ignore_patterns = local_config.file_ignore_patterns }
		)
		fzf_config.grep = vim.tbl_deep_extend(
			"force",
			fzf_config.grep or {},
			{ file_ignore_patterns = local_config.file_ignore_patterns }
		)
	end
end

fzf.setup(fzf_config)
fzf.register_ui_select()
