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
	for line in output:gmatch("[^\r\n]+") do
		line = line:gsub("\27%[[%d;]*m", "") -- strip ANSI, in case a tty slipped through
		local file, lnum, col, kind, code, msg = line:match("^(.-)%((%d+),(%d+)%):%s*(%a+)%s+(TS%d+):%s*(.+)$")
		if file then
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

-- opts.quiet    suppress notifications (counts still land in the statusline)
-- opts.debounce ms to wait before starting; a newer call resets the wait
function M.run(opts)
	opts = opts or {}

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
				M.run(vim.tbl_extend("force", opts, { debounce = nil }))
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
