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
	s({ trig = "tt", condition = function() return vim.fn.expand("%"):match("%.spec%.[tj]sx?$") ~= nil end }, {
		t('test.todo("'),
		i(1),
		t('")'),
	}),
	s("cdir", {
		t("console.dir("),
		i(0),
		t(", { depth: null });"),
	}),
}
