vim.cmd("hi clear")
if vim.fn.exists("syntax_on") then
	vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "high-contrast"

local colors = {
	-- Background colors
	bg = "#131314",
	bg_float = "#131314",
	bg_highlight = "#000066", -- caret row
	bg_popup = "#281A33",
	bg_search = "#006280", -- selection
	bg_sidebar = "#131314",
	bg_statusline = "#131314",
	bg_visual = "#006280",

	-- Foreground colors
	fg = "#ebebeb",
	fg_dark = "#999999", -- line numbers
	fg_gutter = "#999999",
	fg_sidebar = "#ebebeb",

	-- Accent colors
	black = "#000000",
	blue = "#33ccff",
	blue1 = "#1aabff",
	blue2 = "#4ff0ff",
	cyan = "#37cccc",
	grey = "#bcc2be",
	green = "#54b33e",
	green1 = "#62cc47",
	green2 = "#499936",
	magenta = "#ff96ff",
	orange = "#ed864a",
	purple = "#ed94ff",
	purple_dark = "#8547ff",
	red = "#fa3232",
	red1 = "#f2495a",
	teal = "#5be7f5",
	yellow = "#ffcf40",
	yellow1 = "#ffbf66",

	-- Git colors
	git_add = "#62cc47",
	git_change = "#4ff0ff",
	git_delete = "#ed864a",

	-- Diagnostic colors
	error = "#ff0d25",
	warning = "#ffb300",
	info = "#b39500",
	hint = "#005380",

	-- Special
	none = "NONE",
}

local function hi(group, opts)
	local cmd = "hi " .. group
	if opts.fg then
		cmd = cmd .. " guifg=" .. opts.fg
	end
	if opts.bg then
		cmd = cmd .. " guibg=" .. opts.bg
	end
	if opts.bold then
		cmd = cmd .. " gui=bold"
	end
	if opts.italic then
		cmd = cmd .. " gui=italic"
	end
	if opts.underline then
		cmd = cmd .. " gui=underline"
	end

	vim.cmd(cmd)
end

-- Editor
hi("Normal", { fg = colors.fg, bg = colors.bg })
hi("NormalFloat", { fg = colors.fg, bg = colors.bg_float })
hi("LineNr", { fg = colors.fg_dark })
hi("CursorLineNr", { fg = colors.fg, bold = true })
hi("CursorLine", { bg = colors.bg_highlight })
hi("Visual", { bg = colors.bg_visual })
hi("Search", { bg = colors.bg_search })
hi("IncSearch", { bg = colors.bg_search })

-- Syntax highlighting
hi("Comment", { fg = colors.cyan, italic = true })
hi("Constant", { fg = colors.purple, italic = true })
hi("String", { fg = colors.green })
hi("Character", { fg = colors.green })
hi("Number", { fg = colors.blue, bold = true })
hi("Boolean", { fg = colors.purple, italic = true })
hi("Float", { fg = colors.blue, bold = true })

hi("Identifier", { fg = colors.fg })
hi("Function", { fg = colors.yellow })

hi("Statement", { fg = colors.orange })
hi("Conditional", { fg = colors.orange })
hi("Repeat", { fg = colors.orange })
hi("Label", { fg = colors.orange })
hi("Operator", { fg = colors.orange })
hi("Keyword", { fg = colors.orange })
hi("Exception", { fg = colors.orange })

hi("PreProc", { fg = colors.orange })
hi("Include", { fg = colors.orange })
hi("Define", { fg = colors.orange })
hi("Macro", { fg = colors.orange })
hi("PreCondit", { fg = colors.orange })

hi("Type", { fg = colors.fg })
hi("StorageClass", { fg = colors.orange })
hi("Structure", { fg = colors.orange })
hi("Typedef", { fg = colors.orange })

hi("Special", { fg = colors.orange })
hi("SpecialChar", { fg = colors.orange })
hi("Tag", { fg = colors.orange })
hi("Delimiter", { fg = colors.orange, bold = true })
hi("SpecialComment", { fg = colors.cyan })
hi("Debug", { fg = colors.orange })

