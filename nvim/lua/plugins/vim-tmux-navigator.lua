return {
	"christoomey/vim-tmux-navigator",
	lazy = false,
	vim.keymap.set("n", "<M-h>", ":TmuxNavigateLeft<CR>"),
	vim.keymap.set("n", "<M-j>", ":TmuxNavigateDown<CR>"),
	vim.keymap.set("n", "<M-k>", ":TmuxNavigateUp<CR>"),
	vim.keymap.set("n", "<M-l>", ":TmuxNavigateRight<CR>"),
}
