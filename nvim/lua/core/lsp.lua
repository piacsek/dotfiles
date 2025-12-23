-- Cache for elixir-ls root directory lookups to avoid expensive filesystem searches
local elixir_root_cache = {}

-- For some reason, elixir_ls's config is not picked up from nvim-lspconfig
vim.lsp.config["elixir_ls"] = {
	cmd = { "elixir-ls" },
	filetypes = { "elixir", "eelixir", "heex", "surface" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)

		-- Check cache first to avoid filesystem search
		if elixir_root_cache[fname] then
			vim.notify("🎯 Cache hit (file): " .. vim.fn.fnamemodify(fname, ":t"), vim.log.levels.INFO)
			on_dir(elixir_root_cache[fname])
			return
		end

		-- Also check if parent directory is cached
		local parent_dir = vim.fn.fnamemodify(fname, ":h")
		if elixir_root_cache[parent_dir] then
			vim.notify("🎯 Cache hit (dir): " .. vim.fn.fnamemodify(parent_dir, ":t"), vim.log.levels.INFO)
			elixir_root_cache[fname] = elixir_root_cache[parent_dir]
			on_dir(elixir_root_cache[parent_dir])
			return
		end

		-- Perform filesystem search with safeguards
		vim.notify("🔍 Searching filesystem for mix.exs...", vim.log.levels.WARN)
		local matches = vim.fs.find({ "mix.exs" }, {
			upward = true,
			limit = 2,
			path = fname,
			stop = vim.env.HOME, -- Don't search above home directory
		})

		local child_or_root_path, maybe_umbrella_path = unpack(matches)
		local root_dir = vim.fs.dirname(maybe_umbrella_path or child_or_root_path)

		-- Cache the result for this file and its parent directory
		if root_dir then
			elixir_root_cache[fname] = root_dir
			elixir_root_cache[parent_dir] = root_dir
			vim.notify("💾 Cached root: " .. vim.fn.fnamemodify(root_dir, ":t"), vim.log.levels.INFO)
		end

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

-- Overriding the ones from https://github.com/neovim/nvim-lspconfig because they open on new tabs
vim.api.nvim_create_user_command("LspInfo", "vertical checkhealth vim.lsp", { desc = "Show LSP health check" })

vim.api.nvim_create_user_command("LspLogs", function()
	vim.cmd.edit(vim.lsp.get_log_path())
end, { desc = "Show LSP health check" })
