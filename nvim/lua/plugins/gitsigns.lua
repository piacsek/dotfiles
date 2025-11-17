return {
	"lewis6991/gitsigns.nvim",
	opts = {
		signs = {
			add = { text = "+" },
			change = { text = "~" },
			delete = { text = "_" },
			topdelete = { text = "‾" },
			changedelete = { text = "~" },
		},
		current_line_blame = true,
		current_line_blame_opts = {
			delay = 100,
			virt_text = true,
			virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
		},
		on_attach = function(bufnr)
			vim.keymap.set(
				"n",
				"<leader>u",
				"<cmd>Gitsigns reset_hunk<CR>",
				{ desc = "Reset git hunk", buffer = bufnr }
			)
			vim.keymap.set(
				"n",
				"<leader>gl",
				"<cmd>Telescope git_bcommits<CR>",
				{ desc = "[G]it [L]og for current file", buffer = bufnr }
			)
		end,
	},
}
