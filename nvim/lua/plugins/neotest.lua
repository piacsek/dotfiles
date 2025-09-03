local function setup_keymaps()
	vim.keymap.set("n", "<leader><BS>", function()
		vim.cmd("w")
		require("neotest").run.run_last()
	end, { desc = "Save file and re-run last test (if any)" })

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
end

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
		-- Hack: neotest spawns a headless nvim which doesn't have everything loaded up like the regular instance
		-- And neotest elixir requires some stuff to be loaded in order to run return "require("neotest-elixir")._build_position"
		if not vim.env.LUA_PATH then
			local adapter_dir = vim.fn.stdpath("data") .. "/lazy/neotest-elixir"
			local lua_paths = table.concat({ adapter_dir .. "/lua/?.lua", adapter_dir .. "/lua/?/init.lua" }, ";")

			vim.env.LUA_PATH = lua_paths
		end

		require("neotest").setup({
			adapters = {
				require("neotest-elixir")({
					mix_task = "test",
					args = { "--trace" },
					elixir_ls_node_path = function()
						-- For umbrella projects, detect the app and change cwd
						local file = vim.fn.expand("%:p")
						if file:match("/apps/([^/]+)/") then
							local app_name = file:match("/apps/([^/]+)/")
							local app_dir = vim.fn.getcwd() .. "/apps/" .. app_name
							if vim.fn.isdirectory(app_dir) == 1 then
								vim.cmd("cd " .. app_dir)
							end
						end
						return nil
					end,
				}),
			},
			discovery = {
				enabled = false,
			},
		})

		setup_keymaps()
	end,
}