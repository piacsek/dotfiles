vim.g.have_nerd_font = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Cursor configuration
-- Always use block cursor, blink in insert mode only
vim.opt.guicursor = {
	"n-v-c:block", -- Normal, visual, command-line: block cursor
	"i-ci-ve:block-blinkwait700-blinkoff400-blinkon250", -- Insert, command-line insert, visual-exclude: block cursor with blinking
	"r-cr:hor20", -- Replace mode: horizontal bar cursor
	"o:hor50", -- Operator-pending: horizontal bar cursor
	"sm:block-blinkwait175-blinkoff150-blinkon175", -- Showmatch: block cursor with blinking
}

vim.opt.swapfile = false
vim.opt.winborder = "rounded"
vim.opt.autoread = true
vim.opt.breakindent = true
vim.opt.clipboard = ""
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
		source = "always",
		header = "",
		prefix = "",
	},
	severity_sort = true,
	update_in_insert = false,
})
