-- Aerial: outline w/ Elixir multi-clause grouping
local function elixir_clause_signature(bufnr, lnum, _col)
	-- Aerial's lnum can land on the function name (one line below the `def`
	-- keyword on wrapped heads), so read a couple of lines above lnum too.
	-- Then anchor the search at the def line at-or-above lnum so a following
	-- clause's `def` (within lnum+4) can't shadow the real head.
	local lo = math.max(lnum - 2, 1)
	local hi = lnum + 4
	local lines = vim.api.nvim_buf_get_lines(bufnr, lo - 1, hi, false)
	if not lines or #lines == 0 then
		return nil
	end
	local lnum_idx = math.min(lnum - lo + 1, #lines)
	local def_idx = nil
	for i = lnum_idx, 1, -1 do
		-- Match a leading `def`/`defp`/`defmacro[p]`/`defguard` token. The
		-- char after `def%w*` must be whitespace, `(`, `,`, or EOL — this
		-- rejects identifiers like `def_foo` (underscore is not in `%w`,
		-- so it remains as the next char and fails the class match).
		if lines[i]:match("^%s*def%w*[%s%(,]") or lines[i]:match("^%s*def%w*$") then
			def_idx = i
			break
		end
	end
	if not def_idx then
		return nil
	end
	-- Concatenate from the def line forward so wrapped args (`def foo(\n  x,\n  y\n)`)
	-- still close their `%b()` group inside the blob.
	local blob = table.concat(lines, " ", def_idx)
	-- Match `def[p]/defmacro[p] name(...)` and capture the balanced parens.
	local _, _, args = blob:find("def%w*%s+[%w_!?]+(%b())")
	if not args then
		return nil
	end
	args = args:sub(2, -2) -- strip the outer parens
	return (args:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Arity = top-level commas + 1, ignoring commas inside nested (), [], {} and
-- inside "…" / '…' strings. Empty/nil signature means no parens → arity 0.
-- Default args (`x \\ 0`) don't add commas at depth 0, so arity is preserved.
local function elixir_arity_from_sig(sig)
	if not sig or sig:match("^%s*$") then
		return 0
	end
	local depth, count = 0, 1
	local in_str = nil
	local i = 1
	while i <= #sig do
		local c = sig:sub(i, i)
		if in_str then
			if c == "\\" then
				i = i + 1 -- skip escaped char
			elseif c == in_str then
				in_str = nil
			end
		elseif c == '"' or c == "'" then
			in_str = c
		elseif c == "(" or c == "[" or c == "{" then
			depth = depth + 1
		elseif c == ")" or c == "]" or c == "}" then
			depth = depth - 1
		elseif c == "," and depth == 0 then
			count = count + 1
		end
		i = i + 1
	end
	return count
end

-- Override aerial's bundled elixir query so kinds reflect public vs private
-- defs and @-attributes get a dedicated kind. This is more reliable than
-- inspecting source lines at post-process time.
vim.treesitter.query.set(
	"elixir",
	"aerial",
	[[
(call
  target: (identifier) @identifier
  (#any-of? @identifier "defmodule" "defprotocol")
  (arguments) @name
  (#set! "kind" "Function")) @symbol

; NB: capture is @impl_call, NOT @identifier. Aerial's bundled Elixir
; postprocess (extensions.lua) keys on the @identifier text and, when it
; equals "defimpl", does `assert(node_from_match(match, "protocol"))`. Our
; query has no @protocol capture, so naming this @identifier triggers an
; assertion failure on every buffer containing a defimpl. Renaming the
; capture hides it from that branch; the #set! below sets the kind anyway.
(call
  target: (identifier) @impl_call
  (#eq? @impl_call "defimpl")
  (arguments
    (alias)
    (keywords
      (pair
        key: (keyword) @kw
        (#match? @kw "^for:")
        value: (alias) @name)))
  (#set! "kind" "Function")) @symbol

; Public: def / defmacro / defguard -> Function
(call
  target: (identifier) @identifier
  (#any-of? @identifier "def" "defmacro" "defguard")
  (arguments
    [
      (call
        target: (identifier) @name)
      (binary_operator
        left: (call
          target: (identifier) @name))
      (identifier) @name
    ])
  (#set! "kind" "Function")) @symbol

; Private: defp / defmacrop -> Method
(call
  target: (identifier) @identifier
  (#any-of? @identifier "defp" "defmacrop")
  (arguments
    [
      (call
        target: (identifier) @name)
      (binary_operator
        left: (call
          target: (identifier) @name))
      (identifier) @name
    ])
  (#set! "kind" "Method")) @symbol

; All @-prefixed module attributes -> Constant (rendered with @ icon).
; @callback / @spec are intentionally skipped — they're type declarations,
; not symbols worth navigating to.
(unary_operator
  operator: "@"
  operand: (call
    target: (identifier) @identifier
    (#eq? @identifier "module_attribute")
    (arguments) @name) @symbol
  (#set! "kind" "Constant")) @start

(unary_operator
  operator: "@"
  operand: (call
    target: (identifier) @name
    (#not-any-of? @name "module_attribute" "callback" "spec" "doc" "moduledoc")) @symbol
  (#set! "kind" "Constant")) @start

(do_block
  (call
    target: (identifier) @identifier
    (#eq? @identifier "defstruct")) @symbol
  (#set! "kind" "Function")) @start

(call
  target: (identifier) @identifier
  (#any-of? @identifier "describe" "test")
  (arguments
    (string
      (quoted_content) @name))
  (#set! "kind" "Function")) @symbol

(do_block
  (call
    target: (identifier) @identifier @name
    (#eq? @identifier "setup")) @symbol
  (#set! "kind" "Function")) @start
]]
)

-- Detect whether the function at lnum is private. Reads lnum and a couple of
-- lines above it, searching upward for `defp`/`defmacrop`. Aerial's lnum can
-- land on the function name one line below `defp` on wrapped heads, so we
-- widen *upward* only — looking forward would let a following clause of the
-- opposite privacy shadow the real head.
local function elixir_kind_for(bufnr, lnum)
	local lo = math.max(lnum - 2, 1)
	local lines = vim.api.nvim_buf_get_lines(bufnr, lo - 1, lnum, false) or {}
	for i = #lines, 1, -1 do
		local kw = lines[i]:match("(def%a*)%s+[%w_!?]")
		if kw == "defp" or kw == "defmacrop" then
			return "Method"
		elseif kw == "def" or kw == "defmacro" or kw == "defguard" then
			return "Function"
		end
	end
	return nil
end

local function group_elixir_clauses(bufnr, items)
	if vim.bo[bufnr].filetype ~= "elixir" then
		return items
	end

	-- Drop noisy decorators (@impl on every clause, @spec/@doc declarations).
	local noisy = { ["@impl"] = true, ["@spec"] = true, ["@doc"] = true, ["@moduledoc"] = true }
	local function strip_noise(list)
		local i = 1
		while i <= #list do
			if noisy[list[i].name] then
				table.remove(list, i)
			else
				if list[i].children then
					strip_noise(list[i].children)
				end
				i = i + 1
			end
		end
	end
	strip_noise(items)

	-- Re-tag privacy by inspecting source lines. Bypasses the cached treesitter
	-- query that aerial may already have loaded with the bundled (def==Function)
	-- mapping.
	local function tag_privacy(list)
		for _, s in ipairs(list) do
			if s.kind == "Function" or s.kind == "Method" then
				local k = elixir_kind_for(bufnr, s.lnum)
				if k then
					s.kind = k
				end
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

		-- Pre-compute signature + arity once per def-kind item so grouping can
		-- key on (name, kind, arity). Without arity, `foo/1` and `foo/2` (whose
		-- treesitter @name captures are both bare `foo`) would be merged into a
		-- single bogus multi-clause group when adjacent in source.
		for _, s in ipairs(list) do
			if is_def_kind(s.kind) then
				s._aerial_sig = elixir_clause_signature(bufnr, s.lnum, s.col or 1)
				s._aerial_arity = elixir_arity_from_sig(s._aerial_sig)
			end
		end

		local function rename(item, base)
			local sig = item._aerial_sig
			if sig then
				local short = base:gsub("/.*", "")
				item.name = short .. "(" .. sig .. ")"
			end
			item._aerial_sig = nil
			item._aerial_arity = nil
		end

		-- When a clause is re-parented under a new grouping node it descends
		-- one level — and so does its entire subtree, whose levels were already
		-- assigned (during the recursive `process` call above) relative to the
		-- pre-grouping depth. Bump them so descendants stay consistent.
		local function bump_subtree_levels(items, delta)
			for _, item in ipairs(items) do
				if item.level then
					item.level = item.level + delta
				end
				if item.children and #item.children > 0 then
					bump_subtree_levels(item.children, delta)
				end
			end
		end

		local i = 1
		while i <= #list do
			local s = list[i]
			if is_def_kind(s.kind) then
				local base = s.name
				local base_kind = s.kind
				local base_arity = s._aerial_arity
				local j = i
				while j + 1 <= #list
					and list[j + 1].kind == base_kind
					and list[j + 1].name == base
					and list[j + 1]._aerial_arity == base_arity
				do
					j = j + 1
				end
				if j > i then
					local level = s.level or parent_level or 0
					local parent = {
						kind = base_kind,
						name = base,
						level = level,
						lnum = list[i].lnum,
						end_lnum = list[j].end_lnum or list[j].lnum,
						col = list[i].col,
						end_col = list[i].end_col,
						selection_range = list[i].selection_range,
						parent = list[i].parent,
						children = {},
					}
					for k = i, j do
						local c = list[k]
						c.level = level + 1
						if c.children and #c.children > 0 then
							bump_subtree_levels(c.children, 1)
						end
						c.parent = parent
						rename(c, base)
						table.insert(parent.children, c)
					end
					for k = j, i, -1 do
						table.remove(list, k)
					end
					table.insert(list, i, parent)
				else
					-- Single-clause (or arity-distinct neighbor): append the args
					-- to the name so the popup shows `foo(arg1, arg2)` instead of
					-- bare `foo`.
					rename(s, base)
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
	Constant = "@ ",
	Constructor = " ",
	Enum = " ",
	EnumMember = " ",
	Event = " ",
	Field = " ",
	File = " ",
	Function = "ƒ ",
	Interface = " ",
	Key = " ",
	Method = "ƒ ",
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
	lazy_load = false,
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
	get_highlight = function(symbol, is_icon, _is_collapsed)
		if symbol.kind == "Function" then
			return is_icon and "AerialPubFnIcon" or "AerialPubFn"
		elseif symbol.kind == "Method" then
			return is_icon and "AerialPrivFnIcon" or "AerialPrivFn"
		end
	end,
})

-- Custom HL groups returned by aerial's get_highlight callback above.
-- Colors are derived from the active colorscheme so they follow theme changes.
local function hl_fg(name)
	local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
	return ok and hl.fg or nil
end
local function set_aerial_privacy_hl()
	local pub = hl_fg("DiagnosticOk") or hl_fg("String") or hl_fg("Special")
	local priv = hl_fg("DiagnosticError") or hl_fg("Error") or hl_fg("ErrorMsg")
	local attr = hl_fg("Keyword") or hl_fg("Statement") or hl_fg("Identifier")
	vim.api.nvim_set_hl(0, "AerialPubFn", { fg = pub })
	vim.api.nvim_set_hl(0, "AerialPubFnIcon", { fg = pub })
	vim.api.nvim_set_hl(0, "AerialPrivFn", { fg = priv, italic = true })
	vim.api.nvim_set_hl(0, "AerialPrivFnIcon", { fg = priv, italic = true })
	-- @-prefixed module attributes (kind = Constant) get the third color.
	vim.api.nvim_set_hl(0, "AerialConstant", { fg = attr })
	vim.api.nvim_set_hl(0, "AerialConstantIcon", { fg = attr })
end
set_aerial_privacy_hl()
vim.api.nvim_create_autocmd("ColorScheme", { callback = set_aerial_privacy_hl })
-- Re-apply after startup in case anything else clears these groups during init.
vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = set_aerial_privacy_hl })
