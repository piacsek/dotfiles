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
      indent = { enable = true },
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
      "jfpedroza/neotest-elixir",
    },
    config = function()
      -- Hack: neotest spawns a headless nvim which doesn't have everything loaded up like the regular instance
      -- And neotest elixir requires some stuff to be loaded in order to run return "require("neotest-elixir")._build_position"
      if not vim.env.LUA_PATH then
        local adapter_dir = vim.fn.stdpath("data") .. "/lazy/neotest-elixir"
        local lua_paths = table.concat({ adapter_dir .. "/lua/?.lua", adapter_dir .. "/lua/?/init.lua" }, ";")

        vim.env.LUA_PATH = lua_paths
      end

      require("neotest").setup({
        adapters = {
          require("neotest-elixir"),
        },
      })
    end,
  },

{
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1002,
	opts = {},

	init = function()
		vim.cmd.colorscheme("tokyonight-moon")

		vim.cmd.hi("Comment gui=none")
	end,

	config = function()
		require("tokyonight").setup({
			on_colors = function(colors)
				colors.bg = "#000000"
				-- colors.bg_highlight = "#151458"
			end,
		})
	end,
},



{
	"nvim-telescope/telescope.nvim",
	event = "VimEnter",
	branch = "0.1.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{
			"nvim-telescope/telescope-fzf-native.nvim",

			build = "make",

			cond = function()
				return vim.fn.executable("make") == 1
			end,
		},
		{ "nvim-telescope/telescope-ui-select.nvim" },
		{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
	},
	config = function()
		require("telescope").setup({
			extensions = {
				["ui-select"] = {
					require("telescope.themes").get_dropdown(),
				},
			},
		})

		pcall(require("telescope").load_extension, "fzf")
		pcall(require("telescope").load_extension, "ui-select")

		local builtin = require("telescope.builtin")
		vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]find [H]elp" })
		vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]find [K]eymaps" })
		vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]find [S]elect Telescope" })
		vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]find current [W]ord" })
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]find by [G]rep" })
		vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]find [D]iagnostics" })
		vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "[F]find [R]esume" })
		vim.keymap.set("n", "<leader>f.", builtin.oldfiles, { desc = '[F]find Recent Files ("." for repeat)' })
		vim.keymap.set("n", "<leader>o", builtin.find_files, { desc = "[O]pen Files" })
		vim.keymap.set("n", "<leader><leader>", builtin.buffers, { desc = "[ ] Find existing buffers" })

		-- Searching selected words in visual mode
		function vim.getVisualSelection()
			vim.cmd('noau normal! "vy"')
			local text = vim.fn.getreg("v")
			vim.fn.setreg("v", {})

			text = string.gsub(text, "\n", "")

			return #text > 0 and text or ""
		end

		vim.keymap.set("v", "<leader>fw", function()
			local text = vim.getVisualSelection()
			builtin.grep_string({ default_text = text })
		end, { noremap = true, silent = true, desc = "[F]ind selected [W]ords" })

		vim.keymap.set("n", "<leader>/", function()
			builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
				winblend = 10,
				previewer = false,
				layout_config = {
					width = 120,
					height = 40,
				},
			}))
		end, { desc = "[/] Fuzzily search in current buffer" })

		vim.keymap.set("n", "<leader>f/", function()
			builtin.live_grep({
				grep_open_files = true,
				prompt_title = "Live Grep in Open Files",
			})
		end, { desc = "[F]find [/] in Open Files" })

		vim.keymap.set("n", "<leader>fn", function()
			builtin.find_files({ cwd = vim.fn.stdpath("config") })
		end, { desc = "[F]find [N]eovim files" })
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


