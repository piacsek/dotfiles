return {
	"stevearc/overseer.nvim",
	opts = {
		templates = { "builtin" },
	},
	config = function(_, _opts)
		local overseer = require("overseer")
		overseer.setup({
			task_list = {
				min_height = 0.5,
			},
			log = {
				{
					type = "echo",
					level = vim.log.levels.INFO,
				},
				{
					type = "file",
					filename = "overseer.log",
					level = vim.log.levels.DEBUG,
				},
			},
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
		-- Custom cloud_iex tasks
		overseer.register_template({
			name = "cloud_iex prod",
			builder = function()
				return {
					cmd = { "cloud_iex" },
					args = { "prod" },
				}
			end,
		})

		overseer.register_template({
			name = "cloud_iex staging",
			priority = 1,
			builder = function()
				return {
					cmd = { "cloud_iex" },
					args = { "staging" },
				}
			end,
		})

		overseer.register_template({
			name = "cloud_iex dev",
			builder = function()
				return {
					cmd = { "cloud_iex" },
					args = { "dev" },
				}
			end,
		})

		overseer.register_template({
			name = "iex -S mix phx.server",
			builder = function()
				return {
					cmd = { "iex" },
					args = { "-S", "mix", "phx.server" },
					cwd = vim.fn.getcwd(),
				}
			end,
			condition = {
				filetype = { "elixir" },
			},
		})
	end,
	keys = {
		{ "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Overseer Run" },
		{ "<leader>re", "<cmd>OverseerToggle<cr>", desc = "Overseer Toggle" },
		{ "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "Overseer Task Action" },
		{ "<leader>4", "<cmd>OverseerQuickAction open float<cr>", desc = "Open task output on a float window" },
		{
			"<leader>X",
			function()
				vim.api.nvim_feedkeys("yy", "n", false)
				vim.cmd("OverseerQuickAction open float")
				vim.api.nvim_feedkeys("p", "n", false)
			end,
			desc = "Open task output on a float window",
		},
	},
}
