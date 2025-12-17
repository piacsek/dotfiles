return {
	"sontungexpt/url-open",
	branch = "mini",
	event = "VeryLazy",
	cmd = "URLOpenUnderCursor",
	config = function()
		local status_ok, url_open = pcall(require, "url-open")
		if not status_ok then
			return
		end
		url_open.setup({
			highlight_url = {
				cursor_move = {
					enabled = false, -- Don't highlight on every cursor move
				},
			},
		})
	end,
	keys = {
		{ "<leader>jw", "<esc>:URLOpenUnderCursor<cr>", desc = "[J]ump to [W]eb browser" },
	},
}
