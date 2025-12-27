return {
	"vim-test/vim-test",
	keys = {
		{ "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
		{
			"<leader><tt>",
			function()
				if vim.bo.filetype == "oil" then
					local oil = require("oil")
					local entry = oil.get_cursor_entry()

					if not entry then
						vim.notify("No file under cursor", vim.log.levels.WARN)
						return
					end

					local dir = oil.get_current_dir()
					local filepath = dir .. entry.name
					vim.cmd("TestFile " .. filepath)
				else
					vim.cmd("TestNearest")
				end
			end,
			desc = "Save and run last test",
		},
		{
			"<leader><BS>",
			function()
				if vim.bo.buftype == "" then
					vim.cmd("w")
				end
				vim.cmd("TestLast")
			end,
			desc = "Save and run last test",
		},
	},
	config = function()
		vim.g["test#strategy"] = "neovim_sticky"
		vim.g["test#preserve_screen"] = 0
		vim.g["test#echo_command"] = 0
		vim.g["test#neovim#term_position"] = "topleft vsplit"
		vim.g["test#neovim_sticky#kill_previous"] = 1
		vim.g["test#neovim_sticky#reopen_window"] = 1
	end,
}
