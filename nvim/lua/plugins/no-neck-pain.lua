return {
	"shortcuts/no-neck-pain.nvim",
	config = function()
		vim.keymap.set("n", "<leader>zz", "<cmd>NoNeckPain<cr>", { desc = "Toggle No Neck Pain" })
		vim.keymap.set("n", "<leader>zu", "<cmd>NoNeckPainWidthUp<cr>", { desc = "Increases width" })
		vim.keymap.set("n", "<leader>zd", "<cmd>NoNeckPainWidthDown<cr>", { desc = "Increases width" })
		vim.keymap.set("n", "<leader>ztr", "<cmd>NoNeckPainToggleRightSide<cr>", { desc = "[T]oggles [R]ight side" })
		vim.keymap.set("n", "<leader>ztl", "<cmd>NoNeckPainToggleLeftSide<cr>", { desc = "[T]oggles [L]eft side" })
	end,
}

