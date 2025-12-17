return {
	"f-person/git-blame.nvim",
	enabled = false,
	config = function()
		require("gitblame").setup({
			date_format = "%r",
			delay = 0,
		})
	end,
}

