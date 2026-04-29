vim.g.have_nerd_font = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local theme_file = vim.fn.expand("~/.config/ghostty/theme-current")
local lines = vim.fn.filereadable(theme_file) == 1 and vim.fn.readfile(theme_file) or {}
local from_ghostty = lines[1] and lines[1]:match("theme%s*=%s*(%S+)")
vim.g._default_colorscheme = from_ghostty or "zaibatsu"

-- Plugin colorschemes aren't loaded yet; try now, retry after plugins load.
if not pcall(vim.cmd.colorscheme, vim.g._default_colorscheme) then
	vim.api.nvim_create_autocmd("VimEnter", {
		once = true,
		callback = function()
			pcall(vim.cmd.colorscheme, vim.g._default_colorscheme)
		end,
	})
end

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
