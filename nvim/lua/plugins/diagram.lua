return {
	"3rd/diagram.nvim",
	dependencies = {
		{
			"3rd/image.nvim",
			build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
			opts = {
				processor = "magick_cli",
			},
		},
	},
	opts = {},
	config = function()
		require("diagram").setup({
			integrations = {
				require("diagram.integrations.markdown"),
			},
			renderer_options = {
				mermaid = { theme = "forest" },
			},
		})
	end,
}
