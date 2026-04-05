-- Enable bytecode cache for faster Lua module loading
vim.loader.enable()

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.commands")

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

local gh = function(x) return "https://github.com/" .. x end

vim.pack.add({
})

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
