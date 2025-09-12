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
				},
			},
			log = {
				{ type = "echo", level = vim.log.levels.INFO },
				{ type = "file", filename = "overseer.log", level = vim.log.levels.INFO },
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
			name = "mix credo",
			builder = function()
				return { cmd = { "mix" }, args = { "credo" } }
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
			"<leader>4",
			function()
				local overseer = require("overseer")
				local tasks = overseer.list_tasks({ recent_first = true })
				if #tasks == 0 then
					vim.notify("No tasks found")
					return
				elseif #tasks == 1 then
					overseer.run_action(tasks[1], "open float")
				else
					vim.ui.select(tasks, {
						prompt = "Select task:",
						format_item = function(task)
							return task.name
						end,
					}, function(task)
						if task then
							overseer.run_action(task, "open float")
						end
					end)
				end
			end,
			desc = "Pick task and open output in float window",
		},
		{
			"<leader>R",
			function()
				vim.cmd.normal("yy")
				vim.cmd("OverseerQuickAction open float")
				vim.cmd.normal("p")
			end,
			desc = "Pastes the current line on the most recent task buffer",
		},
		{
			"<leader>R",
			function()
				vim.cmd.normal('"vy"')
				vim.cmd("OverseerQuickAction open float")
				vim.cmd.normal('"vp')
			end,
			desc = "Pastes the current selection on the most recent task buffer",
			mode = { "v" },
		},
	},
}
