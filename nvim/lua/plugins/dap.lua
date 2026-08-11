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

for _, ft in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
	dap.configurations[ft] = {
		{
			-- Server already running under `node --inspect` (port 9229).
			type = "pwa-node",
			request = "attach",
			name = "Attach to port 9229",
			address = "127.0.0.1",
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
		{
			type = "pwa-node",
			request = "attach",
			name = "Attach to process…",
			processId = require("dap.utils").pick_process,
			cwd = "${workspaceFolder}",
			skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
		},
	}
end
-- Anything project-specific (Docker localRoot/remoteRoot, env, monorepo cwd)
-- goes in the project's .vscode/launch.json — nvim-dap reads it on demand.

dapui.setup({})
require("nvim-dap-virtual-text").setup({})
dap.listeners.after.event_initialized.dapui = function()
	dapui.open({})
end
dap.listeners.before.event_terminated.dapui = function()
	dapui.close({})
end
dap.listeners.before.event_exited.dapui = function()
	dapui.close({})
end

vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk" })
