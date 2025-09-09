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
			name = "cloud_iex production",
			builder = function()
				return {
					cmd = { "cloud_iex" },
					args = { "production" },
				}
			end,
		})

		overseer.register_template({
			name = "cloud_iex staging",
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
	end,
	keys = {
		{ "<leader>rr", "<cmd>OverseerRun<cr>", desc = "Overseer Run" },
		{ "<leader>re", "<cmd>OverseerToggle<cr>", desc = "Overseer Toggle" },
		{ "<leader>ra", "<cmd>OverseerTaskAction<cr>", desc = "Overseer Task Action" },
	},
}
