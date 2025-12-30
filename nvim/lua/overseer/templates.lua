return function(overseer)
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
		name = "mix docs",
		builder = function()
			return {
				cmd = { "mix" },
				args = { "docs" },
			}
		end,
	})

	overseer.register_template({
		name = "mix compile",
		builder = function()
			return {
				cmd = { "mix" },
				args = { "compile", "--warnings-as-errors" },
			}
		end,
	})

	overseer.register_template({
		name = "mix credo",
		builder = function()
			return {
				cmd = { "mix" },
				args = { "credo" },
			}
		end,
	})

	overseer.register_template({
		name = "mix ecto.reset",
		builder = function()
			return { cmd = { "mix" }, args = { "ecto.reset" } }
		end,
	})

	overseer.register_template({
		name = "mix format",
		builder = function()
			return { cmd = { "mix" }, args = { "format" } }
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
			return { cmd = { "iex" }, args = { "-S", "mix", "phx.server" } }
		end,
	})

	overseer.register_template({
		name = "gh run watch",
		builder = function()
			return {
				cmd = { "gh" },
				args = { "run", "watch" },
			}
		end,
	})

	local overseer = require("overseer")

	overseer.register_template({
		name = "review-commit-push",
		builder = function()
			return {
				name = "review-commit-push",

				-- Run lazygit (interactive TUI)
				cmd = { "lazygit" },

				-- Use toggleterm and pop it open
				strategy = {
					"toggleterm",
					direction = "float", -- "float" | "tab" | "vertical" | "horizontal"
					open_on_start = true, -- auto-open when the task starts
					quit_on_exit = "never", -- don't auto-close the window
					close_on_exit = false, -- don't delete the terminal buffer
					-- size = 80,           -- used for vertical/horizontal (and sometimes float)
				},

				components = {
					{
						"dependencies",
						task_names = { "pre-ci checks" },
						sequential = true,
					},
					"default",
				},
			}
		end,
	})
end
