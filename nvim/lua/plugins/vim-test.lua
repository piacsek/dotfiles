return {
	"vim-test/vim-test",
	keys = {
		{ "<leader>tt", "<cmd>TestNearest<cr>", desc = "Test nearest" },
		{ "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
		{ "<leader>tl", "<cmd>TestLast<cr>", desc = "Test last" },
	},
	config = function()
		vim.g["test#strategy"] = "neovim_sticky"
		vim.g["test#preserve_screen"] = 0
		vim.g["test#echo_command"] = 0
		vim.g["test#neovim#term_position"] = "topleft vsplit"
		vim.g["test#neovim#kill_previous"] = 1
		vim.g["test#neovim#reopen_window"] = 1
	end,
}
