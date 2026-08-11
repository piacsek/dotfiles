-- DAP: Node.js debugging via vscode-js-debug (mason: js-debug-adapter).
local dap = require("dap")
local dapui = require("dapui")

-- vscode-js-debug speaks DAP over TCP: nvim-dap picks a free port, passes it
-- as argv[1], then connects. `${port}` is substituted by nvim-dap.
-- The host argv[2] is load-bearing: given only a port, js-debug binds ::1, and
-- nvim-dap's connect to 127.0.0.1 then fails with no error — the session just
-- never starts.
dap.adapters["pwa-node"] = {
	type = "server",
	host = "127.0.0.1",
	port = "${port}",
	executable = { command = "js-debug-adapter", args = { "${port}", "127.0.0.1" } },
}

-- Project .vscode/launch.json files (read automatically) still use the legacy
-- `node` type; vscode-js-debug handles those, so alias it.
dap.adapters.node = dap.adapters["pwa-node"]

-- nvim-dap ships no language configs; without these `continue` has nothing to
-- run. Attaching to an already-running server is inherently project-specific
-- (which inspector port) — those configs belong in the project's `.nvim.lua`
-- or `.vscode/launch.json`, both of which nvim-dap merges into this list.
dap.configurations.javascript = {
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

-- Gutter signs. nvim-dap's defaults are plain letters (B / →); emoji read
-- faster at a glance. They're double-width, so signcolumn needs the room —
-- `auto` (the default) gives it.
vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointCondition", { text = "🟠", texthl = "", numhl = "" })
vim.fn.sign_define("DapLogPoint", { text = "🔵", texthl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "⚪", texthl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "👉", texthl = "", numhl = "", linehl = "Visual" })

-- Scopes/stack/watches UI, opened and closed with the session.
dapui.setup({})
-- Inline variable values next to their declarations while stopped.
require("nvim-dap-virtual-text").setup({})
dap.listeners.after.event_initialized.dapui = dapui.open
dap.listeners.before.event_terminated.dapui = dapui.close
dap.listeners.before.event_exited.dapui = dapui.close
