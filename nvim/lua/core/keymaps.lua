local arrow_disabling_opts = { noremap = true, silent = true }
vim.keymap.set({ "n", "i", "v", "c" }, "<Up>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Down>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Left>", "<Nop>", arrow_disabling_opts)
vim.keymap.set({ "n", "i", "v", "c" }, "<Right>", "<Nop>", arrow_disabling_opts)
vim.keymap.set("n", "<leader>Y", function()
	vim.fn.setreg('"', vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:."))
end, { desc = "Yank current file path" })

vim.keymap.set("n", "<C-g>", "#*viw", { desc = "Multiple cursor replacement" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Remove search results highlights" })

vim.keymap.set("n", "<leader><Esc>", ":hide<CR>", { desc = "Hide window" })
vim.keymap.set("n", "Y", "y$", { desc = "[Y]ank till the end of the line" })
vim.keymap.set("n", "V", "v$", { desc = "[V]isually select till the end of the line" })
vim.keymap.set("n", "<leader>vp", vim.cmd.Ex, { desc = "Hide window" })

vim.keymap.set("n", "Q", "<nop>", { desc = "Avoiding Q" })

-- Quickfix
vim.keymap.set("n", "<leader>jq", ":copen<CR>", { desc = "[J]ump to the quickfix list" })
vim.keymap.set("n", "<M-n>", ":cnext<CR>", { desc = "Go to the [n]ext item in the quickfix list" })
vim.keymap.set("n", "<M-p>", ":cprev<CR>", { desc = "Go to the [p]revious item in the quickfix list" })

vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Go to the buffer on the left" })
vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Go to the buffer on the bottom" })
vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Go to the buffer on the top" })
vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Go to the buffer on the right" })

vim.keymap.set("x", "<leader>p", [["_dP]], { desc = 'Pastes content without losing current "0 contents' })

vim.keymap.set("n", "[", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
vim.keymap.set("n", "]", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
vim.keymap.set("n", "{", function()
	require("gitsigns").prev_hunk()
end, { desc = "Go to previous git hunk" })
vim.keymap.set("n", "}", function()
	require("gitsigns").next_hunk()
end, { desc = "Go to next git hunk" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "[Y]ank to system clipboard" })
vim.keymap.set({ "n", "v" }, "<C-s>", ":w<CR>", { desc = "[S]ave" })

vim.keymap.set("n", "<C-.>", ":horizontal resize +5<CR>", { desc = "Increase window horizontal size" })
vim.keymap.set("n", "<C-,>", ":horizontal resize -5<CR>", { desc = "Decrease window horizontal size" })

vim.keymap.set("n", ">", ":vertical resize +5<CR>", { desc = "Increase window vertical size" })
vim.keymap.set("n", "<", ":vertical resize -5<CR>", { desc = "Decrease window vertical size" })

vim.keymap.set("v", "<leader>s", '"sy:%s/<C-r>s/', { desc = "[S]ubstitute selected word" })

vim.keymap.set("t", "<C-o>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<leader>o", function()
	require("oil").open_float()
end, { desc = "[J]ump to [O]il" })

vim.keymap.set("n", "<leader>js", ":term<CR>", { desc = "[J]ump to [O]il" })
vim.keymap.set("n", "<leader>fs", ":ScratchOpen<CR>", { desc = "[F]ump to [S]cratch" })
vim.keymap.set("n", "<leader>n", ":Scratch<CR>", { desc = "[N]ew scrach" })

vim.keymap.set("n", "<leader><Del>", ":BufOnly<CR>", { desc = "[T]est [S]ummary" })
vim.keymap.set("n", "<leader>i", ":Inspect<CR>", { desc = "[I]nspect" })
vim.keymap.set("i", "<C-p>", function()
	vim.cmd.normal("p")
end, { desc = "[P]aste in insert mode" })

vim.keymap.set("n", "<leader><BS>", function()
	vim.cmd("w")
	vim.cmd("colorscheme high-contrast")
end, { desc = "Save file & re-apply colorscheme" })

vim.keymap.set("n", "g<Enter>", "gF", { desc = "Go to file with line number support" })
vim.keymap.set("n", "<leader>gd", function()
	require("gitsigns").diffthis("origin/main")
end, { desc = "[G]it [D]iff against origin/main in floating window" })
