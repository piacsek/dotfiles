return {
	"herisetiawan00/jtt.nvim",
	config = function()
		require("jtt").setup()
	end,
	keys = {
		{ "<leader>jt", "<cmd>JumpTest<CR>", desc = "[J]ump to [T]est" },
	},
}
