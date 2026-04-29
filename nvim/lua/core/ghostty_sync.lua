-- Sync Ghostty's theme with Neovim's current colorscheme.
-- Maps nvim colorscheme names to Ghostty theme names (see `ghostty +list-themes`).
-- Add an entry here whenever you adopt a new nvim colorscheme.
local nvim_to_ghostty = {
	["high-contrast"] = "high-contrast",
	elflord = "elflord",
	ron = "ron",
}

local theme_file = vim.fn.expand("~/.config/ghostty/theme-current")

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ghostty-theme-sync", { clear = true }),
	callback = function(ev)
		local theme = nvim_to_ghostty[ev.match]
		if not theme then return end
		vim.fn.writefile({ "theme = " .. theme }, theme_file)
		vim.system({ "pkill", "-SIGUSR2", "ghostty" }, { detach = true })
	end,
})
