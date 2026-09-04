local project_tailwind_root = nil
local has_project_lsp_config = false
local project_lsp_config = vim.fn.getcwd() .. "/piacsek/lsp.lua"
if vim.fn.filereadable(project_lsp_config) == 1 then
	has_project_lsp_config = true
	local ok, config = pcall(dofile, project_lsp_config)
	if ok and type(config) == "table" and config.tailwind_root then
		project_tailwind_root = config.tailwind_root
	end
end

vim.lsp.config["dexter"] = {
	cmd = { "dexter", "lsp" },
	root_markers = { ".dexter/dexter.db", ".dexter.db", ".git", "mix.exs" },
	filetypes = { "elixir", "eelixir", "heex" },
	init_options = {
		followDelegates = true,
	},
}

vim.lsp.config["emmet_ls"] = {
	filetypes = {
		"astro",
		"css",
		"eelixir",
		"heex",
		"html",
		"htmldjango",
		"javascriptreact",
		"less",
		"pug",
		"sass",
		"scss",
		"svelte",
		"typescriptreact",
		"vue",
	},
}

-- Formatting only for now — strip the completion capability so cmp-nvim-lsp
-- never offers rust-analyzer as a completion source.
vim.lsp.config["rust_analyzer"] = {
	on_attach = function(client)
		client.server_capabilities.completionProvider = nil
	end,
}

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

-- Workaround for nvim 0.12 bug: ColorScheme autocmd asserts on stale LSP
-- client_ids in document_color state, crashing colorscheme switches.
vim.lsp.document_color.enable(false)

vim.lsp.enable({
	"lua_ls",
	"vimls",
	"ts_ls",
	"html",
	"emmet_ls",
	"jsonls",
	"yamlls",
	"dexter",
	"bashls",
	"rust_analyzer",
})

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
			-- No piacsek/lsp.lua at all → project doesn't use tailwind, stay quiet.
			-- One exists but lacks tailwind_root → likely an oversight, nudge once.
			if has_project_lsp_config then
				vim.notify_once("tailwindlsp unavailable: define tailwind_root in piacsek/lsp.lua.", vim.log.levels.WARN)
			end
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
