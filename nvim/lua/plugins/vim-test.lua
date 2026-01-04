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
		{
			"<leader>8",
			function()
				local buffers = vim.fn.getbufinfo({ buflisted = 1 })
				local test_buf = nil

				for _, buf in ipairs(buffers) do
					if buf.variables._test_vim_neovim_sticky == 1 then
						test_buf = buf.bufnr
						break
					end
				end

				if test_buf then
					vim.cmd("buffer " .. test_buf)
				else
					vim.notify("No vim-test terminal found", vim.log.levels.WARN)
				end
			end,
			desc = "Open vim-test terminal",
		},
	},
	config = function()
		vim.g["test#strategy"] = "neovim"
		vim.g["test#preserve_screen"] = 0
		vim.g["test#echo_command"] = 0
		vim.g["test#neovim#term_position"] = "topleft vsplit"
		vim.g["test#neovim_sticky#kill_previous"] = 1
		-- vim.g["test#neovim_sticky#reopen_window"] = 1
	end,
}
