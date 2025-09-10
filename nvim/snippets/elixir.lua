local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("skip", {
		t("@tag :skip"),
	}),
	s("ioinspect", {
		t("|> IO.inspect(label: \""),
		i(1),
		t("\")"),
	}),
}