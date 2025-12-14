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
	opts = {
		events = {
			render_buffer = {},
			clear_buffer = { "BufLeave" },
		},
	},
	config = function()
		require("diagram").setup({
			integrations = {
				require("diagram.integrations.markdown"),
			},
			renderer_options = {
				mermaid = { theme = "dark", scale = 8 },
			},
		})
	end,
	keys = {
		{
			"H",
			function()
				require("diagram").show_diagram_hover()
			end,
			mode = "n",
			ft = { "markdown", "norg" },
			desc = "Show diagram in new tab",
		},
	},
}
