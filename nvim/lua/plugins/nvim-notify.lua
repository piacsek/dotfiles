return {
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")
		notify.setup({
			stages = "fade",
			timeout = 3000,
			top_down = false,
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
