-- Sync Ghostty's theme with Neovim's current colorscheme.
-- Maps nvim colorscheme names to Ghostty theme names (see `ghostty +list-themes`).
-- Add an entry here whenever you adopt a new nvim colorscheme.
-- Theme files live in ~/dotfiles/ghostty-themes/. To add a new mapping,
-- create a matching theme file there, then add a key here.
local nvim_to_ghostty = {
	["high-contrast"] = "high-contrast",
	["cyberdream-light"] = "cyberdream-light",
	blue = "blue",
	cyberdream = "cyberdream",
	darkblue = "darkblue",
	default = "default",
	delek = "delek",
	desert = "desert",
	elflord = "elflord",
	evening = "evening",
	koehler = "koehler",
	lunaperche = "lunaperche",
	oxide = "oxide",
	peachpuff = "peachpuff",
	quiet = "quiet",
	retrobox = "retrobox",
	ron = "ron",
	shine = "shine",
	slate = "slate",
	sorbet = "sorbet",
	torte = "torte",
	zellner = "zellner",
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
