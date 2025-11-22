return function(overseer)
	overseer.register_template({
		name = "simple task",
		builder = function()
			return {
				cmd = { "echo" },
				args = { "hello" },
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

	local k8s_envs = {
		{ env = "production" },
		{ env = "staging", priority = 2 },
	}

	for _, config in ipairs(k8s_envs) do
		overseer.register_template({
			name = "tsh " .. config.env,
			builder = function()
				return {
					cmd = { "tsh" },
					args = { "kube", "login", config.env .. "-gke-cluster-1" },
				}
			end,
		})
		overseer.register_template({
			name = "k9s nova " .. config.env,
			priority = config.priority,
			builder = function()
				return {
					cmd = { "k9s" },
					args = { "-n", "nova" },
					components = {
						{
							"dependencies",
							task_names = { "tsh " .. config.env },
							sequential = true,
						},
						"default",
					},
				}
			end,
		})
	end
end
