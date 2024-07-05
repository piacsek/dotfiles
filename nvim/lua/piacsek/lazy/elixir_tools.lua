return {
	"elixir-tools/elixir-tools.nvim",
	version = "*",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local elixir = require("elixir")

		elixir.setup({
			nextls = { enable = true },
			credo = { enable = false },
			elixirls = { enable = false, autostart = false },
		})
	end,
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
}
