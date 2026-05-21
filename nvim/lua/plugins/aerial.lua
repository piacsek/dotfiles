-- Aerial: outline w/ Elixir multi-clause grouping
local function elixir_clause_signature(bufnr, lnum, _col)
	-- Read up to ~5 lines starting at lnum to handle multi-line heads.
	local lines = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum + 4, false)
	if not lines or #lines == 0 then
		return nil
	end
	local blob = table.concat(lines, " ")
	-- Match `def[p]/defmacro[p] name(...)` and capture the balanced parens.
	local _, _, args = blob:find("def%w*%s+[%w_!?]+(%b())")
	if not args then
		return nil
	end
	args = args:sub(2, -2) -- strip the outer parens
	return (args:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

local function is_private_def_line(bufnr, lnum)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "elixir")
	if not ok or not parser then
		return false
	end
	local trees = parser:trees()
	if not trees or not trees[1] then
		return false
	end
	local root = trees[1]:root()
	local row = lnum - 1
	-- Walk the line column-by-column until we hit a node, then climb to the
	-- enclosing `def[macro][p]` call.
	local node
	for col = 0, 200 do
		node = root:descendant_for_range(row, col, row, col)
		if node and node:type() ~= "ERROR" then
			break
		end
	end
	while node do
		if node:type() == "call" then
			local target = node:field("target")
			target = target and target[1]
			if target then
				local name = vim.treesitter.get_node_text(target, bufnr)
				if name == "defp" or name == "defmacrop" then
					return true
				elseif name == "def" or name == "defmacro" then
					return false
				end
			end
		end
		node = node:parent()
	end
	return false
end

local function group_elixir_clauses(bufnr, items)
	if vim.bo[bufnr].filetype ~= "elixir" then
		return items
	end

	-- Drop `@impl` markers — they decorate every function head and add noise.
	local function strip_impl(list)
		local i = 1
		while i <= #list do
			if list[i].name == "@impl" then
				table.remove(list, i)
			else
				if list[i].children then
					strip_impl(list[i].children)
				end
				i = i + 1
			end
		end
	end
	strip_impl(items)

	-- Re-kind private (defp/defmacrop) functions as "Method" so aerial picks
	-- up the AerialMethod / AerialMethodIcon highlight groups for them.
	local function tag_privacy(list)
		for _, s in ipairs(list) do
			if s.kind == "Function" and is_private_def_line(bufnr, s.lnum) then
				s.kind = "Method"
			end
			if s.children then
				tag_privacy(s.children)
			end
		end
	end
	tag_privacy(items)

	local function process(list, parent_level)
		for _, s in ipairs(list) do
			if s.children and #s.children > 0 then
				process(s.children, (s.level or parent_level or 0) + 1)
			end
		end

		local function is_def_kind(k)
			return k == "Function" or k == "Method"
		end
		local i = 1
		while i <= #list do
			local s = list[i]
			if is_def_kind(s.kind) then
				local base = s.name
				local base_kind = s.kind
				local j = i
				while j + 1 <= #list and list[j + 1].kind == base_kind and list[j + 1].name == base do
					j = j + 1
				end
				if j > i then
					local children = {}
					local level = s.level or parent_level or 0
					for k = i, j do
						local c = list[k]
						c.level = level + 1
						c.parent = nil
						local sig = elixir_clause_signature(bufnr, c.lnum, c.col or 1)
						if sig then
							local short = base:gsub("/.*", "")
							c.name = short .. "(" .. sig .. ")"
						end
						table.insert(children, c)
					end
					local parent = {
						kind = base_kind,
						name = base,
						level = level,
						lnum = list[i].lnum,
						end_lnum = list[j].end_lnum or list[j].lnum,
						col = list[i].col,
						end_col = list[i].end_col,
						selection_range = list[i].selection_range,
						children = children,
					}
					for k = j, i, -1 do
						table.remove(list, k)
					end
					table.insert(list, i, parent)
				end
			end
			i = i + 1
		end
	end

	process(items, 0)
	return items
end

-- Explicit nerd-font icons (codicon set). Aerial's defaults use emoji that
-- render as tofu in many terminals; this gives a consistent monochrome look.
local aerial_icons = {
	Array = " ",
	Boolean = " ",
	Class = " ",
	Constant = " ",
	Constructor = " ",
	Enum = " ",
	EnumMember = " ",
	Event = " ",
	Field = " ",
	File = " ",
	Function = " ",
	Interface = " ",
	Key = " ",
	Method = " ",
	Module = " ",
	Namespace = " ",
	Null = " ",
	Number = " ",
	Object = " ",
	Operator = " ",
	Package = " ",
	Property = " ",
	String = " ",
	Struct = " ",
	TypeParameter = " ",
	Variable = " ",
	Collapsed = " ",
}

require("aerial").setup({
	backends = {
		["_"] = { "treesitter", "lsp" },
		elixir = { "treesitter" },
	},
	post_add_all_symbols = group_elixir_clauses,
	show_guides = true,
	layout = {
		default_direction = "right",
		min_width = 30,
		max_width = 60,
	},
	icons = aerial_icons,
	filter_kind = false,
})

-- Public defs render purple; private defs (re-kinded to Method) render beige.
local PUBLIC_FG = "#bd93f9"
local PRIVATE_FG = "#e6d3b3"
local function set_aerial_privacy_hl()
	vim.api.nvim_set_hl(0, "AerialFunction", { fg = PUBLIC_FG })
	vim.api.nvim_set_hl(0, "AerialFunctionIcon", { fg = PUBLIC_FG })
	vim.api.nvim_set_hl(0, "AerialMethod", { fg = PRIVATE_FG, italic = true })
	vim.api.nvim_set_hl(0, "AerialMethodIcon", { fg = PRIVATE_FG, italic = true })
end
set_aerial_privacy_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_aerial_privacy_hl })
