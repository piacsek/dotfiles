-- Project-wide diagnostics from a real typechecker.
--
-- ts_ls only ever reports files you have open — it is a single-file server, so
-- a type error in a file you never visited is invisible. This runs the
-- project's own typecheck command asynchronously and publishes its output as
-- diagnostics under a dedicated namespace, which means it shows up everywhere
-- LSP diagnostics do: Trouble, <leader>fd, the statusline workspace count, and
-- the gutter of files you later open.
--
-- Configured per project (in .nvim.lua) via vim.g.typecheck:
--   vim.g.typecheck = {
--     cmd  = "NX_TUI=false npx nx run nexus:typecheck --skip-nx-cache",
--     cwd  = "/abs/path/to/repo",      -- where the command runs
--     root = "/abs/path/to/apps/nexus", -- what tsc's relative paths resolve
--                                       -- against (defaults to cwd)
--   }
local ns = vim.api.nvim_create_namespace("typecheck")

local severities = {
	error = vim.diagnostic.severity.ERROR,
	warning = vim.diagnostic.severity.WARN,
}

-- tsc's non-pretty line format: `src/foo.ts(12,5): error TS2345: message`.
-- Anything else in the stream (nx banners, "Warning: command ... exited") just
-- doesn't match and is dropped.
local function parse(output, root)
	local by_file = {}
	-- A target that runs several tsc passes (e.g. tsconfig.app.json plus
	-- tsconfig.spec.json) emits the same error once per pass for any file both
	-- configs include. Identical file+position+code+message is one error.
	local seen = {}
	for line in output:gmatch("[^\r\n]+") do
		line = line:gsub("\27%[[%d;]*m", "") -- strip ANSI, in case a tty slipped through
		local file, lnum, col, kind, code, msg = line:match("^(.-)%((%d+),(%d+)%):%s*(%a+)%s+(TS%d+):%s*(.+)$")
		if file and not seen[line] then
			seen[line] = true
			local path = file:sub(1, 1) == "/" and file or vim.fs.normalize(root .. "/" .. file)
			by_file[path] = by_file[path] or {}
			table.insert(by_file[path], {
				lnum = tonumber(lnum) - 1,
				col = tonumber(col) - 1,
				severity = severities[kind:lower()] or vim.diagnostic.severity.ERROR,
				message = msg,
				code = code,
				source = "tsc",
			})
		end
	end
	return by_file
end

-- Once ts_ls attaches to a file it publishes its own diagnostics, which would
-- sit on top of ours — same error, twice in the gutter and twice in Trouble.
-- Drop our copy of anything the live server is already reporting, matched on
-- position + code. Errors ts_ls does NOT report (it resolves a different
-- tsconfig than the spec pass) survive, which is the whole point.
local function normalize_code(code)
	return (tostring(code or ""):gsub("^TS", ""))
end

local deduping = false
vim.api.nvim_create_autocmd("DiagnosticChanged", {
	group = vim.api.nvim_create_augroup("typecheck_dedup", { clear = true }),
	callback = function(ev)
		-- set() below re-fires this event; without the guard it recurses.
		if deduping then
			return
		end
		local mine = vim.diagnostic.get(ev.buf, { namespace = ns })
		if #mine == 0 then
			return
		end

		local live = {}
		for _, d in ipairs(vim.diagnostic.get(ev.buf)) do
			if d.namespace ~= ns then
				live[("%d:%d:%s"):format(d.lnum, d.col, normalize_code(d.code))] = true
			end
		end

		local kept = vim.tbl_filter(function(d)
			return not live[("%d:%d:%s"):format(d.lnum, d.col, normalize_code(d.code))]
		end, mine)

		if #kept ~= #mine then
			deduping = true
			vim.diagnostic.set(ns, ev.buf, kept)
			deduping = false
		end
	end,
})

local M = {}

local running -- vim.system handle of the in-flight run
local timer -- debounce timer

