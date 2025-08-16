if vim.loader then vim.loader.enable() end

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
    { "jfpedroza/neotest-elixir", lazy = false }, -- keep it eager
  },
  lazy = false,
  config = function()
    -- 0) (Optional but good) enable the modern loader very early in your init.lua:
    --    if vim.loader then vim.loader.enable() end

    -- 1) Put the adapter dir on runtimepath (parent → mirrored to child)
    local data = vim.fn.stdpath("data")
    local adapter_dir = data .. "/lazy/neotest-elixir"
    vim.opt.rtp:append(adapter_dir)

    -- 2) Put the adapter on LUA_PATH (env → inherited by child)
    local lua_paths = adapter_dir .. "/lua/?.lua;" .. adapter_dir .. "/lua/?/init.lua"
    if vim.env.LUA_PATH and #vim.env.LUA_PATH > 0 then
      if not string.find(vim.env.LUA_PATH, adapter_dir, 1, true) then
        vim.env.LUA_PATH = vim.env.LUA_PATH .. ";" .. lua_paths
      end
    else
      vim.env.LUA_PATH = lua_paths
    end

    require("neotest").setup({
      log_level = vim.log.levels.DEBUG,

      -- Tiny consumer: in the CHILD, make sure loader is on and warm up the module
      consumers = {
        elixir_child_boot = function(client)
          client.listeners.starting.elixir_child_boot = function()
            if vim.loader then vim.loader.enable() end
            -- attempt to load once so subsequent remote calls succeed
            pcall(require, "neotest-elixir")
          end
        end,
      },

      adapters = {
        -- instantiate explicitly so the parent registers it
        require("neotest-elixir")({}),
      },
    })
  end,
} ,
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

