local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("async", {
		t({ "async () => {", "\t" }),
		i(0),
		t({ "", "}" }),
	}),
}
