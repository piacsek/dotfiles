return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	lazy = false,
	opts = {
		width = 120,
		autocmds = {
			enableOnVimEnter = false,
			skipEnteringNoNeckPainBuffer = true,
		},
		buffers = {
			right = { enabled = false },
			bo = { filetype = "no-neck-pain" },
		},
	},
	config = function(_, opts)
		require("no-neck-pain").setup(opts)

		-- Prevent overseer buffers from opening in NoNeckPain side buffers
		vim.api.nvim_create_autocmd("BufWinEnter", {
			callback = function(args)
				-- Check if this is an overseer task buffer
				if vim.b[args.buf].overseer_task then
					local current_win = vim.api.nvim_get_current_win()
					local buf_ft = vim.bo[args.buf].filetype

					-- Check if we're in a NoNeckPain side buffer
					if buf_ft == "no-neck-pain" or vim.w[current_win].no_neck_pain_side then
						-- Find the main window (not a NoNeckPain side buffer)
						for _, win in ipairs(vim.api.nvim_list_wins()) do
							local win_buf = vim.api.nvim_win_get_buf(win)
							local win_ft = vim.bo[win_buf].filetype
							if win_ft ~= "no-neck-pain" and not vim.w[win].no_neck_pain_side then
								-- Switch to the main window and open the buffer there
								vim.api.nvim_set_current_win(win)
								vim.api.nvim_win_set_buf(win, args.buf)
								return
							end
						end
					end
				end
			end,
		})
	end,
	keys = {
		{ "<leader>z", "<cmd>NoNeckPain<cr>", desc = "Toggle NoNeckPain" },
	},
}
