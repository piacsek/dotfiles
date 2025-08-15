return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",

	dependencies = { "nvim-lua/plenary.nvim" },

	config = function()
		local harpoon = require("harpoon")

		harpoon:setup()

		vim.keymap.set("n", "<leader>e", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())

			vim.keymap.set("n", "<leader>a", function()
				harpoon:list():add()
			end)
		end)

		local keys_that_toggle_selections = { "j", "k", "l", "h" }

		for file_index, key in ipairs(keys_that_toggle_selections) do
			local open_on_split_buffer_remap = ("<C-S-%s>"):format(key)
			vim.keymap.set("n", open_on_split_buffer_remap, function()
				harpoon:list():select(file_index, { vsplit = true })
			end)

			local open_on_same_buffer_remap = ("<C-%s>"):format(key)
			vim.keymap.set("n", open_on_same_buffer_remap, function()
				harpoon:list():select(file_index)
			end)

			local replace_file_remap = ("<leader><C-%s>"):format(key)
			vim.keymap.set("n", replace_file_remap, function()
				harpoon:list():select(file_index)
			end)
		end
	end,
}
