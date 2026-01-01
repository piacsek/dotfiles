return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	config = function()
		vim.keymap.set({ "n", "x", "v" }, "<leader>ca", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode" })
		vim.keymap.set({ "n", "x", "v" }, "<leader>cc", function()
			require("opencode").select()
		end, { desc = "Execute opencode action" })
		vim.keymap.set({ "n", "x", "v" }, "<leader>ce", function()
			require("opencode").toggle()
		end, { desc = "Toggle opencode" })

		-- vim.keymap.set({ "n", "x", "v" }, "go", function()
		-- 	return require("opencode").operator("@this ")
		-- end, { expr = true, desc = "Add range to opencode" })
		-- vim.keymap.set("n", "goo", function()
		-- 	return require("opencode").operator("@this ") .. "_"
		-- end, { expr = true, desc = "Add line to opencode" })
	end,
}
