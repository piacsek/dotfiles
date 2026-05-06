-- Enable bytecode cache for faster Lua module loading
vim.loader.enable()

require("core.options")
require("core.plugins")
require("core.commands")
require("core.auto_commands")
require("core.keymaps")
require("core.lsp")
