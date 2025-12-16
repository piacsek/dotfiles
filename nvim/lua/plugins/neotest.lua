local function setup_keymaps()
	vim.keymap.set("n", "<leader>tt", function()
		require("neotest").run.run()
	end, { desc = "[T]est neares[T]" })

	vim.keymap.set("n", "<leader>tf", function()
		require("neotest").run.run(vim.fn.expand("%"))
	end, { desc = "[T]est [F]ile" })

	vim.keymap.set("n", "<leader>ts", function()
		require("neotest").summary.toggle()
	end, { desc = "[T]est [S]ummary" })

	vim.keymap.set("n", "<leader>to", function()
		require("neotest").output.open({ enter = true })
	end, { desc = "[T]est [O]utput" })

	vim.keymap.set("n", "<leader><BS>", function()
		vim.cmd("w")
		vim.cmd("colorscheme high-contrast")
		local position_id, last_args = require("neotest").run.get_last_run()
		if position_id and last_args then
			require("neotest").run.run_last()
		end
	end, { desc = "Save file and re-run last test (if any)" })
end

return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-neotest/neotest-jest",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"jfpedroza/neotest-elixir",
	},
	config = function()
		-- Hack: neotest spawns a headless nvim which doesn't have everything loaded up like the regular instance
		-- And neotest elixir requires some stuff to be loaded in order to run return "require("neotest-elixir")._build_position"
		if not vim.env.LUA_PATH then
			local adapter_dir = vim.fn.stdpath("data") .. "/lazy/neotest-elixir"
			local lua_paths = table.concat({ adapter_dir .. "/lua/?.lua", adapter_dir .. "/lua/?/init.lua" }, ";")

			vim.env.LUA_PATH = lua_paths
		end

		-- Only load jest adapter if package.json exists
		local adapters = { require("neotest-elixir") }

		local cwd = vim.fn.getcwd()
		local package_json_path = cwd .. "/package.json"

		-- Check for project-specific jest config
		local project_jest_config = cwd .. "/piacsek/neotest/jest.lua"
		if vim.fn.filereadable(project_jest_config) == 1 then
			local ok, config = pcall(dofile, project_jest_config)
			if ok and type(config) == "table" and config.package_json_path then
				package_json_path = cwd .. "/" .. config.package_json_path
			end
		end

		if vim.fn.filereadable(package_json_path) == 1 then
			table.insert(adapters, require("neotest-jest"))
		end

		require("neotest").setup({
			adapters = adapters,
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

		setup_keymaps()
	end,
}
