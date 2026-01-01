return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	opts = {
		confirm_edits = true,
		contexts = {
			["@harpoon"] = function(context)
				local ok, harpoon = pcall(require, "harpoon")
				if not ok then
					return nil
				end

				local list = harpoon:list()
				if not list or not list.items then
					return nil
				end

				local length = list:length()
				if length == 0 then
					return nil
				end

				local paths = {}
				for i = 1, length do
					local item = list.items[i]
					if item and item.value and item.value ~= "" then
						table.insert(paths, context.format({ path = item.value }))
					end
				end

				if #paths == 0 then
					return nil
				end

				return table.concat(paths, " ")
			end,
		},
	},
	config = function()
		vim.keymap.set({ "n", "x", "v" }, "<leader>cc", function()
			require("opencode").ask("@this: ", { submit = true })
		end, { desc = "Ask opencode" })
		vim.keymap.set({ "n", "x", "v" }, "<leader>C", function()
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

		vim.keymap.set("v", "<leader>ca", function()
			return require("opencode").operator("@this ")
		end, { expr = true, desc = "Add range to opencode" })
		vim.keymap.set("n", "<leader>ca", function()
			return require("opencode").operator("@this ") .. "_"
		end, { expr = true, desc = "Add line to opencode" })
	end,
}
