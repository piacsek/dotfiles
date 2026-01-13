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

require("lazy").setup("plugins")

vim.g._default_colorscheme = "moonfly"
vim.cmd.colorscheme(vim.g._default_colorscheme)

vim.notify = require("snacks").notifier.notify

require("core.lsp")
local project_templates = vim.fn.getcwd() .. "/piacsek/init.lua"
if vim.fn.filereadable(project_templates) == 1 then
	local function project_register(opts)
		if opts.name == nil then
			vim.notify("Invalid overseer project template: must define a unique name", vim.log.levels.WARN)
			return
		end
		if project_template_names[opts.name] == true then
			vim.notify(
				opts.name .. " has already been defined in this project. Skipping duplicate...",
				vim.log.levels.WARN
			)
			return
		end
		project_template_names[opts.name] = true
		original_register(opts)
	end
	overseer.register_template = project_register
	dofile(project_templates)(overseer)
	overseer.register_template = original_register
end
require("piacsek")
