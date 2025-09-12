return {
	"nvim-tree/nvim-tree.lua",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		vim.g.loaded_netrw = 1
		vim.g.loaded_netrwPlugin = 1

		local function on_attach_mappings(bufnr)
			local api = require("nvim-tree.api")

			local function opts(desc)
				return {
					desc = "nvim-tree: " .. desc,
					buffer = bufnr,
					noremap = true,
					silent = true,
					nowait = true,
				}
			end

			-- Keep default mappings
			api.config.mappings.default_on_attach(bufnr)

			-- Remove tab mapping(to avoid messing w/ my navigation) and add space for preview
			vim.keymap.del("n", "<Tab>", { buffer = bufnr })
			vim.keymap.del("n", ">", { buffer = bufnr })
			vim.keymap.del("n", "<", { buffer = bufnr })
			vim.keymap.set("n", "p", api.node.open.preview, opts("[P]review"))
		end

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
			update_focused_file = {
				enable = true,
				update_root = false,
			},
			on_attach = on_attach_mappings,
		})

		vim.keymap.set("n", "<leader>1", ":NvimTreeFocus<CR>", { desc = "Focus on file explorer" })
		vim.keymap.set("n", "<leader>jp", ":NvimTreeFocus<CR>", { desc = "[J]ump to [P]roject files(IntelliJ legacy)" })
	end,
}
