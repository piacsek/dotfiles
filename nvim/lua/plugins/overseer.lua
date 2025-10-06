return {
	"stevearc/overseer.nvim",
	opts = {
		templates = { "builtin" },
	},
	config = function(_, _opts)
		local overseer = require("overseer")

		overseer.setup({
			templates = {
				mix = false,
			},
			task_list = {
				min_height = 0.5,
				bindings = {
					["<Esc>"] = "Close",
					["r"] = "<CMD>OverseerQuickAction restart<CR>",
					["w"] = "<CMD>OverseerQuickAction watch<CR>",
					["W"] = "<CMD>OverseerQuickAction unwatch<CR>",
				},
			},
			log = {
				{ type = "echo", level = vim.log.levels.INFO },
				{ type = "file", filename = "overseer.log", level = vim.log.levels.INFO },
			},
			component_aliases = {
				default_neotest = {
					"display_duration",
					"on_output_summarize",
					"on_exit_set_status",
					{
						"pattern_notifier",
						patterns = {
							{ pattern = "Compiling (%d+) files" },
							{ pattern = "Generated %w+ app", message = "Compilation succeeded. Starting ExUnit..." },
							{ pattern = "Running ExUnit", message = "Running ExUnit..." },
							{ pattern = "Compilation error" },
							{ pattern = "%d+ tests?, %d+ failures?", once = true },
						},
					},
				},
			},
		})

		overseer.register_template({
			name = "claude",
			builder = function()
				return {
					cmd = { "claude" },
				}
			end,
		})

		overseer.register_template({
			name = "claude nvim config",
			builder = function()
				return {
					cmd = { "claude" },
					cwd = vim.fn.stdpath("config"),
				}
			end,
		})

		overseer.register_template({
			name = "view pr in the browser",
			builder = function()
				return {
					cmd = { "gh" },
					args = { "pr", "view", "-w" },
				}
			end,
		})

		overseer.register_template({
			name = "pr status",
			builder = function()
				return {
					cmd = { "gh" },
					args = { "pr", "checks" },
				}
			end,
		})

		overseer.register_template({
			name = "dotfiles sync",
			builder = function()
				return {
					cmd = { "/Users/piacsek/dotfiles/sync_dotfiles.sh" },
					args = { "sync" },
				}
			end,
		})

		local cloud_iex_envs = {
			{ env = "prod" },
			{ env = "staging", priority = 1 },
			{ env = "dev" },
		}

		for _, config in ipairs(cloud_iex_envs) do
			overseer.register_template({
				name = "cloud_iex " .. config.env,
				priority = config.priority,
				builder = function()
					return {
						cmd = { "cloud_iex" },
						args = { config.env },
					}
				end,
			})
		end

		overseer.register_template({
			name = "mix compile",
			builder = function()
				return {
					cmd = { "mix" },
					args = { "compile", "--warnings-as-errors" },
					components = {
						{
							"pattern_notifier",
							patterns = {
								{ pattern = "Compiling (%d+) files" },
								{ pattern = "Generated %w+ app", once = true },
								{ pattern = "Compilation error", once = true },
							},
						},
						"on_output_summarize",
						"on_exit_set_status",
						"display_duration",
					},
				}
			end,
		})
		overseer.register_template({
			name = "mix credo",
			builder = function()
				return {
					cmd = { "mix" },
					args = { "credo" },
					components = {
						{
							"pattern_notifier",
							patterns = {
								{ pattern = "Checking (%d+) source file" },
								{ pattern = "(%d+) mods/funs", once = true },
							},
						},
						"on_output_summarize",
						"on_exit_set_status",
						"display_duration",
					},
				}
			end,
		})
		overseer.register_template({
			name = "mix deps.get",
			builder = function()
				return { cmd = { "mix" }, args = { "deps.get" } }
			end,
		})

		overseer.register_template({
			name = "iex -S mix phx.server",
			builder = function()
				return {
					cmd = { "iex" },
					args = { "-S", "mix", "phx.server" },
				}
			end,
		})
	end,
	keys = {
		{ "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Overseer Run" },
		{ "<leader>re", "<cmd>OverseerToggle<cr>", desc = "Overseer Toggle" },
		{ "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "Overseer Task Action" },
		{
			"<leader>rl",
			function()
				local overseer = require("overseer")
				local tasks = overseer.list_tasks({ recent_first = true })
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
				local tasks = overseer.list_tasks({ recent_first = true })
				if #tasks == 0 then
					vim.notify("No tasks found")
					return
				elseif #tasks == 1 then
					overseer.run_action(tasks[1], "open")
				else
					vim.ui.select(tasks, {
						prompt = "Select task:",
						format_item = function(task)
							return task.name
						end,
					}, function(task)
						if task then
							overseer.run_action(task, "open")
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
				local tasks = overseer.list_tasks({ recent_first = true })
				if #tasks == 0 then
					vim.notify("No tasks found")
					return
				else
					overseer.run_action(tasks[1], "open")
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
	},
}
