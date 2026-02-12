return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end)

		vim.keymap.set("n", "<leader>A", function()
			harpoon:list():clear()
			harpoon:list():add()
		end)

		vim.keymap.set("n", "<M-z>", function()
			harpoon:list():select(1)
		end)

		vim.keymap.set("n", "<M-x>", function()
			harpoon:list():select(2)
		end)

		vim.keymap.set("n", "<M-c>", function()
			harpoon:list():select(3)
		end)

		vim.keymap.set("n", "<M-v>", function()
			harpoon:list():select(4)
		end)
		vim.keymap.set("n", "<M-b>", function()
			harpoon:list():select(4)
		end)

		vim.keymap.set("n", "<M-e>", function()
			harpoon.ui:toggle_quick_menu(require("harpoon"):list())
		end)
	end,
}
