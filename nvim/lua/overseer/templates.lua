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
		name = "review-commit-push",
		builder = function()
			local has_toggleterm, toggleterm = pcall(require, "toggleterm.terminal")
			if not has_toggleterm then
				vim.notify("toggleterm not found. Please install toggleterm.nvim", vim.log.levels.ERROR)
				return nil
			end

			return {
				name = "review-commit-push",
				strategy = {
					"jobstart",
					on_start = function()
						local Terminal = toggleterm.Terminal
						local term = Terminal:new({
							cmd = vim.fn.expand("$HOME") .. "/dotfiles/review-commit-push.sh",
							direction = "float",
							close_on_exit = false,
							on_exit = function(t, job, exit_code, name)
								vim.schedule(function()
									if exit_code == 0 then
										vim.notify("Review-commit-push completed successfully!", vim.log.levels.INFO)
									else
										vim.notify(
											"Review-commit-push failed with exit code: " .. exit_code,
											vim.log.levels.ERROR
										)
									end
								end)
							end,
						})
						term:toggle()
					end,
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
