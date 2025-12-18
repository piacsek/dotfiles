local function setup_keymaps(harpoon)
	vim.keymap.set("n", "<leader>e", function()
		harpoon.ui:toggle_quick_menu(require("harpoon"):list())
	end)

	vim.keymap.set("n", "<leader>a", function()
		vim.cmd("Gitsigns attach")
		harpoon:list():add()
	end)

	vim.keymap.set("n", "<leader>A", function()
		vim.cmd("Gitsigns detach_all")
		harpoon:list():clear()
		vim.cmd("Gitsigns attach")
		harpoon:list():add()
	end)

	for file_index, key in ipairs({ "j", "k", "l", "h" }) do
		vim.keymap.set("n", ("<C-%s>"):format(key), function()
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
