vim.api.nvim_create_user_command("R", function()
	vim.cmd("mksession! Session.vim | wall | restart source Session.vim")
end, { desc = "Restart nvim (save session, then source Session.vim)" })

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
	local names = {}
	for _, client in ipairs(clients) do
		table.insert(names, client.name)
	end
	vim.lsp.enable(names, false)
	vim.lsp.enable(names, true)
	vim.notify("Restarting LSP: " .. table.concat(names, ", "), vim.log.levels.INFO)
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

vim.api.nvim_create_user_command("TokenColor", function()
	local pos = vim.inspect_pos()

	-- Semantic tokens outrank treesitter; within each, higher priority and
	-- later insertion win. Semantic token entries are extmark records (group
	-- under opts.hl_group), unlike the flat treesitter items.
	local candidates = {}
	local st = {}
	for i, t in ipairs(pos.semantic_tokens) do
		if t.opts.hl_group then
			table.insert(st, { group = t.opts.hl_group, pri = t.opts.priority or 0, idx = i })
		end
	end
	table.sort(st, function(a, b)
		if a.pri ~= b.pri then
			return a.pri > b.pri
		end
		return a.idx > b.idx
	end)
	for _, t in ipairs(st) do
		table.insert(candidates, t.group)
	end
	for i = #pos.treesitter, 1, -1 do
		table.insert(candidates, pos.treesitter[i].hl_group)
	end

	---Follow the link chain (and the renderer's dot-segment fallback for
	---undefined groups like @lsp.type.property.lua) to the defining group.
	local function resolve_name(group)
		local seen = {}
		while true do
			local h = vim.api.nvim_get_hl(0, { name = group })
			if next(h) == nil and group:find("%.") then
				group = group:gsub("%.[^.]+$", "")
			elseif h.link and not seen[h.link] then
				seen[h.link] = true
				group = h.link
			else
				return group
			end
		end
	end

	-- First candidate whose effective attrs are non-empty is what's rendered;
	-- a group that resolves to nothing falls through to the next layer.
	local capture, name, hl
	for _, group in ipairs(candidates) do
		local attrs = vim.api.nvim_get_hl(0, { name = group, link = false })
		if next(attrs) ~= nil then
			capture, name, hl = group, resolve_name(group), attrs
			break
		end
	end
	if not name then
		vim.notify("No highlight under the cursor", vim.log.levels.WARN)
		return
	end

	local styles = {}
	for _, s in ipairs({ "bold", "italic", "underline", "undercurl", "strikethrough", "reverse" }) do
		if hl[s] then
			table.insert(styles, s)
		end
	end

	-- The group name line renders in the group itself; each color line gets a
	-- swatch block colored via a throwaway highlight group.
	local swatch = "████"
	local title = capture == name and name or (capture .. " -> " .. name)
	local lines, marks = { title }, {}
	local function color_line(label, color)
		if not color then
			table.insert(lines, ("%s  -"):format(label))
			return
		end
		local hex = ("#%06x"):format(color)
		local group = "TokenColorSwatch" .. label
		vim.api.nvim_set_hl(0, group, { fg = color })
		table.insert(lines, ("%s  %s %s"):format(label, hex, swatch))
		local start = #label + 2 + #hex + 1
		table.insert(marks, { line = #lines - 1, col = start, end_col = start + #swatch, group = group })
	end
	color_line("fg", hl.fg)
	color_line("bg", hl.bg)
	if #styles > 0 then
		table.insert(lines, table.concat(styles, " "))
	end

	-- The LSP docs popup's own machinery: first call opens the float, calling
	-- it again enters it for normal-mode navigation, q / cursor move closes.
	local buf, win = vim.lsp.util.open_floating_preview(lines, "", { focus_id = "token-color", border = "rounded" })
	-- The focus path (second call) enters the existing float without touching
	-- its content; the swatch extmarks from the first call still stand.
	if vim.api.nvim_get_current_win() == win then
		return
	end
	local ns = vim.api.nvim_create_namespace("token-color")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { end_col = #lines[1], hl_group = name })
	for _, m in ipairs(marks) do
		vim.api.nvim_buf_set_extmark(buf, ns, m.line, m.col, { end_col = m.end_col, hl_group = m.group })
	end
end, { desc = "Float with the resolved highlight group + color swatches under the cursor" })
