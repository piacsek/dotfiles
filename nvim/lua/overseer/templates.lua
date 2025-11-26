return function(overseer)
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
				cwd = "/Users/piacsek/dotfiles/nvim/",
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
					{ "on_complete_dispose", statuses = { "SUCCESS" }, timeout = 1 },
				},
			}
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
			return {
				cmd = { "iex" },
				args = { "-S", "mix", "phx.server" },
			}
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
end
