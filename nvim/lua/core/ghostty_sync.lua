-- Sync Ghostty's theme with Neovim's current colorscheme.
-- A Ghostty theme file at ~/.config/ghostty/themes/<name> must exist;
-- if it doesn't, this is a no-op. Theme files are managed in
-- ~/dotfiles/ghostty-themes/ and symlinked into ~/.config/ghostty/themes.
local themes_dir = vim.fn.expand("~/.config/ghostty/themes")
local theme_file = vim.fn.expand("~/.config/ghostty/theme-current")

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ghostty-theme-sync", { clear = true }),
	callback = function(ev)
		-- Some plugins (e.g. cyberdream) set the same g:colors_name for both
		-- light and dark variants. Prefer "<name>-light" when &background=light.
		local name = ev.match
		if vim.o.background == "light" and vim.uv.fs_stat(themes_dir .. "/" .. name .. "-light") then
			name = name .. "-light"
		end
		if vim.uv.fs_stat(themes_dir .. "/" .. name) == nil then return end
		vim.fn.writefile({ "theme = " .. name }, theme_file)
		vim.system({ "pkill", "-SIGUSR2", "ghostty" }, { detach = true })
		vim.notify("ghostty: " .. name)
	end,
})
