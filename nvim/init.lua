-- require("piacsek")

-----------------
-- set configs --
-----------------

-- vim.g configs

vim.g.have_nerd_font = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- vim.opt configs

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = false
vim.opt.smartcase = false
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.autoread = true

-- vim.api configs

vim.api.nvim_create_augroup("autoread", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	group = "autoread",
	command = "checktime",
})
