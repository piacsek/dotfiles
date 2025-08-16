-- require("piacsek")

---------------------------
--  <basic vim configs>  --
---------------------------

-- vim.g configs

vim.g.have_nerd_font = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- vim.opt configs

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

vim.opt.scrolloff = 10
vim.opt.shiftwidth = 2
vim.opt.showmode = false
vim.opt.signcolumn = "yes"
vim.opt.smartcase = false
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.tabstop = 2
vim.opt.timeoutlen = 300

vim.opt.updatetime = 250
vim.opt.undofile = true

-- vim.api configs

vim.api.nvim_create_augroup("autoread", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	group = "autoread",
	command = "checktime",
})


----------------------------
--  <basic vim configs/>  --
----------------------------



--------------------
--  <lazy setup>  --
--------------------

-- from https://lazy.folke.io/installation

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" }, { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'bash', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc', 'elixir', 'heex', 'eex' },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
      "jfpedroza/neotest-elixir",
    },
    lazy = false,
    config = function()
      require("neotest").setup({
        log_level = vim.log.levels.DEBUG,
        adapters = {
          require("neotest-python"),
          require("neotest-elixir"),
        },
      })
    end,
  },
})

---------------------
--  <lazy setup/>  --
---------------------

---------------------
--    <remaps>     --
---------------------



-- <Normal mode remaps>
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search results highlights" })
vim.keymap.set("n", "<Tab>", "<C-w>w", { desc = "Go to next window" })
vim.keymap.set("n", "<S-Tab>", "<C-w>p", { desc = "Go to previous window" })

vim.keymap.set("n", "<leader><Esc>", ":hide<CR>", { desc = "Hide window" })
vim.keymap.set("n", "<leader>vp", vim.cmd.Ex, { desc = "Hide window" })

vim.keymap.set("n", "<leader><BS>", ":w<CR>", { desc = "Save file" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Avoiding Q" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Auto zz" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Auto zz" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Pastes content without losing current "0 contents' })
vim.keymap.set(
	"n",
	"<leader>s",
	[[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
	{ desc = "Replace word under the cursor" }
)

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set(
	"n",
	"<leader>y",
	':lua vim.fn.setreg("+", vim.fn.expand("%:p") .. ":" .. vim.fn.line("."))<CR>',
	{ noremap = true, silent = true, desc = "[Y]anks current buffer filepath" }
)

vim.keymap.set("n", "<C-.>", ":horizontal resize +5<CR>", { desc = "Increase window horizontal size" })
vim.keymap.set("n", "<C-,>", ":horizontal resize -5<CR>", { desc = "Decrease window horizontal size" })

vim.keymap.set("n", ">", ":vertical resize +5<CR>", { desc = "Increase window vertical size" })
vim.keymap.set("n", "<", ":vertical resize -5<CR>", { desc = "Decrease window vertical size" })

-- </Normal mode remaps>

-- <Visual mode remaps>

vim.keymap.set("v", "<leader>s", '"sy:%s/<C-r>s/', { desc = "[S]ubstitute selected word" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move currently selection one line below" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move currently selection one line above" })

-- </Visual mode remaps>

-- <Terminal mode remaps>
vim.keymap.set("t", "<C-Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
-- </Terminal mode remaps>

-- <Neotest remaps>
vim.keymap.set("n", "<leader>tt", function()
  require("neotest").run.run()
end, { desc = "[T]est neares[T]" })

vim.keymap.set("n", "<leader>tf", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "[T]est [F]ile" })

vim.keymap.set("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "[T]est [S]ummary" })

vim.keymap.set("n", "<leader>to", function()
  require("neotest").output.open({ enter = true })
end, { desc = "[T]est [O]utput" })
-- </Neotest remaps>

----------------------
--    </remaps>     --
----------------------


