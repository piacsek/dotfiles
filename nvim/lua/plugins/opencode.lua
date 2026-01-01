return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	opts = {
		confirm_edits = true,
	},
	config = function()
		vim.keymap.set({ "n", "x", "v" }, "<leader>cc", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode" })
		vim.keymap.set({ "n", "x", "v" }, "<leader>cc", function()
			require("opencode").select()
		end, { desc = "Execute opencode action" })
		vim.keymap.set({ "n", "x", "v" }, "<leader>ce", function()
			require("opencode").toggle()
		end, { desc = "Toggle opencode" })
		vim.keymap.set("n", "<M-C-u>", function()
			require("opencode").command("session.half.page.up")
		end, { desc = "opencode half page up" })
		vim.keymap.set("n", "<M-C-d>", function()
			require("opencode").command("session.half.page.down")
		end, { desc = "opencode half page down" })

		vim.keymap.set("v", "<leader>cal", function()
			return require("opencode").operator("@this ")
		end, { expr = true, desc = "Add range to opencode" })
		vim.keymap.set("n", "<leader>cal", function()
			return require("opencode").operator("@this ") .. "_"
		end, { expr = true, desc = "Add line to opencode" })
	end,
}
