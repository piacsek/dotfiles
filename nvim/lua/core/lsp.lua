vim.lsp.config("elixir_ls", {
	settings = {
		["elixir_ls"] = {
			dialyzerEnabled = false,
			fetchDeps = false,
			enableTestLenses = false,
			suggestSpecs = false,
			mixEnv = "dev",
		},
	},
})
vim.lsp.enable("lua_ls")
vim.lsp.enable("vimls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("html")
vim.lsp.enable("emmet_ls")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("jsonls")
vim.lsp.enable("yamlls")
vim.lsp.enable("elixir_ls")

-- Overriding the ones from https://github.com/neovim/nvim-lspconfig because they open on new tabs
vim.api.nvim_create_user_command("LspInfo", function()
	vim.cmd("vertical checkhealth vim.lsp")
end, { desc = "Show LSP health check" })

vim.api.nvim_create_user_command("LspLogs", function()
	vim.cmd.edit(vim.lsp.get_log_path())
end, { desc = "Show LSP health check" })
