-- Enable bytecode cache for faster Lua module loading
vim.loader.enable()

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.commands")

local gh = function(x)
	return "https://github.com/" .. x
end

vim.pack.add({
	gh("numToStr/Comment.nvim"),
	gh("windwp/nvim-autopairs"),
	gh("echasnovski/mini.ai"),
	gh("echasnovski/mini.icons"),
	gh("windwp/nvim-ts-autotag"),
	{ src = gh("sontungexpt/url-open"), version = "mini" },
	gh("sotte/presenting.nvim"),
	gh("herisetiawan00/jtt.nvim"),
	gh("christoomey/vim-tmux-navigator"),
	gh("scottmckendry/cyberdream.nvim"),
	gh("piacsek/high-contrast.nvim"),
	gh("AlexvZyl/nordic.nvim"),
	gh("0Risotto/rainbow12"),
	gh("aisk/kukishinobu.vim"),
	gh("oxidescheme/oxide.nvim"),
	gh("dmkc/underwater-vim-theme"),
	gh("bluz71/vim-moonfly-colors"),
	gh("mason-org/mason.nvim"),
	gh("neovim/nvim-lspconfig"),
	gh("folke/lazydev.nvim"),
	gh("lewis6991/gitsigns.nvim"),
}, { load = true })

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
		vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "[G]it [B]lame toggle", buffer = bufnr })
		vim.keymap.set("n", "{", "<cmd>Gitsigns nav_hunk prev<CR>", { desc = "Go to previous git hunk", buffer = bufnr })
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
-- vim.g._default_colorscheme = "moonfly"
vim.g._default_colorscheme = "high-contrast"
-- vim.g._default_colorscheme = "oxide"
vim.cmd.colorscheme(vim.g._default_colorscheme)

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
	dev = {
		path = "~/projects/nvim-plugins",
	},
})

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
