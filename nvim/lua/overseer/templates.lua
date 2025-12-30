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

	overseer.register_template({
		name = "auto-commit",
		builder = function()
			return {
				name = "auto-commit",
				cmd = { vim.fn.expand("$HOME") .. "/dotfiles/auto-commit.sh" },
			}
		end,
	})

	overseer.register_template({
		name = "lazygit-review",
		builder = function()
			return {
				name = "review-commit-push",
				cmd = { "lazygit" },
				strategy = {
					"toggleterm",
					direction = "float",
					open_on_start = true,
					close_on_exit = true,
				},
			}
		end,
	})

	overseer.register_template({
		name = "git-push",
		builder = function()
			return {
				name = "git-push",
				cmd = { "bash" },
				args = {
					"-c",
					'BRANCH=$(git rev-parse --abbrev-ref HEAD) && git pull origin "$BRANCH" --rebase && git push origin "$BRANCH"',
				},
			}
		end,
	})

	overseer.register_template({
		name = "review-commit-push",
		builder = function()
			return {
				name = "review-commit-push",
				cmd = { "lazygit" },
				strategy = {
					"toggleterm",
					direction = "float",
					open_on_start = true,
					close_on_exit = true,
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
