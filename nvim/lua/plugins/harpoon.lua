local function setup_keymaps(harpoon)
	vim.keymap.set("n", "<leader>e", function()
		harpoon.ui:toggle_quick_menu(require("harpoon"):list())
	end)

	vim.keymap.set("n", "<leader>a", function()
		harpoon:list():add()
	end)

	vim.keymap.set("n", "<leader>A", function()
		harpoon:list():clear()
		harpoon:list():add()
	end)

	for file_index in { 1, 2, 3, 4, 5, 6, 7, 8, 9, 0 } do
		vim.keymap.set("n", ("<leader>%s"):format(file_index), function()
			harpoon:list():select(file_index)
		end)
	end
end

return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()
		setup_keymaps(harpoon)
	end,
}