-- Git signs
hi("GitSignsAdd", { fg = colors.git_add })
hi("GitSignsChange", { fg = colors.git_change })
hi("GitSignsDelete", { fg = colors.git_delete })

-- Diagnostics
hi("DiagnosticError", { fg = colors.error })
hi("DiagnosticWarn", { fg = colors.warning })
hi("DiagnosticInfo", { fg = colors.green1 })
hi("DiagnosticHint", { fg = colors.hint })

-- LSP
hi("LspReferenceText", { bg = "#3b0a" })
hi("LspReferenceRead", { bg = "#3b0a" })
hi("LspReferenceWrite", { bg = "#471747" })

-- Treesitter
hi("@variable", { fg = colors.purple_dark, bold = true })
hi("@variable.member", { fg = colors.purple })
hi("@boolean.elixir", { fg = colors.orange })
hi("@constant", { fg = colors.purple, italic = true })
hi("@constant.builtin", { fg = colors.purple, italic = true })
hi("@symbol", { fg = colors.purple, italic = true })
hi("@string.special.symbol", { fg = colors.purple })
hi("@string", { fg = colors.green })
hi("@string.escape", { fg = colors.orange })
hi("@number", { fg = colors.blue, bold = true })
hi("@boolean", { fg = colors.purple, italic = true })
hi("@function", { fg = colors.yellow })
hi("@function.builtin", { fg = colors.yellow })
hi("@function.call", { fg = colors.yellow })
hi("@function.call.elixir", { fg = colors.fg })
hi("@keyword", { fg = colors.orange })
hi("@keyword.function", { fg = colors.orange })
hi("@keyword.return", { fg = colors.orange })
hi("@type", { fg = colors.teal, bold = true })
hi("@namespace", { fg = colors.teal, bold = true })
hi("@module", { fg = colors.teal, bold = true })
hi("@type.builtin", { fg = colors.cyan, bold = true })
hi("@comment", { fg = colors.grey, italic = true })
hi("@punctuation.special", { fg = colors.blue, bold = true })
hi("@punctuation.delimiter", { fg = colors.orange, bold = true })
hi("@punctuation.bracket", { fg = colors.blue, bold = true })
hi("@constructor", { fg = colors.blue, bold = true })
hi("@type.qualifier", { fg = colors.blue, bold = true })
hi("@operator", { fg = colors.green1, bold = true })
hi("@tag.attribute.heex", { fg = colors.fg })
hi("@string.special.elixir", { fg = colors.green })
hi("@markup.raw.block.markdown", { fg = colors.grey })

-- Telescope
hi("TelescopeNormal", { fg = colors.fg, bg = colors.bg_float })
hi("TelescopeBorder", { fg = colors.fg_dark, bg = colors.bg_float })
hi("TelescopeSelection", { bg = colors.bg_visual })

-- Status line
hi("StatusLine", { fg = colors.fg, bg = colors.bg_statusline })
hi("StatusLineNC", { fg = colors.fg_dark, bg = colors.bg_statusline })

-- Tab line
hi("TabLine", { fg = colors.fg_dark, bg = colors.bg_statusline })
hi("TabLineFill", { bg = colors.bg_statusline })
hi("TabLineSel", { fg = colors.fg, bg = colors.bg_highlight })

-- Popup menu
hi("Pmenu", { fg = colors.fg, bg = colors.bg_popup })
hi("PmenuSel", { fg = colors.fg, bg = colors.bg_visual })
hi("PmenuSbar", { bg = colors.bg_popup })
hi("PmenuThumb", { bg = colors.fg_dark })

-- Folding
hi("Folded", { fg = colors.fg, bg = colors.none })
hi("FoldColumn", { fg = colors.fg_dark, bg = colors.bg })

-- Diff
hi("DiffAdd", { bg = "#400f" })
hi("DiffChange", { bg = "#99" })
hi("DiffDelete", { bg = "#4d2e08" })
hi("DiffText", { bg = "#661300" })