-- True from the moment a run is queued until its results are published, so a
-- statusline component can show activity. Counts the debounce window too —
-- otherwise saving would look like nothing happened for a second.
function M.is_running()
	return running ~= nil or timer ~= nil
end

-- Consumers (lualine) listen for this instead of polling on their own timer.
local function notify_state_change()
	vim.api.nvim_exec_autocmds("User", { pattern = "TypecheckStateChanged", modeline = false })
end

-- opts.quiet     suppress notifications (counts still land in the statusline)
-- opts.debounce  ms to wait before starting; a newer call resets the wait
-- opts.clear_buf drop this buffer's results now, before the run
function M.run(opts)
	opts = opts or {}

	-- Without this, a fixed error keeps its marker for the whole run (seconds),
	-- unlike LSP diagnostics which vanish the moment the server re-publishes.
	-- Clearing up front makes the edited file feel live; the run below puts
	-- back anything still broken, here or elsewhere.
	if opts.clear_buf and vim.api.nvim_buf_is_valid(opts.clear_buf) then
		vim.diagnostic.set(ns, opts.clear_buf, {})
		opts = vim.deepcopy(opts)
		opts.clear_buf = nil -- only clear once, not again after the debounce
	end

	if opts.debounce and opts.debounce > 0 then
		if timer then
			timer:stop()
			timer:close()
		end
		timer = vim.uv.new_timer()
		timer:start(
			opts.debounce,
			0,
			vim.schedule_wrap(function()
				if timer then
					timer:stop()
					timer:close()
					timer = nil
				end
				-- NOT tbl_extend(opts, { debounce = nil }): a nil value makes
				-- that an empty table, so debounce would survive and this
				-- would reschedule itself forever without ever running.
				local now = vim.deepcopy(opts)
				now.debounce = nil
				M.run(now)
			end)
		)
		return
	end

	local cfg = vim.g.typecheck
	if not cfg or not cfg.cmd then
		if not opts.quiet then
			vim.notify("typecheck: set vim.g.typecheck = { cmd = ... } in .nvim.lua", vim.log.levels.WARN)
		end
		return
	end
	local cwd = cfg.cwd or vim.fn.getcwd()
	local root = cfg.root or cwd

	-- A save during a run makes the in-flight result stale; kill it rather than
	-- letting two tsc passes race to publish.
	if running then
		pcall(function()
			running:kill(15)
		end)
		running = nil
	end

	if not opts.quiet then
		vim.notify("typecheck: running…")
	end
	-- Non-zero exit is the normal case (that's what "there are errors" means),
	-- so the result is parsed regardless of res.code.
	running = vim.system(
		{ "sh", "-c", cfg.cmd },
		{ cwd = cwd, text = true },
		vim.schedule_wrap(function(res)
			running = nil
			-- SIGTERM from the kill above: a superseded run, not a result.
			if res.signal ~= 0 then
				return
			end

			local by_file = parse((res.stdout or "") .. (res.stderr or ""), root)
			vim.diagnostic.reset(ns)

			local files, total = 0, 0
			for path, diags in pairs(by_file) do
				-- bufadd, not bufload: an unlisted, unloaded buffer is enough to
				-- hold diagnostics, and it keeps a 200-error run from opening 200
				-- real buffers. They render as soon as you open the file.
				vim.diagnostic.set(ns, vim.fn.bufadd(path), diags)
				files = files + 1
				total = total + #diags
			end

			if opts.quiet then
				return
			end
			if total == 0 then
				vim.notify(
					"typecheck: clean" .. (res.code ~= 0 and " (command failed — check the command itself)" or "")
				)
			else
				vim.notify(("typecheck: %d error(s) in %d file(s)"):format(total, files), vim.log.levels.WARN)
			end
		end)
	)
end

vim.api.nvim_create_user_command("Typecheck", function(opts)
	if opts.bang then
		vim.diagnostic.reset(ns)
		vim.notify("typecheck: cleared")
		return
	end
	M.run()
end, { bang = true, desc = "Run the project typecheck, publish results as diagnostics (! to clear)" })

return M
