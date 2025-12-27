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
		current_line_blame = false,
		auto_attach = true,
		current_line_blame_opts = {
			delay = 0,
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
				"<leader>gb",
				"<cmd>Gitsigns toggle_current_line_blame<CR>",
				{ desc = "[G]it [B]lame toggle", buffer = bufnr }
			)
			vim.keymap.set(
				"n",
				"{",
				"<cmd>Gitsigns nav_hunk prev<CR>",
				{ desc = "Go to previous git hunk", buffer = bufnr }
			)
			vim.keymap.set(
				"n",
				"}",
				"<cmd>Gitsigns nav_hunk next<CR>",
				{ desc = "Go to next git hunk", buffer = bufnr }
			)
		end,
	},
}
