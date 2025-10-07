vim.api.nvim_create_augroup("autoread", { clear = true })
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
	group = "autoread",
	command = "checktime",
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",
	callback = function()
		for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
			vim.keymap.set("i", key, "<Nop>", { buffer = true })
		end
	end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "no-neck-pain",
	callback = function()
		vim.opt_local.fillchars = { eob = " ", vert = " " }
		vim.opt_local.winhighlight = "EndOfBuffer:Normal,VertSplit:Normal"
	end,
})

vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local ns = vim.api.nvim_create_namespace("file_path_highlight")

		-- Define highlight group for file paths
		vim.api.nvim_set_hl(0, "TermFilePath", { bold = true, underline = true })

		-- Create autocmd to highlight paths whenever terminal updates
		vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI", "TermEnter" }, {
			buffer = buf,
			callback = function()
				vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
				local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

				for i, line in ipairs(lines) do
					-- Match file paths like lib/my/file.ex or src/foo/bar.rb
					for match in line:gmatch("[%w_%-%.]+/[%w_%-%.%/]+%.%w+") do
						local start_col = line:find(match, 1, true)
						if start_col then
							vim.api.nvim_buf_add_highlight(buf, ns, "TermFilePath", i - 1, start_col - 1, start_col - 1 + #match)
						end
					end
				end
			end,
		})
	end,
})