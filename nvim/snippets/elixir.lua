local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
	s("def", {
		t("def "), i(1, "name"), t("("), i(2), t({ ") do", "\t" }),
		i(3), t({ "", "end" }),
	}),
	s("defp", {
		t("defp "), i(1, "name"), t("("), i(2), t({ ") do", "\t" }),
		i(3), t({ "", "end" }),
	}),
	s("defmodule", {
		t("defmodule "), i(1, "Name"), t({ " do", "\t" }),
		i(2), t({ "", "end" }),
	}),
	s("skip", {
		t("@tag :skip"),
	}),
	s("dbg", {
		t("|> dbg()"),
	}),
	s("linfo", {
		t("|> Logger.info()"),
	}),
	s({ trig = "ttest", priority = 1000 }, {
		t("@tag :skip"),
		t({ "", 'test "' }),
		i(1),
		t('" do'),
		t({ "", "\t" }),
		i(2),
		t({ "", "end" }),
	}),
}
