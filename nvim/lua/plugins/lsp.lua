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
		{ "folke/neodev.nvim", opts = {} },
		"b0o/schemastore.nvim",
	},
	config = function()
		local MAX_BUFFERS_PER_CLIENT = 4
		local client_fifo = {} -- [client_id] = {buf1, buf2, ...} (oldest first)
		local client_set = {} -- [client_id] = { [bufnr]=true, ... }

		local function ensure_client_tables(client_id)
			client_fifo[client_id] = client_fifo[client_id] or {}
			client_set[client_id] = client_set[client_id] or {}
		end

		local function client_attached_to_buf(client_id, bufnr)
			for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
				if c.id == client_id then
					return true
				end
			end
			return false
		end

		local function prune_dead(client_id)
			local fifo = client_fifo[client_id]
			local set = client_set[client_id]
			if not fifo or not set then
				return
			end
			local i = 1
			while i <= #fifo do
				local b = fifo[i]
				if not client_attached_to_buf(client_id, b) then
					table.remove(fifo, i)
					set[b] = nil
				else
					i = i + 1
				end
			end
			if #fifo == 0 then
				client_fifo[client_id], client_set[client_id] = nil, nil
			end
		end

		local function remove_from_tracking(client_id, bufnr)
			local fifo = client_fifo[client_id]
			local set = client_set[client_id]
			if not fifo or not set or not set[bufnr] then
				return
			end
			set[bufnr] = nil
			for i, b in ipairs(fifo) do
				if b == bufnr then
					table.remove(fifo, i)
					break
				end
			end
			if #fifo == 0 then
				client_fifo[client_id], client_set[client_id] = nil, nil
			end
		end

		-- === Autocommands ===
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
			callback = function(event)
				local bufnr = event.buf
				local client_id = event.data and event.data.client_id
				if not bufnr or not client_id then
					return
				end

				ensure_client_tables(client_id)
				prune_dead(client_id)

				local fifo = client_fifo[client_id]
				local set = client_set[client_id]

				if set[bufnr] then
					for i, b in ipairs(fifo) do
						if b == bufnr then
							table.remove(fifo, i)
							break
						end
					end
					table.insert(fifo, bufnr)
				else
					if #fifo >= MAX_BUFFERS_PER_CLIENT then
						local oldest = table.remove(fifo, 1)
						set[oldest] = nil
						local client = vim.lsp.get_client_by_id(client_id)
						vim.schedule(function()
							vim.lsp.buf_detach_client(oldest, client_id)
							if client then
								vim.notify(
									string.format(
										"LSP '%s': detached oldest buffer #%d to keep max=%d",
										client.name,
										oldest,
										MAX_BUFFERS_PER_CLIENT
									),
									vim.log.levels.WARN
								)
							end
						end)
					end
					table.insert(fifo, bufnr)
					set[bufnr] = true
				end

				setup_lsp_keymaps(event)
			end,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
			callback = function(event)
				local bufnr = event.buf
				local client_id = event.data and event.data.client_id
				if not bufnr or not client_id then
					return
				end
				remove_from_tracking(client_id, bufnr)
			end,
		})

		vim.api.nvim_create_autocmd("BufWipeout", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-bufwipe", { clear = true }),
			callback = function(event)
				local bufnr = event.buf
				for client_id, set in pairs(client_set) do
					if set[bufnr] then
						remove_from_tracking(client_id, bufnr)
					end
				end
			end,
		})

		-- === Capabilities and Servers ===
		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		local servers = {
			html_lsp = {},
			tailwindcss = {},
			elixirls = {
				root_dir = require("lspconfig.util").root_pattern("mix.exs"),
				settings = {
					elixirLS = {
						dialyzerEnabled = false,
						fetchDeps = false,
						enableTestLenses = false,
						suggestSpecs = false,
						mixEnv = "dev",
					},
				},
			},
			lua_ls = {
				settings = {
					Lua = {
						completion = { callSnippet = "Replace" },
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

		local ensure_installed = { "elixirls", "lua_ls", "yaml-language-server", "json-lsp", "tailwindcss" }
		require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					local server = servers[server_name] or {}
					server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
					require("lspconfig")[server_name].setup(server)
				end,
			},
		})

		setup_general_lsp_keymaps()
	end,
}
