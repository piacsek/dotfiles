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
		name = "dotfiles sync",
		builder = function()
			return {
				cmd = { "/Users/piacsek/dotfiles/sync_dotfiles.sh" },
				args = { "sync" },
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
