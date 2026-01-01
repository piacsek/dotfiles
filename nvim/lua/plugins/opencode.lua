return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = { win = { width = 0.5 } } } },
	},
	opts = {
		confirm_edits = true,
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

		vim.keymap.set("n", "<leader>ch", function()
			local harpoon = require("harpoon")

			local list = harpoon:list()
			if not list or not list.items then
				vim.notify("No harpoon list found", vim.log.levels.WARN)
				return
			end

			local length = list:length()
			if length == 0 then
				vim.notify("No files in harpoon list", vim.log.levels.WARN)
				return
			end

			local files = {}
			for i = 1, length do
				local item = list.items[i]
				if item and item.value and item.value ~= "" then
					table.insert(files, "@" .. item.value)
				end
			end

			if #files == 0 then
				vim.notify("No valid files in harpoon list", vim.log.levels.WARN)
				return
			end

			local files_list = table.concat(files, " ")
			local prompt = "These are relevant files for this session: " .. files_list

			require("opencode").prompt(prompt, { submit = false })
		end, { desc = "Add harpoon files to opencode" })
	end,
}
