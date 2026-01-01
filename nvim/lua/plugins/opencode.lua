return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	opts = {
		confirm_edits = true,
		contexts = {
			["@harpoon"] = function(context)
				-- Get harpoon list
				local ok, harpoon = pcall(require, "harpoon")
				if not ok then
					vim.notify("Harpoon not available", vim.log.levels.WARN)
					return nil
				end

				local list = harpoon:list()
				local items = list.items

				if #items == 0 then
					return nil
				end

				-- Build file references for all harpoon files
				local files = {}
				for _, item in ipairs(items) do
					if item.value and item.value ~= "" then
						table.insert(files, "@" .. item.value)
					end
				end

				if #files == 0 then
					return nil
				end

				return table.concat(files, " ")
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
