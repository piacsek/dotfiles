vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
    "jfpedroza/neotest-elixir",
  },
  config = function()
    local adapter_dir = vim.fn.stdpath("data") .. "/lazy/neotest-elixir"

    local lua_paths = table.concat({
      adapter_dir .. "/lua/?.lua",
      adapter_dir .. "/lua/?/init.lua",
    }, ";")

    if not vim.env.LUA_PATH or #vim.env.LUA_PATH <= 0 then
      vim.env.LUA_PATH = lua_paths
    end

    require("neotest").setup({
      log_level = vim.log.levels.DEBUG,
      adapters = {
        require("neotest-elixir"),
      },
    })
  end,
},
 

})


vim.keymap.set("n", "<leader><BS>", ":w<CR>", { desc = "Save file" })

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

