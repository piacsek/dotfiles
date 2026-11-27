local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s({ trig = "ttest", priority = 1000 }, {
		t({ "#[test]", "fn " }),
		i(1),
		t({ "() {", "\t" }),
		i(2),
		t({ "", "}" }),
	}),
}
