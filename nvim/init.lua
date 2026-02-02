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

-- if tonumber(os.date("%H")) <= 13 then
-- vim.g._default_colorscheme = "cyberdream-light"
-- else
-- vim.g._default_colorscheme = "moonfly"
vim.g._default_colorscheme = "high-contrast"
-- end
vim.cmd.colorscheme(vim.g._default_colorscheme)

vim.notify = require("snacks").notifier.notify

require("core.lsp")
local local_init = vim.fn.getcwd() .. "/piacsek/init.lua"
if vim.fn.filereadable(local_init) == 1 then
	dofile(local_init)
end
