return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {
		keymaps = {
			["<leader>tt"] = {
				callback = function()
					local oil = require("oil")
					local dir = oil.get_current_dir()

					local entries = oil.get_selected_entries()
					if not entries or #entries == 0 then
						local entry = oil.get_cursor_entry()
						if entry then
							entries = { entry }
						end
					end

					local test_files = {}
					for _, entry in ipairs(entries) do
						local filepath = dir .. entry.name
						table.insert(test_files, filepath)
					end

					if #test_files == 0 then
						vim.notify("No test files selected", vim.log.levels.WARN)
						return
					end

					vim.cmd("TestSuite " .. table.concat(test_files, " "))
				end,
				desc = "Run test file(s) under cursor/selection",
			},
		},
	},
	dependencies = { { "echasnovski/mini.icons", opts = {} } },
	-- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
	lazy = false,
}
