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

	vim.keymap.set("n", "<M-j>", function()
		harpoon:list():select(1)
	end)

	vim.keymap.set("n", "<M-k>", function()
		harpoon:list():select(2)
	end)

	vim.keymap.set("n", "<M-l>", function()
		harpoon:list():select(4)
	end)

	vim.keymap.set("n", "<M-h>", function()
		harpoon:list():select(4)
	end)
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
