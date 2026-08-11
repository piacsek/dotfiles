-- DAP: Node.js debugging via vscode-js-debug (mason: js-debug-adapter).
local dap = require("dap")
local dapui = require("dapui")

-- vscode-js-debug speaks DAP over TCP: nvim-dap picks a free port, passes it
-- as argv[1], then connects. `${port}` is substituted by nvim-dap.
dap.adapters["pwa-node"] = {
	type = "server",
	host = "127.0.0.1",
	port = "${port}",
	executable = { command = "js-debug-adapter", args = { "${port}" } },
}

-- Project .vscode/launch.json files (read automatically) still use the legacy
-- `node` type; vscode-js-debug handles those, so alias it.
dap.adapters.node = dap.adapters["pwa-node"]

-- nvim-dap ships no language configs; without these `continue` has nothing to
-- run. Project-specific setups go in the project's .vscode/launch.json.
dap.configurations.javascript = {
	{ -- server already running under `node --inspect`
		type = "pwa-node",
		request = "attach",
		name = "Attach to port 9229",
		port = 9229,
		cwd = "${workspaceFolder}",
		restart = true,
		skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
	},
	{
		type = "pwa-node",
		request = "launch",
		name = "Launch current file",
		program = "${file}",
		cwd = "${workspaceFolder}",
		console = "integratedTerminal",
		skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
	},
}
dap.configurations.typescript = dap.configurations.javascript

-- Scopes/stack/watches UI, opened and closed with the session.
dapui.setup({})
-- Inline variable values next to their declarations while stopped.
require("nvim-dap-virtual-text").setup({})
dap.listeners.after.event_initialized.dapui = dapui.open
dap.listeners.before.event_terminated.dapui = dapui.close
dap.listeners.before.event_exited.dapui = dapui.close
