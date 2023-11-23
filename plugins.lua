local plugins = {
  {
    "elixir-tools/elixir-tools.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local elixir = require("elixir")
      local elixirls = require("elixir.elixirls")

      elixir.setup {
        nextls = {enable = true},
        credo = {},
        elixirls = {
          enable = true,
          settings = elixirls.settings {
            dialyzerEnabled = false,
            enableTestLenses = false,
          },
          on_attach = function(client, _bufnr)
            vim.keymap.set("n", "<space>fp", ":elixirfrompipe<cr>", { buffer = true, noremap = true })
            vim.keymap.set("n", "<space>tp", ":elixirtopipe<cr>", { buffer = true, noremap = true })
            vim.keymap.set("v", "<space>em", ":elixirexpandmacro<cr>", { buffer = true, noremap = true })
          end,
        }
      }
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  }
}

return plugins
