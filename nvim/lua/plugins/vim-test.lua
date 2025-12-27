return {
	"vim-test/vim-test",
	keys = {
		{ "<leader>tt", "<cmd>TestNearest<cr>", desc = "Test nearest" },
		{ "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
		{ "<leader>tl", "<cmd>TestLast<cr>", desc = "Test last" },
	},
	config = function()
		vim.g["test#strategy"] = "neovim"
		vim.g["test#neovim#term_position"] = "topleft vsplit"
	end,
}
