vim.api.nvim_create_user_command("LspInfo", "vertical checkhealth vim.lsp", { desc = "Show LSP health check" })
vim.api.nvim_create_user_command("LspLog", function()
	vim.cmd.edit(vim.lsp.log.get_filename())
end, { desc = "Show LSP health check" })

vim.api.nvim_create_user_command("LspRestart", function()
	local clients = vim.lsp.get_clients()
	if #clients == 0 then
		vim.notify("No active LSP clients", vim.log.levels.WARN)
		return
	end
	for _, client in ipairs(clients) do
		local bufs = vim.tbl_keys(client.attached_buffers)
		local config = client.config
		client:stop()
		vim.notify("Restarting LSP: " .. client.name, vim.log.levels.INFO)
		vim.defer_fn(function()
			local new_id = vim.lsp.start(config)
			if new_id then
				for _, buf in ipairs(bufs) do
					if vim.api.nvim_buf_is_valid(buf) then
						vim.lsp.buf_attach_client(buf, new_id)
					end
				end
			end
		end, 500)
	end
end, { desc = "Restart all active LSP clients" })

vim.api.nvim_create_user_command("ClearOldfiles", function()
	vim.v.oldfiles = {}
	vim.cmd("wshada!")
	vim.notify("Oldfiles list cleared", vim.log.levels.INFO)
end, { desc = "Clear the oldfiles list" })

vim.api.nvim_create_user_command("LineNumbers", function()
	vim.opt.relativenumber = true
	vim.opt.number = true
end, { desc = "Force line numbers to appear" })

vim.api.nvim_create_user_command("VerboseModeEnable", function()
	vim.opt.verbose = 12
	vim.opt.verbosefile = "/tmp/nvim-verbose.log"
end, { desc = "Enable verbose mode and log to /tmp/nvim-verbose.log" })

vim.api.nvim_create_user_command("VerboseModeDisable", function()
	vim.opt.verbose = 0
	vim.opt.verbosefile = ""
end, { desc = "Disable verbose mode" })

vim.api.nvim_create_user_command("VerboseModeOpenFile", function()
	vim.cmd("e /tmp/nvim-verbose.log")
end, { desc = "Opens verbose mode log file" })

vim.api.nvim_create_user_command("VerboseModeDeleteFile", function()
	vim.cmd("!rm /tmp/nvim-verbose.log")
end, { desc = "Deletes verbose mode log file" })

vim.api.nvim_create_user_command("BufferStats", function()
	local buffers = vim.api.nvim_list_bufs()
	local loaded = 0
	local hidden = 0
	local modified = 0
	local with_lsp = 0
	local total_diagnostics = 0

	for _, buf in ipairs(buffers) do
		if vim.api.nvim_buf_is_loaded(buf) then
			loaded = loaded + 1

			-- Check if hidden
			local wins = vim.fn.win_findbuf(buf)
			if #wins == 0 then
				hidden = hidden + 1
			end

			-- Check if modified
			if vim.api.nvim_get_option_value("modified", { buf = buf }) then
				modified = modified + 1
			end

			-- Check LSP attachment
			local clients = vim.lsp.get_clients({ bufnr = buf })
			if #clients > 0 then
				with_lsp = with_lsp + 1
			end

			-- Count diagnostics
			local diag = vim.diagnostic.get(buf)
			total_diagnostics = total_diagnostics + #diag
		end
	end

	local msg = string.format(
		"Buffers:\n  Total loaded: %d\n  Hidden: %d\n  Modified: %d\n  With LSP: %d\n  Total diagnostics: %d",
		loaded,
		hidden,
		modified,
		with_lsp,
		total_diagnostics
	)
	vim.notify(msg, vim.log.levels.INFO)
end, { desc = "Show buffer statistics" })

vim.api.nvim_create_user_command("NotificationsHistory", function()
	require("snacks").notifier.show_history()
end, { desc = "Notification history" })

vim.api.nvim_create_user_command("NotificationsClear", function()
	require("snacks").notifier.hide()
end, { desc = "Clear all notifications" })

vim.api.nvim_create_user_command("ThemeDefault", function()
	vim.cmd.colorscheme(vim.g._default_colorscheme)
	vim.notify(vim.g._default_colorscheme)
end, { desc = "Assigns the default colorscheme" })
