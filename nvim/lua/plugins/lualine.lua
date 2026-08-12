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

-- lualine's own refresh is a 1s timer; without this the counts visibly lag a
-- save-and-lint cycle.
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	group = vim.api.nvim_create_augroup("lualine_diagnostics_refresh", { clear = true }),
	callback = function()
		require("lualine").refresh({ place = { "statusline" } })
	end,
})
