return {
	"rcarriga/nvim-notify",
	enabled = false,
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
