return {
	"f-person/git-blame.nvim",
	config = function()
		require("gitblame").setup({
			date_format = "%r",
		})
	end,
}
