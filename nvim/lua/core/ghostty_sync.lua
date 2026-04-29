-- Sync between Neovim's colorscheme and Ghostty's theme.
--
-- ColorScheme autocmd writes the chosen theme to ~/.config/ghostty/theme-current
-- and signals Ghostty to reload. Run :ThemeFromGhostty in any other nvim
-- instance to pull the current theme from that file.
local themes_dir = vim.fn.expand("~/.config/ghostty/themes")
local theme_file = vim.fn.expand("~/.config/ghostty/theme-current")

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ghostty-theme-sync", { clear = true }),
	callback = function(ev)
		-- cyberdream and similar set the same g:colors_name for both light and
		-- dark variants. Prefer "<name>-light" when &background=light.
		local name = ev.match
		if vim.o.background == "light" and vim.uv.fs_stat(themes_dir .. "/" .. name .. "-light") then
			name = name .. "-light"
		end
		if vim.uv.fs_stat(themes_dir .. "/" .. name) == nil then return end
		vim.fn.writefile({ "theme = " .. name }, theme_file)
		vim.system({ "pkill", "-SIGUSR2", "ghostty" }, { detach = true })
	end,
})

vim.api.nvim_create_user_command("ThemeFromGhostty", function()
	local lines = vim.fn.readfile(theme_file)
	local theme = lines[1] and lines[1]:match("theme%s*=%s*(%S+)")
	if not theme then
		vim.notify("ThemeFromGhostty: could not read theme from " .. theme_file, vim.log.levels.WARN)
		return
	end
	vim.cmd.colorscheme(theme)
end, { desc = "Apply the colorscheme currently set in Ghostty's theme-current" })

vim.keymap.set("n", "<M-t>", "<cmd>ThemeFromGhostty<cr>", { desc = "Sync colorscheme from Ghostty" })
