return {
	"NickvanDyke/opencode.nvim",
	dependencies = {
		{ "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	},
	opts = {
		confirm_edits = true,
		prompts = {
			add_harpoon_files = {
				prompt = function()
					local harpoon = require("harpoon")

					local list = harpoon:list()
					if not list or not list.items then
						vim.notify("No harpoon list found", vim.log.levels.WARN)
						return nil
					end

					local length = list:length()
					if length == 0 then
						vim.notify("No files in harpoon list", vim.log.levels.WARN)
						return nil
					end

					-- Build file references for all harpoon files
					local files = {}
					for i = 1, length do
						local item = list.items[i]
						if item and item.value and item.value ~= "" then
							table.insert(files, "@" .. item.value)
						end
					end

					if #files == 0 then
						vim.notify("No valid files in harpoon list", vim.log.levels.WARN)
						return nil
					end

					local files_list = table.concat(files, " ")
					return "These are relevant files for this session: " .. files_list
				end,
				submit = true,
			},
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

		-- Add harpoon files to opencode session
		vim.keymap.set("n", "<leader>ch", function()
			require("opencode").prompt("add_harpoon_files")
		end, { desc = "Add harpoon files to opencode" })
	end,
}
