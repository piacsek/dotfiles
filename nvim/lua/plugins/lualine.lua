-- Statusline. Deliberately sparse: mode, file, diagnostics, position.
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
			{
				"diagnostics",
				sources = { "nvim_diagnostic" },
				symbols = { error = "E", warn = "W", info = "I", hint = "H" },
			},
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
