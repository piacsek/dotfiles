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

		vim.keymap.set("n", "<leader>ml", function()
			local history = notify.history()
			if #history > 0 then
				local last = history[#history]
				notify.notify(last.message, last.level)
			end
		end, { desc = "Show last notification" })
	end,
}
