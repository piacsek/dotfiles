return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		require("nvim-tree").setup({
			sort_by = "case_sensitive",
			view = {
				width = 30,
				side = "left",
			},
			renderer = {
				group_empty = true,
				highlight_git = true,
				icons = {
					show = {
						file = true,
						folder = true,
						folder_arrow = true,
						git = true,
					},
				},
			},
			filters = {
				dotfiles = false,
			},
			git = {
				enable = true,
				ignore = false,
			},
			actions = {
				open_file = {
					quit_on_open = false,
				},
			},
		})

		vim.keymap.set("n", "<leader>1", ":NvimTreeFocus<CR>", { desc = "Focus on file explorer" })
		vim.keymap.set(
			"n",
			"<leader>jp",
			":NvimTreeFindFile<CR>",
			{ desc = "[J]ump to [P]roject files(IntelliJ legacy)" }
		)
	end,
}
