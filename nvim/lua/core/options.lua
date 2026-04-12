vim.g.have_nerd_font = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "
-- local current_date = os.date("*t")
-- print(current_date.wday) -- Example: 1 for Sunday, 2 for Monday, etc.

local current_date = os.date("*t")
-- vim.notify(current_date)
vim.g._default_colorscheme = "high-contrast"
vim.cmd.colorscheme(vim.g._default_colorscheme)

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
		source = true,
		header = "",
		prefix = "",
	},
	severity_sort = true,
	update_in_insert = false,
})
