local function setup_lsp_keymaps(event)
	local map = function(keys, func, desc)
		vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
	end

	map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
	map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
	map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
	map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
	map("K", vim.lsp.buf.hover, "Hover Documentation")
	map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

	local client = vim.lsp.get_client_by_id(event.data.client_id)
	if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
		map("<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, "[T]oggle Inlay [H]ints")
	end
end

local function setup_general_lsp_keymaps()
	vim.keymap.set("n", "<leader>ll", ":LspLog<CR>", { desc = "[L]SP [L]ogs" })
	vim.keymap.set("n", "<leader>li", ":LspInfo<CR>", { desc = "[L]SP [I]nfo" })
	vim.keymap.set("n", "<leader>lr", ":LspRestart<CR>", { desc = "[L]SP [R]estart" })
end

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		"SmiteshP/nvim-navbuddy",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		{ "folke/neodev.nvim", enabled = false, opts = {} },
		"b0o/schemastore.nvim",
	},
	config = function()
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				setup_lsp_keymaps(event)
			end,
		})

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		local servers = {
			html = {
				filetypes = { "html" },
			},
			emmet_ls = {
				filetypes = { "html", "heex", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
			},
			tailwindcss = {
				filetypes = { "html", "heex", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
			},
			vimls = {},
			ts_ls = {},
			elixirls = {
				filetypes = { "elixir", "eelixir", "heex", "surface" },
				root_dir = require("lspconfig.util").root_pattern("mix.exs"),
				settings = {
					elixirLS = {
						dialyzerEnabled = false,
						fetchDeps = false,
						enableTestLenses = false,
						-- suggestSpecs requires dialyzer
						suggestSpecs = false,
						mixEnv = "dev",
					},
				},
				-- ElixirLS also reads from init_options
				init_options = {
					dialyzerEnabled = false,
					fetchDeps = false,
					enableTestLenses = false,
					suggestSpecs = false,
					mixEnv = "dev",
				},
			},
			lua_ls = {
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			},
			jsonls = {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			},
			yamlls = {
				settings = {
					yaml = {
						schemas = {
							["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
							["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.yml",
						},
					},
				},
			},
		}

		require("mason").setup()

		local ensure_installed = {
			"vimls",
			"elixirls",
			"lua_ls",
			"yaml-language-server",
			"json-lsp",
			"tailwindcss",
			"html",
			"emmet-ls",
			"typescript-language-server",
		}
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					-- Ensure capabilities are properly merged
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})

					require("lspconfig")[server_name].setup(server)
				end,
				-- Specific handler for elixirls to ensure settings are applied
				elixirls = function()
					require("lspconfig").elixirls.setup({
						capabilities = capabilities,
						filetypes = { "elixir", "eelixir", "heex", "surface" },
						root_dir = require("lspconfig.util").root_pattern("mix.exs"),
						init_options = {
							dialyzerEnabled = false,
							fetchDeps = false,
							enableTestLenses = false,
							suggestSpecs = false,
							mixEnv = "dev",
						},
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
				end,
			},
		})
		vim.lsp.config["emmet_ls"] = {
			capabilities = capabilities,
			filetypes = { "html", "heex", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
		}

		setup_general_lsp_keymaps()
	end,
}
