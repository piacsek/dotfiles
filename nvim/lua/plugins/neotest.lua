return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-neotest/neotest-jest",
		"nvim-lua/plenary.nvim",
		"jfpedroza/neotest-elixir",
	},
	config = function()
		-- Only load jest adapter if package.json exists since neotest errors if it doesn't
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

		local neotest = require("neotest")
		---@diagnostic disable-next-line: missing-fields
		neotest.setup({
			adapters = adapters,
			running = {
				concurrent = false,
			},
			consumers = {
				---@diagnostic disable-next-line: assign-type-mismatch
				overseer = require("neotest.consumers.overseer"),
			},
			---@diagnostic disable-next-line: missing-fields
			summary = {
				open = "vsplit",
			},
			---@diagnostic disable-next-line: missing-fields
			output = {
				open_on_run = false,
			},
			default_strategy = "overseer",
		})

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

		vim.keymap.set("n", "<leader>ta", function()
			local file_path = vim.fn.expand("%:p")
			local adapter_ids = neotest.state.adapter_ids()
			if #adapter_ids > 0 then
				-- Use the first adapter - you could make this smarter by detecting which adapter owns the file
				neotest.summary.target(adapter_ids[1], file_path)
			else
				vim.notify("No neotest adapters found", vim.log.levels.WARN)
			end
		end, { desc = "[T]est set t[A]rget" })

		vim.keymap.set("n", "<leader>tq", function()
			local adapter_ids = neotest.state.adapter_ids()
			if #adapter_ids > 0 then
				-- Clear target for all adapters
				for _, adapter_id in ipairs(adapter_ids) do
					neotest.summary.target(adapter_id, nil)
				end
			end
		end, { desc = "[T]est clear target ([Q]uit)" })

		vim.keymap.set("n", "<leader><BS>", function()
			if vim.bo.buftype == "" then
				vim.cmd("w")
			end
			local position_id, last_args = neotest.run.get_last_run()
			if position_id and last_args then
				neotest.run.run_last()
			end
		end, { desc = "Save file and re-run last test (if any)" })
	end,
}
