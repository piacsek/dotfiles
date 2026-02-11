return {
	"bluz71/vim-moonfly-colors",
	name = "moonfly",
	lazy = false,
	priority = 1000,
	config = function()
		-- Enable bold fonts in moonfly
		vim.g.moonflyItalics = true
		vim.g.moonflyTransparent = false
	end,
}
