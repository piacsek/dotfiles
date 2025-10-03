local function setup_keymaps()
	vim.keymap.set("n", "<leader>e", function()
		require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
	end)

	vim.keymap.set("n", "<leader>a", function()
		require("harpoon"):list():add()
	end)

	for file_index, key in ipairs({ "j", "k", "l", "h" }) do
		vim.keymap.set("n", ("<C-%s>"):format(key), function()
			require("harpoon"):list():select(file_index)
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
		setup_keymaps()
	end,
}
