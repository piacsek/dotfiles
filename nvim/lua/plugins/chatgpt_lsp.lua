-- ~/.config/nvim/lua/plugins/elixir-lsp.lua
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
	},
	config = function()
		-- Setup Mason to manage LSP installations
		require("mason").setup()
		require("mason-tool-installer").setup({
			ensure_installed = { "elixir-ls" },
		})

		local capabilities = vim.tbl_deep_extend(
			"force",
			vim.lsp.protocol.make_client_capabilities(),
			require("cmp_nvim_lsp").default_capabilities()
		)

		require("lspconfig").elixirls.setup({
			cmd = { "elixir-ls" },
			root_dir = require("lspconfig.util").root_pattern("mix.exs"),
			capabilities = capabilities,
			settings = {
				elixirLS = {
					dialyzerEnabled = false,
					fetchDeps = false,
					enableTestLenses = false,
					suggestSpecs = false,
					mixEnv = "dev",
				},
			},
		})

		-- Basic LSP keymaps
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(event)
				local map = function(keys, func, desc)
					vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
				end
				map("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
				map("gr", vim.lsp.buf.references, "[G]oto [R]eferences")
				map("K", vim.lsp.buf.hover, "Hover Documentation")
				map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
				map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
			end,
		})
	end,
}
