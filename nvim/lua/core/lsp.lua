local project_elixir_root = nil
local project_tailwind_root = nil
local project_lsp_config = vim.fn.getcwd() .. "/piacsek/lsp.lua"
if vim.fn.filereadable(project_lsp_config) == 1 then
	local ok, config = pcall(dofile, project_lsp_config)
	if ok and type(config) == "table" and config.elixir_root then
		project_elixir_root = config.elixir_root
		project_tailwind_root = config.tailwind_root
	end
end

-- Suppressing formatter errors for files ignored by .formatter.exs(IE: migration files)
local default_show_message = vim.lsp.handlers["window/showMessage"]
vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
	if result and type(result.message) == "string" and result.message:find("not included in") then
		return
	end
	return default_show_message(err, result, ctx, config)
end

vim.lsp.config["elixir_ls"] = {
	cmd = { "elixir-ls" },
	filetypes = { "elixir", "eelixir", "heex" },
	root_dir = function(_, on_dir)
		if vim.g_elixir_root then
			on_dir(project_elixir_root)
		else
			vim.notify("elixir_ls unavailable: Please define elixir_root.", vim.log.levels.ERROR)
		end
	end,
	settings = {
		elixirLS = {
			dialyzerEnabled = false,
			fetchDeps = false,
			enableTestLenses = false,
			suggestSpecs = false,
			mixEnv = "test",
		},
	},
}

local emmet_config = vim.lsp.config["emmet_ls"] or {}
emmet_config.filetypes = vim.list_extend(emmet_config.filetypes or {}, { "heex", "eelixir" })
vim.lsp.config["emmet_ls"] = emmet_config

vim.lsp.config["ts_ls"] = {
	init_options = {
		preferences = {
			importModuleSpecifierPreference = "relative",
		},
	},
	settings = {
		typescript = {
			preferences = {
				importModuleSpecifier = "relative",
			},
		},
		javascript = {
			preferences = {
				importModuleSpecifier = "relative",
			},
		},
	},
}

vim.lsp.enable("lua_ls")
vim.lsp.enable("vimls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("html")
vim.lsp.enable("emmet_ls")
vim.lsp.enable("jsonls")
vim.lsp.enable("yamlls")
vim.lsp.enable("elixir_ls")

-- Tailwind LSP is laggy via vim.lsp.enable, using vim.lsp.start solves the issue
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"html",
		"css",
		"scss",
		"javascriptreact",
		"typescriptreact",
		"svelte",
		"vue",
		"heex",
	},
	callback = function(ev)
		if not project_tailwind_root then
			vim.notify("tailwindlsp unavailable: Please define tailwind_root.", vim.log.levels.ERROR)
			return
		end
		local path = vim.fn.expand(project_tailwind_root)
		path = vim.uv.fs_realpath(path) or path
		vim.lsp.start({
			name = "tailwindcss",
			cmd = { "tailwindcss-language-server", "--stdio" },
			root_dir = path,
		}, { bufnr = ev.buf })
	end,
})
