return {
	"vim-test/vim-test",
	keys = {
		{ "<leader>tt", "<cmd>TestNearest<cr>", desc = "Test nearest" },
		{ "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
		{
			"<leader>td",
			function()
				local dir = vim.fn.expand("%:p:h")
				vim.cmd("TestSuite " .. vim.fn.fnameescape(dir))
			end,
			desc = "Test suite in current directory",
		},
		{
			"<leader><BS>",
			function()
				if vim.bo.buftype == "" then
					vim.cmd("wall")
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
		-- vim.g["test#neovim_sticky#reopen_window"] = 1
	end,
}
