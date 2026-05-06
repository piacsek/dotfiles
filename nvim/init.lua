-- Enable bytecode cache for faster Lua module loading
vim.loader.enable()

require("core.options")
require("core.plugins")
require("core.commands")
require("core.auto_commands")
require("core.keymaps")
require("core.lsp")

-- Config overrides
local home_init = vim.fn.expand("$HOME/init.lua")
if vim.fn.filereadable(home_init) == 1 then
	dofile(home_init)
end

-- Project-local init now lives in `.nvim.lua` at the project root and is
-- auto-sourced via `exrc` (see core/options.lua). Mark it trusted with `:trust`.
