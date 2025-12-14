-- Configs available at:
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/

vim.lsp.config["lua_ls"] = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".emmyrc.json",
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
	settings = {
		Lua = {
			codeLens = { enable = true },
			hint = { enable = true, semicolon = "Disable" },
		},
	},
}

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
