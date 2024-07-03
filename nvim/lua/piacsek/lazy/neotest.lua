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
		dump = function(o)
			if type(o) == "table" then
				local s = "{ "
				for k, v in pairs(o) do
					if type(k) ~= "number" then
						k = '"' .. k .. '"'
					end
					s = s .. "[" .. k .. "] = " .. dump(v) .. ","
				end
				return s .. "} "
			else
				return tostring(o)
			end
		end
		neotest.setup({
			adapters = {
				require("neotest-elixir")({
					post_process_command = function(cmd)
						local test_file_path_from_root = cmd[#cmd]
						local current_umbrella_app = test_file_path_from_root:match("^apps/([^/]+)")
						local umbrella_relative_path_to_test =
							test_file_path_from_root:match("apps/" .. current_umbrella_app .. "/(.*)")

						return {
							"mix",
							"cmd",
							"--app",
							current_umbrella_app,
							"mix",
							"test",
							"--formatter",
							"NeotestElixir.Formatter",
							"--formatter",
							"ExUnit.CLIFormatter",
							umbrella_relative_path_to_test,
						}
					end,
				}),
			},
		})

		vim.keymap.set("n", "<leader>ta", function()
			neotest.run.run(vim.fn.expand("%"))
		end)

		vim.keymap.set("n", "<leader>tt", function()
			neotest.run.run()
		end)

		vim.keymap.set("n", "<leader>to", function()
			neotest.output.open()
		end)

		vim.keymap.set("n", "<leader>tO", function()
			neotest.output_panel.open()
		end)

		vim.keymap.set("n", "<leader>ts", function()
			neotest.summary.toggle()
		end)
	end,
}
