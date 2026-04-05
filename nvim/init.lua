-- Enable bytecode cache for faster Lua module loading
vim.loader.enable()

require("core.options")
require("core.commands")
require("core.auto_commands")
require("core.plugins")
require("core.keymaps")

-- --------------------------------------------------- <KEYMAPS> ---------------------------------------------------
-- Helper fns

-- -------------------------------------------------- </KEYMAPS> ---------------------------------------------------
-- ----------------------------------------------------- <LSP> -----------------------------------------------------

-- Cache for elixir-ls root directory lookups to avoid expensive filesystem searches
local elixir_root_cache = {}

-- Load project-specific elixir root if configured
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
	root_dir = function(bufnr, on_dir)
		if project_elixir_root then
			on_dir(project_elixir_root)
			return
		end

		local fname = vim.api.nvim_buf_get_name(bufnr)

		if elixir_root_cache[fname] then
			on_dir(elixir_root_cache[fname])
			return
		end

		local parent_dir = vim.fn.fnamemodify(fname, ":h")
		if elixir_root_cache[parent_dir] then
			elixir_root_cache[fname] = elixir_root_cache[parent_dir]
			on_dir(elixir_root_cache[parent_dir])
			return
		end

		local matches = vim.fs.find({ "mix.exs" }, {
			upward = true,
			limit = 2,
			path = fname,
			stop = vim.env.HOME,
		})

		local child_or_root_path, maybe_umbrella_path = unpack(matches)
		local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

		if root_dir then
			elixir_root_cache[fname] = root_dir
			elixir_root_cache[parent_dir] = root_dir
		end

		on_dir(root_dir)
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

local emmet_config = vim.lsp.config["emmet_ls"] or {}
emmet_config.filetypes = vim.list_extend(emmet_config.filetypes or {}, { "heex", "eelixir" })
vim.lsp.config["emmet_ls"] = emmet_config

vim.lsp.enable("lua_ls")
vim.lsp.enable("vimls")
vim.lsp.enable("ts_ls")
vim.lsp.enable("html")
vim.lsp.enable("emmet_ls")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("jsonls")
vim.lsp.enable("yamlls")
vim.lsp.enable("elixir_ls")

-- ----------------------------------------------------- </LSP> -----------------------------------------------------

-- Config overrides
local home_init = vim.fn.expand("$HOME/init.lua")
if vim.fn.filereadable(home_init) == 1 then
	dofile(home_init)
end

local local_init = vim.fn.getcwd() .. "/piacsek/init.lua"
if vim.fn.filereadable(local_init) == 1 then
	dofile(local_init)
end
