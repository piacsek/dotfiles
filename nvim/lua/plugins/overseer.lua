return {
	"stevearc/overseer.nvim",
	opts = {
		templates = { "builtin" },
	},
	config = function(_, _opts)
		local overseer = require("overseer")

		overseer.setup({
			disable_template_modules = { "^overseer.template" },
			component_aliases = {
				default_neotest = {
					"on_exit_set_status",
					"on_complete_notify",
					{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
				},
			},
			task_list = {
				min_height = 0.5,
				bindings = {
					["<Esc>"] = "Close",
					["r"] = "<CMD>OverseerQuickAction restart<CR>",
					["s"] = "<CMD>OverseerQuickAction stop<CR>",
					["w"] = "<CMD>OverseerQuickAction watch<CR>",
					["W"] = "<CMD>OverseerQuickAction unwatch<CR>",
				},
			},
			log = {
				{ type = "echo", level = vim.log.levels.INFO },
				{ type = "file", filename = "overseer.log", level = vim.log.levels.INFO },
			},
		})

		local global_templates = vim.fn.stdpath("config") .. "/lua/overseer/templates.lua"
		if vim.fn.filereadable(global_templates) == 1 then
			dofile(global_templates)(overseer)
		end

		local project_templates = vim.fn.getcwd() .. "/piacsek/overseer/templates.lua"
		if vim.fn.filereadable(project_templates) == 1 then
			dofile(project_templates)(overseer)
		end
	end,
	keys = {
		{ "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Overseer Run" },
		{ "<leader>re", "<cmd>OverseerToggle<cr>", desc = "Overseer Toggle" },
		{ "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "Overseer Task Action" },
		{
			"<leader>rl",
			function()
				local overseer = require("overseer")
				local tasks = overseer.list_tasks({ recent_first = true, include_ephemeral = true })
				if #tasks == 0 then
					vim.notify("No tasks found")
					return
				else
					overseer.run_action(tasks[1], "restart")
				end
			end,
			desc = "[R]un [L]ast",
		},
		{
			"<leader>4",
			function()
				local overseer = require("overseer")
				local tasks = overseer.list_tasks({ recent_first = true, include_ephemeral = true })
				if #tasks == 0 then
					vim.notify("No tasks found")
					return
				elseif #tasks == 1 then
					tasks[1]:open_output()
				else
					vim.ui.select(tasks, {
						prompt = "Select task:",
						format_item = function(task)
							return task.name
						end,
					}, function(task)
						if task then
							task:open_output()
						end
					end)
				end
			end,
			desc = "Pick task and open its output",
		},
		{
			"<leader>9",
			function()
				local overseer = require("overseer")
				local tasks = overseer.list_tasks({ recent_first = true, include_ephemeral = true })
				if #tasks == 0 then
					vim.notify("No tasks found")
					return
				else
					tasks[1]:open_output()
				end
			end,
			desc = "Open the current task's output",
		},
		{
			"<leader>R",
			function()
				vim.cmd.normal("yy")
				vim.cmd("OverseerQuickAction open")
				vim.cmd.normal("p")
			end,
			desc = "Pastes the current line on the most recent task buffer",
		},
		{
			"<leader>R",
			function()
				vim.cmd.normal('"vy"')
				vim.cmd("OverseerQuickAction open")
				vim.cmd.normal('"vp')
			end,
			desc = "Pastes the current selection on the most recent task buffer",
			mode = { "v" },
		},
		{
			"<leader>jc",
			function()
				local overseer = require("overseer")

				local claude_running = vim.tbl_filter(function(task)
					return task.name:lower():find("claude", 1, true)
				end, overseer.list_tasks({ status = "RUNNING", include_ephemeral = true }))

				if #claude_running == 0 then
					vim.ui.select({ "claude", "claude nvim config" }, {
						prompt = "Select Claude task to run:",
					}, function(task_name)
						overseer.run_task({ name = task_name }, function(task)
							if task then
								task:open_output()
							end
						end)
					end)
				elseif #claude_running == 1 then
					claude_running[1]:open_output()
				else
					vim.ui.select(claude_running, {
						prompt = "Select Claude task:",
						format_item = function(task)
							return task.name
						end,
					}, function(task)
						if task then
							task:open_output()
						end
					end)
				end
			end,
			desc = "[J]ump to [C]laude task",
		},
	},
}
