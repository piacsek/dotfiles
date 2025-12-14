vim.lsp.config["elixir_ls"] = {
	cmd = { "elixir-ls" },
	filetypes = { "elixir", "eelixir", "heex", "surface" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local matches = vim.fs.find({ "mix.exs" }, { upward = true, limit = 2, path = fname })
		local child_or_root_path, maybe_umbrella_path = unpack(matches)
		local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

		on_dir(root_dir)
	end,
	settings = {
		dialyzerEnabled = false,
		fetchDeps = false,
		enableTestLenses = false,
		suggestSpecs = false,
		mixEnv = "dev",
	},
}

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
vim.api.nvim_create_user_command("LspInfo", "vertical checkhealth vim.lsp", { desc = "Show LSP health check" })

vim.api.nvim_create_user_command("LspLogs", function()
	vim.cmd.edit(vim.lsp.get_log_path())
end, { desc = "Show LSP health check" })
