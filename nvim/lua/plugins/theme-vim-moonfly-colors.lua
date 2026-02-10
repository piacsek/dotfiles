return {
	"bluz71/vim-moonfly-colors",
	name = "moonfly",
	lazy = false,
	priority = 1000,
	config = function()
		vim.api.nvim_create_autocmd("ColorScheme", {
			pattern = "moonfly",
			callback = function()
				-- Customize Elixir module colors to cyan
				-- local cyan = "#37cccc" -- moonfly's cyan color
				--
				-- vim.api.nvim_set_hl(0, "@module.elixir", { fg = cyan })
				-- vim.api.nvim_set_hl(0, "@lsp.type.namespace.elixir", { fg = cyan })
				-- vim.api.nvim_set_hl(0, "@type.elixir", { fg = cyan })
			end,
		})
	end,
}
