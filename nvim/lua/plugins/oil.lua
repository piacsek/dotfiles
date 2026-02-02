return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		view_options = { show_hidden = true },
		keymaps = {
			["<CR>"] = { "actions.select" },
			["-"] = { "actions.parent", mode = "n" },
			["_"] = { "actions.open_cwd", mode = "n" },
			["<leader>tt"] = {
				callback = function()
					local oil = require("oil")
					local entry = oil.get_cursor_entry()

					if not entry then
						vim.notify("No file under cursor", vim.log.levels.WARN)
						return
					end

					local dir = oil.get_current_dir()
					local filepath = dir .. entry.name

					vim.cmd("TestSuite " .. filepath)
				end,
				desc = "Run test file under cursor",
			},
		},
		use_default_keymaps = false,
	},
	keys = {
		{ "<leader>o", ":Oil<CR>", mode = "n", desc = "Open Oil" },
	},
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
}
