-- Enable bytecode cache for faster Lua module loading
vim.loader.enable()

require("core.options")
require("core.plugins")
require("core.commands")
require("core.auto_commands")
require("core.ghostty_sync")
require("core.keymaps")
require("core.lsp")

-- Config overrides
local home_init = vim.fn.expand("$HOME/init.lua")
if vim.fn.filereadable(home_init) == 1 then
	dofile(home_init)
end

local local_init = vim.fn.getcwd() .. "/piacsek/init.lua"
if vim.fn.filereadable(local_init) == 1 then
	dofile(local_init)
end
