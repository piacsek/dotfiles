local function setup_keymaps(neotest)
	vim.keymap.set("n", "<leader>tt", function()
		neotest.run.run()
	end, { desc = "[T]est neares[T]" })

	vim.keymap.set("n", "<leader>tf", function()
		neotest.run.run(vim.fn.expand("%"))
	end, { desc = "[T]est [F]ile" })

	vim.keymap.set("n", "<leader>ts", function()
		neotest.summary.toggle()
	end, { desc = "[T]est [S]ummary" })

	vim.keymap.set("n", "<leader>to", function()
		neotest.output.open({ enter = true })
	end, { desc = "[T]est [O]utput" })

	vim.keymap.set("n", "<leader><BS>", function()
		if vim.bo.buftype == "" then
			vim.cmd("w")
		end
		local position_id, last_args = neotest.run.get_last_run()
		if position_id and last_args then
			neotest.run.run_last()
		end
	end, { desc = "Save file and re-run last test (if any)" })
end

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-neotest/neotest-jest",
		"nvim-lua/plenary.nvim",
		"nvim-treesitter/nvim-treesitter",
		"jfpedroza/neotest-elixir",
	},
	config = function()
		local neotest = require("neotest")

		neotest.setup({
			adapters = { require("neotest-elixir"), require("neotest-jest") },
			consumers = {
				overseer = require("neotest.consumers.overseer"),
			},
			summary = {
				open = "botright vsplit",
			},
			output = {
				open_on_run = false,
			},
		})

		setup_keymaps(neotest)
	end,
}
