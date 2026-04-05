local project_elixir_root = nil
local project_lsp_config = vim.fn.getcwd() .. "/piacsek/lsp.lua"
if vim.fn.filereadable(project_lsp_config) == 1 then
	local ok, config = pcall(dofile, project_lsp_config)
	if ok and type(config) == "table" and config.elixir_root then
		project_elixir_root = config.elixir_root
	end
end

vim.lsp.config["elixir_ls"] = {
	cmd = { "elixir-ls" },
	filetypes = { "elixir", "eelixir", "heex", "surface" },
	root_dir = function(_, on_dir)
		if project_elixir_root then
			on_dir(project_elixir_root)
		else
			vim.notify("elixir_ls unavailable: Please define elixir_root.")
		end
	end,
	settings = {
		elixirLS = {
			dialyzerEnabled = false,
			fetchDeps = false,
			enableTestLenses = false,
			suggestSpecs = false,
			mixEnv = "dev",
		},
	},
}
--
-- local emmet_config = vim.lsp.config["emmet_ls"] or {}
-- emmet_config.filetypes = vim.list_extend(emmet_config.filetypes or {}, { "heex", "eelixir" })
-- vim.lsp.config["emmet_ls"] = emmet_config
--
-- vim.lsp.enable("lua_ls")
-- vim.lsp.enable("vimls")
-- vim.lsp.enable("ts_ls")
-- vim.lsp.enable("html")
-- vim.lsp.enable("emmet_ls")
-- vim.lsp.enable("tailwindcss")
-- vim.lsp.enable("jsonls")
-- vim.lsp.enable("yamlls")
vim.lsp.enable("elixir_ls")
