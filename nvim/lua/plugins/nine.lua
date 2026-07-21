-- ThePrimeagen/99: AI client for Neovim (search / visual / vibe / work).
-- The whole <leader>9… namespace belongs to this plugin; harpoon's single-digit
-- select loop was trimmed to 1..8 (see core/keymaps.lua) to free <leader>9.
local _99 = require("99")

local cwd = vim.uv.cwd()
local basename = vim.fs.basename(cwd)

_99.setup({
	-- claude CLI is what I live in; opencode is the plugin default. Switch on the
	-- fly with <leader>9p (provider picker) — that also resets model to the
	-- provider default.
	provider = _99.Providers.ClaudeCodeProvider,

	-- File log for tracing a request when reporting a bug. Prefer :lua
	-- require("99").view_logs() for normal debugging.
	logger = {
		level = _99.DEBUG,
		path = "/tmp/" .. basename .. ".99.debug",
		print_on_error = true,
	},

	-- Must live inside cwd or the provider CLI hits permission errors.
	tmp_dir = "./tmp",

	completion = {
		-- I use nvim-cmp, so #rules / @files complete through it.
		source = "cmp",
	},

	-- Auto-inject AGENT.md walking up from the request's file to project root.
	md_files = { "AGENT.md" },
})

-- Visual mode only, on purpose: sends the *current* selection + prompt and
-- replaces it with the result. Keeping it v-mode avoids reusing a stale
-- last-visual selection.
vim.keymap.set("v", "<leader>9v", function()
	_99.visual({})
end, { desc = "99: rewrite visual selection" })

vim.keymap.set("n", "<leader>9s", function()
	_99.search({})
end, { desc = "99: search project -> quickfix" })

vim.keymap.set("n", "<leader>9o", function()
	_99.open()
end, { desc = "99: open last interaction" })

vim.keymap.set("n", "<leader>9x", function()
	_99.stop_all_requests()
end, { desc = "99: stop all in-flight requests" })

vim.keymap.set("n", "<leader>9c", function()
	_99.clear_previous_requests()
end, { desc = "99: clear previous search/visual results" })

vim.keymap.set("n", "<leader>9l", function()
	_99.view_logs()
end, { desc = "99: view logs" })

-- fzf-lua pickers (I don't run telescope).
vim.keymap.set("n", "<leader>9m", function()
	require("99.extensions.fzf_lua").select_model()
end, { desc = "99: select model" })

vim.keymap.set("n", "<leader>9p", function()
	require("99.extensions.fzf_lua").select_provider()
end, { desc = "99: select provider" })
