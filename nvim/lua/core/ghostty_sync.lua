-- Sync Ghostty's theme with Neovim's current colorscheme.
-- A Ghostty theme file at ~/.config/ghostty/themes/<name> must exist;
-- if it doesn't, this is a no-op. Theme files are managed in
-- ~/dotfiles/ghostty-themes/ and symlinked into ~/.config/ghostty/themes.
local themes_dir = vim.fn.expand("~/.config/ghostty/themes")
local theme_file = vim.fn.expand("~/.config/ghostty/theme-current")

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ghostty-theme-sync", { clear = true }),
	callback = function(ev)
		if vim.uv.fs_stat(themes_dir .. "/" .. ev.match) == nil then return end
		vim.fn.writefile({ "theme = " .. ev.match }, theme_file)
		vim.system({ "pkill", "-SIGUSR2", "ghostty" }, { detach = true })
	end,
})
