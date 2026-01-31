return {
	"christoomey/vim-tmux-navigator",
	lazy = false,
	vim.keymap.set("n", "<M-h>", "<C-w>h", { desc = "Go to the buffer on the left" }),
	vim.keymap.set("n", "<M-j>", "<C-w>j", { desc = "Go to the buffer on the bottom" }),
	vim.keymap.set("n", "<M-k>", "<C-w>k", { desc = "Go to the buffer on the top" }),
	vim.keymap.set("n", "<M-l>", "<C-w>l", { desc = "Go to the buffer on the right" }),
}
