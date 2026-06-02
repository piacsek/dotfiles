vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- Keep &background honest across colorscheme switches, in two beats:
--
--   Pre  — baseline to dark before a scheme loads, so &background-adaptive
--          schemes (e.g. the built-in `default`) don't inherit a stale "light"
--          left by a previous light scheme and render their washed variant.
--   Post — after the scheme settles, set &background to match the actual Normal
--          background luminance. Fixes themes that render light but never set
--          &background themselves (e.g. cyberdream-light), which would otherwise
--          leave &background-aware UI in dark mode over a light background.
--
-- Together: `default` after a light scheme comes back dark, while a genuinely
-- light scheme ends with &background=light to match. ghostty-mirror then mirrors
-- the right variant in both cases.
--
-- Writing &background re-applies the current scheme (and re-fires these events),
-- so every write is wrapped in `adjusting` to prevent the two hooks fighting in
-- an infinite loop, and skipped when already correct.
pcall(vim.api.nvim_del_augroup_by_name, "background-baseline-dark") -- drop the earlier Pre-only version
local bg_group = vim.api.nvim_create_augroup("background-honest", { clear = true })
local bg_adjusting = false

local function set_background(want)
	if vim.o.background ~= want then
		bg_adjusting = true
		vim.o.background = want
		bg_adjusting = false
	end
end

vim.api.nvim_create_autocmd("ColorSchemePre", {
	desc = "Baseline &background to dark so adaptive schemes don't inherit a stale light",
	group = bg_group,
	callback = function()
		if not bg_adjusting then
			set_background("dark")
		end
	end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
	desc = "Sync &background to the loaded scheme's actual Normal background luminance",
	group = bg_group,
	callback = function()
		if bg_adjusting then
			return
		end
		local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
		if type(normal.bg) ~= "number" then
			return
		end
		local r = math.floor(normal.bg / 65536) % 256
		local g = math.floor(normal.bg / 256) % 256
		local b = normal.bg % 256
		local luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255
		set_background(luminance > 0.5 and "light" or "dark")
	end,
})
