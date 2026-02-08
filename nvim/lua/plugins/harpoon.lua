local function setup_keymaps(harpoon)
	vim.keymap.set("n", "<M-h>", function()
		harpoon.ui:toggle_quick_menu(require("harpoon"):list())
	end)

	vim.keymap.set("n", "<leader>a", function()
		harpoon:list():add()
	end)

	vim.keymap.set("n", "<leader>A", function()
		harpoon:list():clear()
		harpoon:list():add()
	end)

	vim.keymap.set("n", "<M-a>", function()
		harpoon:list():select(1)
	end)

	vim.keymap.set("n", "<M-s>", function()
		harpoon:list():select(2)
	end)

	vim.keymap.set("n", "<M-d>", function()
		harpoon:list():select(4)
	end)

	vim.keymap.set("n", "<M-f>", function()
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
		vim.keymap.set("n", "<M-h>", function()
			harpoon.ui:toggle_quick_menu(require("harpoon"):list())
		end)

		vim.keymap.set("n", "<leader>a", function()
			harpoon:list():add()
		end)

		vim.keymap.set("n", "<leader>A", function()
			harpoon:list():clear()
			harpoon:list():add()
		end)

		vim.keymap.set("n", "<M-a>", function()
			harpoon:list():select(1)
		end)

		vim.keymap.set("n", "<M-s>", function()
			harpoon:list():select(2)
		end)

		vim.keymap.set("n", "<M-d>", function()
			harpoon:list():select(4)
		end)

		vim.keymap.set("n", "<M-f>", function()
			harpoon:list():select(4)
		end)
	end,
}
