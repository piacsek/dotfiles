return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"jfpedroza/neotest-elixir",
	},

	config = function()
		local function find_app_root(test_file)
			-- Find the directory that contains the "apps" directory
			local project_root = vim.fn.getcwd()
			local test_file_path = vim.fn.fnamemodify(test_file, ":p")
			local apps_index = test_file_path:find("/apps/")
			if apps_index then
				local app_dir = test_file_path:sub(1, apps_index + 4)
				return app_dir .. test_file_path:match("/apps/([^/]+)/")
			end
			return project_root
		end

		local neotest = require("neotest")
		neotest.setup({
			adapters = {
				require("neotest-elixir"),
			},
		})

		vim.keymap.set("n", "<leader>ta", function()
			neotest.run.run(vim.fn.expand("%"))
		end)

		vim.keymap.set("n", "<leader>tt", function()
			neotest.run.run()
		end)

		vim.keymap.set("n", "<leader>to", function()
			neotest.output.open({ open = true })
		end)

		vim.keymap.set("n", "<leader>ts", function()
			neotest.summary.toggle()
		end)
	end,
}
