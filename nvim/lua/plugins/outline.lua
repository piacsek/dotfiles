return {
	"hedyhli/outline.nvim",
	config = function()
		require("outline").setup({
			outline_items = {
				show_symbol_details = true,
				show_symbol_lineno = true,
			},
			symbol_folding = {
				autofold_depth = nil,
				auto_unfold = {
					hovered = true,
				},
			},
			keymaps = {
				fold_toggle = "f",
			},
		})
	end,
	keys = {
		{ "<leader>s", ":Outline<cr>", desc = "Toggle Outline" },
	},
}
