-- Close all buffers except the current one
vim.api.nvim_create_user_command("BufOnly", function()
	local current = vim.api.nvim_get_current_buf()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
			if buftype ~= "terminal" then
				vim.api.nvim_buf_delete(buf, { force = false })
			end
		end
	end
end, { desc = "Close all buffers except current" })

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
			if vim.api.nvim_buf_get_option(buf, "modified") then
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

-- Auto-cleanup hidden buffers that haven't been used in a while
vim.api.nvim_create_user_command("CleanHiddenBuffers", function()
	local current = vim.api.nvim_get_current_buf()
	local deleted = 0

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if buf ~= current and vim.api.nvim_buf_is_loaded(buf) then
			local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
			local modified = vim.api.nvim_buf_get_option(buf, "modified")
			local wins = vim.fn.win_findbuf(buf)

			-- Only delete if: not special buffer, not modified, and hidden
			if buftype == "" and not modified and #wins == 0 then
				pcall(vim.api.nvim_buf_delete, buf, { force = false })
				deleted = deleted + 1
			end
		end
	end

	vim.notify(string.format("Cleaned %d hidden buffers", deleted), vim.log.levels.INFO)
end, { desc = "Delete all unmodified hidden buffers" })

-- Profile what's taking time when opening files
vim.api.nvim_create_user_command("ProfileFileOpen", function()
	local times = {}

	-- Track gitsigns attach
	vim.api.nvim_create_autocmd("User", {
		pattern = "GitSignsAttach",
		once = true,
		callback = function()
			times.gitsigns = vim.uv.hrtime()
		end,
	})

	-- Track LSP attach
	vim.api.nvim_create_autocmd("LspAttach", {
		once = true,
		callback = function()
			times.lsp_attach = vim.uv.hrtime()
		end,
	})

	-- Track when file is fully loaded
	vim.api.nvim_create_autocmd("BufReadPost", {
		once = true,
		callback = function()
			times.buf_read = vim.uv.hrtime()
		end,
	})

	vim.notify("Profiling enabled. Open a new file to measure timings.", vim.log.levels.INFO)

	-- After 5 seconds, report results
	vim.defer_fn(function()
		local start = times.buf_read or 0
		local report = "File open timings:\n"

		if times.gitsigns then
			report = report .. string.format("  Gitsigns: +%.2fms\n", (times.gitsigns - start) / 1e6)
		end
		if times.lsp_attach then
			report = report .. string.format("  LSP attach: +%.2fms\n", (times.lsp_attach - start) / 1e6)
		end

		vim.notify(report, vim.log.levels.INFO)
	end, 5000)
end, { desc = "Profile file opening performance" })
