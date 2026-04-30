local function tone_down_zaibatsu()
	vim.api.nvim_set_hl(0, "StatusLine", { fg = "#e8e6ec", bg = "#3a1e6e" })
	vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#a39bb0", bg = "#2a1450" })
	-- Floats (LSP hover, diagnostics, plugin popups, snacks, etc.)
	vim.api.nvim_set_hl(0, "NormalFloat", { fg = "#d7d5db", bg = "#1a0540" })
	vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#878092", bg = "#1a0540" })
	vim.api.nvim_set_hl(0, "FloatTitle", { fg = "#ffd700", bg = "#1a0540", bold = true })
	-- Completion popup (LSP, nvim-cmp, blink)
	vim.api.nvim_set_hl(0, "Pmenu", { fg = "#d7d5db", bg = "#1a0540" })
	vim.api.nvim_set_hl(0, "PmenuSel", { fg = "#ffd700", bg = "#3a1e6e", bold = true })
	vim.api.nvim_set_hl(0, "PmenuKind", { fg = "#878092", bg = "#1a0540" })
	vim.api.nvim_set_hl(0, "PmenuKindSel", { fg = "#878092", bg = "#3a1e6e" })
	vim.api.nvim_set_hl(0, "PmenuExtra", { fg = "#878092", bg = "#1a0540" })
	vim.api.nvim_set_hl(0, "PmenuExtraSel", { fg = "#878092", bg = "#3a1e6e" })
	vim.api.nvim_set_hl(0, "PmenuMatch", { fg = "#ff87ff", bg = "#1a0540", bold = true })
	vim.api.nvim_set_hl(0, "PmenuMatchSel", { fg = "#ff87ff", bg = "#3a1e6e", bold = true })
	vim.api.nvim_set_hl(0, "PmenuSbar", { bg = "#2a1450" })
	vim.api.nvim_set_hl(0, "PmenuThumb", { bg = "#878092" })
	-- Other surfaces zaibatsu leaves bright/white
	vim.api.nvim_set_hl(0, "VisualNOS", { fg = "#d7d5db", bg = "#3a1e6e" })
	vim.api.nvim_set_hl(0, "WildMenu", { fg = "#ffd700", bg = "#3a1e6e", bold = true })
	vim.api.nvim_set_hl(0, "TabLine", { fg = "#a39bb0", bg = "#2a1450" })
	vim.api.nvim_set_hl(0, "TabLineSel", { fg = "#ffd700", bg = "#3a1e6e", bold = true })
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "#170233" })
	vim.api.nvim_set_hl(0, "WinBar", { fg = "#d7d5db", bg = "#1f0a3a" })
	vim.api.nvim_set_hl(0, "WinBarNC", { fg = "#878092", bg = "#170233" })
	vim.api.nvim_set_hl(0, "MsgArea", { fg = "#d7d5db", bg = "#0e0024" })
	-- WhichKey-style overlays (covers folke/which-key.nvim and snacks variants)
	vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "#1a0540" })
	vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#878092", bg = "#1a0540" })
	-- Distinguish object keys from value identifiers (JSON, JS/TS, Lua tables, etc.)
	vim.api.nvim_set_hl(0, "@variable.member", { fg = "#87afff" })
	vim.api.nvim_set_hl(0, "@property", { fg = "#87afff" })
	-- Elixir atoms / map keys (`:foo`, `%{key: val}`)
	vim.api.nvim_set_hl(0, "@string.special.symbol", { fg = "#87afff" })
	-- Function/method (calls AND declarations) — amber, distinct from variables (cyan),
	-- strings (yellow), keys (blue), keywords (pink). Covers JS/TS + Elixir.
	vim.api.nvim_set_hl(0, "@function", { fg = "#ffaf00" })
	vim.api.nvim_set_hl(0, "@function.call", { fg = "#ffaf00" })
	vim.api.nvim_set_hl(0, "@function.method", { fg = "#ffaf00" })
	vim.api.nvim_set_hl(0, "@function.method.call", { fg = "#ffaf00" })
	-- Module / namespace names (Elixir modules, TS namespaces) — italic teal,
	-- so `LicenseApplication`, `Steps`, `OnboardingSchema` stand apart from variables.
	vim.api.nvim_set_hl(0, "@module", { fg = "#af87ff", bold = true })
	-- MatchParen: zaibatsu uses reverse video which obscures the cursor.
	vim.api.nvim_set_hl(0, "MatchParen", { fg = "#ffd700", bg = "#3a1e6e", bold = true })
	vim.api.nvim_set_hl(0, "@lsp.type.module", { fg = "#af87ff", bold = true })
	vim.api.nvim_set_hl(0, "@lsp.type.namespace", { fg = "#af87ff", bold = true })
	-- LSP semantic tokens override treesitter once the server attaches
	vim.api.nvim_set_hl(0, "@lsp.type.property", { fg = "#87afff" })
	vim.api.nvim_set_hl(0, "@lsp.type.function", { fg = "#ffaf00" })
	vim.api.nvim_set_hl(0, "@lsp.type.method", { fg = "#ffaf00" })
	-- JS/TS classes & constructors share the Elixir module styling: bold violet.
	vim.api.nvim_set_hl(0, "@constructor", { fg = "#af87ff", bold = true })
	vim.api.nvim_set_hl(0, "@lsp.type.class", { fg = "#af87ff", bold = true })
	-- Enum members and readonly fields: keep them on the @variable.member blue
	-- (the treesitter color) instead of letting LSP recolor them as Constant (yellow).
	vim.api.nvim_set_hl(0, "@lsp.type.enumMember", { link = "@variable.member" })
	vim.api.nvim_set_hl(0, "@lsp.typemod.enumMember.readonly", { link = "@variable.member" })
	-- Zaibatsu sets terminal_color_0 to its bg (#0e0024), so anything ANSI-black
	-- (e.g. lazygit borders) vanishes inside :terminal. Lift it just enough
	-- to be visible without affecting the editor background.
	vim.g.terminal_color_0 = "#2a1450"
end

vim.api.nvim_create_autocmd("ColorScheme", {
	pattern = "zaibatsu",
	desc = "Tone down zaibatsu's bright white statusline",
	callback = tone_down_zaibatsu,
})

-- options.lua applies the colorscheme before this file loads, so the autocmd
-- above misses the initial load. Apply the override now if we're already on it.
if vim.g.colors_name == "zaibatsu" then
	tone_down_zaibatsu()
end

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
