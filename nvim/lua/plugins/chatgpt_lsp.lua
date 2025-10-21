return {
	{
		-- Core LSP client
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile" },

		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			"williamboman/mason-lspconfig.nvim",
		},

		config = function()
			-- Mason: manage LSP binaries
			require("mason").setup({})

			-- Install ONLY elixirls
			require("mason-lspconfig").setup({
				ensure_installed = { "elixirls" },
				automatic_installation = false,
			})

			-- Minimal capabilities (no cmp dependency)
			local capabilities = vim.lsp.protocol.make_client_capabilities()

			-- Keymaps on attach (Neovim 0.11 style)
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
				callback = function(ev)
					local map = function(lhs, rhs, desc)
						vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = "LSP: " .. desc })
					end
					map("gd", vim.lsp.buf.definition, "Goto Definition")
					map("gr", vim.lsp.buf.references, "Goto References")
					map("gD", vim.lsp.buf.declaration, "Goto Declaration")
					map("K", vim.lsp.buf.hover, "Hover")
					map("<leader>rn", vim.lsp.buf.rename, "Rename")
					map("<leader>ca", vim.lsp.buf.code_action, "Code Action")

					-- Inlay hints toggle (0.11 API)
					if vim.lsp.inlay_hint then
						map("<leader>th", function()
							local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf })
							vim.lsp.inlay_hint.enable(not enabled, { bufnr = ev.buf })
						end, "Toggle Inlay Hints")
					end
				end,
			})

			-- Set up elixirls with Dialyzer disabled
			local lspconfig = require("lspconfig")
			lspconfig.elixirls.setup({
				capabilities = capabilities,
				cmd = { "elixir-ls" }, -- resolved by Mason
				root_dir = require("lspconfig.util").root_pattern("mix.exs", ".git"),
				settings = {
					elixirLS = {
						dialyzerEnabled = false,
						suggestSpecs = false,
						fetchDeps = false,
						enableTestLenses = false,
						mixEnv = "dev",
					},
				},
			})
		end,
	},
}
