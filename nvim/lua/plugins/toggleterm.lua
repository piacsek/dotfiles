return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.4
			end
		end,
		open_mapping = [[<c-\>]],
		hide_numbers = true,
		shade_terminals = false,
		start_in_insert = true,
		insert_mappings = true,
		terminal_mappings = true,
		persist_size = true,
		persist_mode = true,
		direction = "float",
		close_on_exit = true,
		shell = vim.o.shell,
		float_opts = {
			border = "curved",
			width = function()
				return math.floor(vim.o.columns * 0.9)
			end,
			height = function()
				return math.floor(vim.o.lines * 0.9)
			end,
		},
	},
	keys = {
		{ "<leader>4", '<cmd>TermExec cmd="echo "keymap deprecated!" && sl"<CR>', desc = ":p deprecated!" },
		{ "<leader>8", "<cmd>TermExec cmd='echo 'keymap deprecated!' && sl'<CR>", desc = ":p deprecated!" },
		{ "<leader>9", "<cmd>TermExec cmd='echo 'keymap deprecated!' && sl'<CR>", desc = ":p deprecated!" },
	},
}
