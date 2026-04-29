-- Two-way sync between Neovim's colorscheme and Ghostty's theme.
--
-- ColorScheme autocmd writes the chosen theme to ~/.config/ghostty/theme-current
-- and signals Ghostty to reload. A file watcher on the same file picks up
-- changes made by other Neovim instances and applies the colorscheme locally,
-- so swapping themes in one nvim propagates to every nvim across tmux/Ghostty.
local themes_dir = vim.fn.expand("~/.config/ghostty/themes")
local theme_file = vim.fn.expand("~/.config/ghostty/theme-current")

local last_synced
local applying_from_file = false

local function read_theme()
	local lines = vim.fn.readfile(theme_file)
	return lines[1] and lines[1]:match("theme%s*=%s*(%S+)") or nil
end

vim.api.nvim_create_autocmd("ColorScheme", {
	group = vim.api.nvim_create_augroup("ghostty-theme-sync", { clear = true }),
	callback = function(ev)
		if applying_from_file then return end
		-- cyberdream and similar set the same g:colors_name for both light and
		-- dark variants. Prefer "<name>-light" when &background=light.
		local name = ev.match
		if vim.o.background == "light" and vim.uv.fs_stat(themes_dir .. "/" .. name .. "-light") then
			name = name .. "-light"
		end
		if vim.uv.fs_stat(themes_dir .. "/" .. name) == nil then return end
		if name == last_synced then return end
		last_synced = name
		vim.fn.writefile({ "theme = " .. name }, theme_file)
		vim.system({ "pkill", "-SIGUSR2", "ghostty" }, { detach = true })
	end,
})

local watcher = vim.uv.new_fs_event()
watcher:start(theme_file, {}, vim.schedule_wrap(function(err)
	if err then return end
	local theme = read_theme()
	if not theme or theme == last_synced then return end
	last_synced = theme
	applying_from_file = true
	pcall(vim.cmd.colorscheme, theme)
	applying_from_file = false
end))
