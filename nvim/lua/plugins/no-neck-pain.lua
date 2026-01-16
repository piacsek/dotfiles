return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	config = function()
		require("no-neck-pain").setup({
			width = 120,
			autocmds = {
				enableOnVimEnter = true,
			},
			buffers = {
				right = {
					enabled = false,
				},
				wo = {
					fillchars = "eob: ",
				},
				bo = {
					filetype = "no-neck-pain",
				},
			},
			integrations = {
				fzf = {
					enable = true,
				},
			},
		})
	end,
}
