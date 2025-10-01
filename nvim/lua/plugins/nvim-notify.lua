return {
	"rcarriga/nvim-notify",
	config = function()
		local notify = require("notify")
		notify.setup({
			stages = "fade",
			timeout = 3000,
			top_down = false,
			render = "compact",
		})
		vim.notify = notify
	end,
}
