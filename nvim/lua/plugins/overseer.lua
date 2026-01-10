local clear_non_in_progress_tasks = function(overseer)
	local tasks = overseer.list_tasks()
	for _, task in ipairs(tasks) do
		if task.status ~= "RUNNING" then
			task:dispose()
		end
	end
end
local open_last_task_output = function(overseer)
	local tasks = overseer.list_tasks({ recent_first = true, include_ephemeral = true })
	if #tasks == 0 then
		vim.notify("No tasks found")
		return
	else
		tasks[1]:open_output()
	end
end
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
				silent = {
					"on_exit_set_status",
					{ "on_complete_notify", statuses = { "FAILURE" } },
					{ "on_complete_dispose", require_view = { "SUCCESS", "FAILURE" } },
				},
			},
			task_list = {
				min_height = 0.5,
				keymaps = {
					["<Esc>"] = { "<CMD>close<CR>", desc = "Close task list" },
					["r"] = { "keymap.run_action", opts = { action = "restart" }, desc = "Restart task" },
					["s"] = { "keymap.run_action", opts = { action = "stop" }, desc = "Stop task" },
					["w"] = { "keymap.run_action", opts = { action = "watch" }, desc = "Watch task" },
					["W"] = { "keymap.run_action", opts = { action = "unwatch" }, desc = "Unwatch task" },
					["C"] = {
						function()
							clear_non_in_progress_tasks(overseer)
						end,
						desc = "Clear all tasks except in progress",
					},
				},
			},
			log = {
				{ type = "echo", level = vim.log.levels.INFO },
				{ type = "file", filename = "overseer.log", level = vim.log.levels.INFO },
			},
		})

		-- Track project template names during loading
		local project_template_names = {}
		local original_register = overseer.register_template

		-- Load project templates first, tracking their names
		local project_templates = vim.fn.getcwd() .. "/piacsek/overseer/templates.lua"
		if vim.fn.filereadable(project_templates) == 1 then
			local function project_register(opts)
				if opts.name == nil then
					vim.notify("Invalid overseer project template: must define a unique name", vim.log.levels.WARN)
					return
				end
				if project_template_names[opts.name] == true then
					vim.notify(
						opts.name .. " has already been defined in this project. Skipping duplicate...",
						vim.log.levels.WARN
					)
					return
				end
				project_template_names[opts.name] = true
				original_register(opts)
			end
			overseer.register_template = project_register
			dofile(project_templates)(overseer)
			overseer.register_template = original_register
		end

		-- Then load global templates, skipping any that were overridden by project templates
		local global_templates = vim.fn.stdpath("config") .. "/lua/overseer/templates.lua"
		if vim.fn.filereadable(global_templates) == 1 then
			local function global_register(opts)
				if not project_template_names[opts.name] then
					original_register(opts)
				end
			end
			overseer.register_template = global_register
			dofile(global_templates)(overseer)
			overseer.register_template = original_register
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
			"<leader>rq",
			function()
				local overseer = require("overseer")
				clear_non_in_progress_tasks(overseer)
			end,
			desc = "Clear non in progress tasks",
		},
		{
			"<leader>ll",
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
			"<leader>jr",
			function()
				local overseer = require("overseer")
				open_last_task_output(overseer)
			end,
			desc = "Open the current task's output",
		},
		{
			"<leader>R",
			function()
				local overseer = require("overseer")
				vim.cmd.normal("yy")
				open_last_task_output(overseer)
				vim.cmd.normal("p")
			end,
			desc = "Pastes the current line on the most recent task buffer",
		},
		{
			"<leader>R",
			function()
				local overseer = require("overseer")
				vim.cmd.normal('"vy"')
				open_last_task_output(overseer)
				vim.cmd.normal('"vp')
			end,
			desc = "Pastes the current selection on the most recent task buffer",
			mode = { "v" },
		},
		{
			"<leader>G",
			function()
				local overseer = require("overseer")
				overseer.run_task({ name = "review-commit-push" })
				-- overseer.open()
			end,
			desc = "Review, commit and push",
		},
	},
}
