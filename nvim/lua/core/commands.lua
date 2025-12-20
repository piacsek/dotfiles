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

vim.api.nvim_create_user_command("K9s", function()
	vim.ui.input({ prompt = "Namespace (leave empty for default): " }, function(input)
		if input and input ~= "" then
			vim.cmd("terminal k9s -n " .. input)
		else
			vim.cmd("terminal k9s")
		end
	end)
end, { desc = "Run k9s in a terminal buffer" })
