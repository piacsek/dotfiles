return {
	"mbbill/undotree",
	keys = {
		{ "<leader>ju", vim.cmd.UndotreeToggle, desc = "Toggle Undo Tree" },
	},
	config = function()
		vim.g.undotree_WindowLayout = 3
		vim.g.undotree_SplitWidth = 40
	end,
}
