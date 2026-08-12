-- Statusline. Deliberately sparse: mode, file, diagnostics, position.
--
-- Two diagnostic readouts sit side by side: the buffer's own counts, then the
-- everything-nvim-knows-about counts in brackets. Caveat on the second: it is
-- not a project scan — it's whatever diagnostics are currently published, which
-- for tsserver/eslint means open buffers only. It grows as you visit files.
local severities = {
	{ level = vim.diagnostic.severity.ERROR, label = "E", hl = "DiagnosticError" },
	{ level = vim.diagnostic.severity.WARN, label = "W", hl = "DiagnosticWarn" },
	{ level = vim.diagnostic.severity.INFO, label = "I", hl = "DiagnosticInfo" },
	{ level = vim.diagnostic.severity.HINT, label = "H", hl = "DiagnosticHint" },
}

-- Spinner for the typecheck indicator. lualine's own refresh is a 1s timer, far
-- too slow to animate, so a dedicated 100ms timer runs — but only while a
-- typecheck is in flight, so there is no idle repaint loop.
-- Dense braille: every frame lights 7 of the 8 dots, so the glyph's ink stays
-- constant and only the gap moves. The classic ⠋⠙⠹ set lights 3 dots that hop
-- between the top and bottom rows, which reads as vertical bobbing.
local spinner_chars = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }
local spinner_idx = 1
local spinner_timer

local function spinner_frame()
	return spinner_chars[spinner_idx]
end

local function stop_spinner()
	if spinner_timer then
		spinner_timer:stop()
		spinner_timer:close()
		spinner_timer = nil
	end
end

local function start_spinner(on_tick)
	if spinner_timer then
		return
	end
	spinner_timer = vim.uv.new_timer()
	spinner_timer:start(
		0,
		220, -- ~4.5 fps: reads as "busy" in peripheral vision without pulling the eye
		vim.schedule_wrap(function()
			spinner_idx = spinner_idx % #spinner_chars + 1
			on_tick()
		end)
	)
end

-- nil bufnr = every buffer nvim holds diagnostics for. Returns a table keyed by
-- severity, so one call covers all four counts.
local function workspace_diagnostics()
	local counts = vim.diagnostic.count(nil)
	local parts = {}
	for _, s in ipairs(severities) do
		local n = counts[s.level] or 0
		if n > 0 then
			parts[#parts + 1] = "%#" .. s.hl .. "#" .. s.label .. n
		end
	end
	if #parts == 0 then
		return ""
	end
	-- %* resets to the section's own highlight so the brackets stay neutral.
	return "%*[" .. table.concat(parts, " ") .. "%*]"
end

-- theme = "auto" derives colors from the active colorscheme and re-derives on
-- ColorScheme, so it follows the ghostty-mirror theme switching for free.
require("lualine").setup({
	options = {
		theme = "auto",
		icons_enabled = true,
		component_separators = "",
		section_separators = "",
		globalstatus = true,
		disabled_filetypes = { statusline = { "oil", "aerial", "dap-repl", "trouble" } },
	},
	sections = {
		lualine_a = { "mode" },
		lualine_b = {},
		lualine_c = {
			-- path = 1: relative to cwd. The tail alone is ambiguous in a
			-- monorepo where five apps each have an index.ts.
			{ "filename", path = 1, symbols = { modified = "●", readonly = "", unnamed = "" } },
		},
		lualine_x = {
			-- Visible only while a project typecheck is queued or in flight.
			{
				function()
					local ok, tc = pcall(require, "core.typecheck")
					if not (ok and tc.is_running and tc.is_running()) then
						return ""
					end
					return spinner_frame() .. " tsc"
				end,
			},
			-- This buffer.
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = { error = "E", warn = "W", info = "I", hint = "H" },
			},
			-- Everything else nvim knows about.
			{ workspace_diagnostics },
		},
		lualine_y = {},
		lualine_z = { "location" },
	},
	-- Inactive windows get the filename only; anything more is noise you can't
	-- act on without focusing the window first.
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = { { "filename", path = 1 } },
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
})

-- lualine's own refresh is a 1s timer; without these the counts visibly lag a
-- save-and-lint cycle, and the tsc indicator would appear up to a second late
-- (and linger that long after the run ends).
-- Two autocmds, not one with both events: `pattern` applies to every event in
-- the list, and for DiagnosticChanged it is matched against the file name — so
-- a shared "TypecheckStateChanged" pattern would silently disable the
-- diagnostics refresh.
local lualine_refresh = vim.api.nvim_create_augroup("lualine_refresh", { clear = true })
local function refresh()
	require("lualine").refresh({ place = { "statusline" } })
end
vim.api.nvim_create_autocmd("DiagnosticChanged", { group = lualine_refresh, callback = refresh })
vim.api.nvim_create_autocmd("User", {
	group = lualine_refresh,
	pattern = "TypecheckStateChanged",
	callback = function()
		local ok, tc = pcall(require, "core.typecheck")
		if ok and tc.is_running and tc.is_running() then
			start_spinner(refresh)
		else
			stop_spinner()
		end
		refresh()
	end,
})

-- A live uv timer keeps the loop alive at exit; stop it explicitly.
vim.api.nvim_create_autocmd("VimLeavePre", { group = lualine_refresh, callback = stop_spinner })
