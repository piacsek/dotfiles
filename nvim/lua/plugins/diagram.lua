return {
	"3rd/diagram.nvim",
	dependencies = {
		{ "3rd/image.nvim", opts = {} }, -- you'd probably want to configure image.nvim manually instead of doing this
	},
	opts = {},
	config = function()
		require("diagram").setup({
			integrations = {
				require("diagram.integrations.markdown"),
				require("diagram.integrations.neorg"),
			},
			renderer_options = {
				mermaid = {
					theme = "forest",
				},
			},
		})
	end,
}
