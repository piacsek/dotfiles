return {
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")
		notify.setup({
			stages = "fade",
			timeout = 3000,
			merge_duplicates = true,
			icons = {
				ERROR = "",
				WARN = "",
				INFO = "",
			},
			render = "compact",
		})
		vim.notify = notify
	end,
}
