-- Project-wide diagnostics from real command-line checkers (tsc, eslint, …).
--
-- Language servers like ts_ls are single-file: a problem in a file you never
-- opened is invisible. This runs the project's own checkers asynchronously and
-- publishes their output as diagnostics, so results show up everywhere LSP
-- diagnostics do: Trouble, <leader>fd, the statusline counts, and the gutter of
-- files you later open.
--
-- Configured per project (in .nvim.lua) as a list of checkers, each of which
-- gets its own namespace and runs in parallel with the others:
--   vim.g.typecheck = {
--     { name = "tsc",  cmd = "…", cwd = "/repo", root = "/repo/apps/nexus", format = "tsc" },
--     { name = "lint", cmd = "…", cwd = "/repo/apps/nexus",                 format = "unix" },
--   }
-- `root` is what relative paths in the output resolve against (defaults to
-- cwd); `format` selects the parser. A single table with a `cmd` key is also
-- accepted and treated as one tsc checker.
local M = {}

local severities = {
	error = vim.diagnostic.severity.ERROR,
	warning = vim.diagnostic.severity.WARN,
}

-- name -> { ns, running, timer }
local state = {}

local function checker_state(name)
	if not state[name] then
		state[name] = { ns = vim.api.nvim_create_namespace("typecheck:" .. name) }
	end
	return state[name]
end

--- Normalize vim.g.typecheck into a list of checkers.
local function checkers()
	local cfg = vim.g.typecheck
	if not cfg then
		return {}
	end
	if cfg.cmd then -- single-checker shorthand
		return { vim.tbl_extend("keep", cfg, { name = "tsc", format = "tsc" }) }
	end
	local list = {}
	for i, c in ipairs(cfg) do
		if c.cmd then
			list[#list + 1] = vim.tbl_extend("keep", c, { name = "check" .. i, format = "tsc" })
		end
	end
	return list
end

local function resolve(path, root)
	return path:sub(1, 1) == "/" and path or vim.fs.normalize(root .. "/" .. path)
end

-- tsc, non-pretty: `src/foo.ts(12,5): error TS2345: message`
local function parse_tsc(line, root)
	local file, lnum, col, kind, code, msg = line:match("^(.-)%((%d+),(%d+)%):%s*(%a+)%s+(TS%d+):%s*(.+)$")
	if not file then
		return nil
	end
	return resolve(file, root),
		{
			lnum = tonumber(lnum) - 1,
			col = tonumber(col) - 1,
			severity = severities[kind:lower()] or vim.diagnostic.severity.ERROR,
			message = msg,
			code = code,
			source = "tsc",
		}
end

-- eslint --format unix: `/abs/foo.ts:12:5: message [Error/rule-name]`
local function parse_unix(line, root)
	local file, lnum, col, msg, kind, rule = line:match("^(.-):(%d+):(%d+):%s*(.-)%s*%[(%a+)/(.-)%]$")
	if not file then
		return nil
	end
	return resolve(file, root),
		{
			lnum = tonumber(lnum) - 1,
			col = tonumber(col) - 1,
			severity = severities[kind:lower()] or vim.diagnostic.severity.WARN,
			message = msg,
			code = rule,
			source = "eslint",
		}
end

local parsers = { tsc = parse_tsc, unix = parse_unix }

local function parse(output, format, root)
	local parse_line = parsers[format] or parse_tsc
	local by_file = {}
	-- A target running several passes (e.g. tsconfig.app.json plus
	-- tsconfig.spec.json) emits the same problem once per pass for any file both
	-- include. An identical raw line is one problem.
	local seen = {}
	for line in output:gmatch("[^\r\n]+") do
		line = line:gsub("\27%[[%d;]*m", "") -- strip ANSI, in case a tty slipped through
		if not seen[line] then
			seen[line] = true
			local path, diag = parse_line(line, root)
			if path then
				by_file[path] = by_file[path] or {}
				table.insert(by_file[path], diag)
			end
		end
	end
	return by_file
end

--- True while any checker is queued or in flight.
function M.is_running()
	for _, s in pairs(state) do
		if s.running or s.timer then
			return true
		end
	end
	return false
end

--- Names of the checkers currently working, for a statusline label.
function M.running_names()
	local names = {}
	for name, s in pairs(state) do
		if s.running or s.timer then
			names[#names + 1] = name
		end
	end
	table.sort(names)
	return names
end

-- Consumers (lualine) listen for this instead of polling on their own timer.
local function notify_state_change()
	vim.api.nvim_exec_autocmds("User", { pattern = "TypecheckStateChanged", modeline = false })
end

local function start(checker, opts)
	local s = checker_state(checker.name)
	local cwd = checker.cwd or vim.fn.getcwd()
	local root = checker.root or cwd

	-- A save during a run makes the in-flight result stale; kill it rather than
	-- letting two passes race to publish.
	if s.running then
		pcall(function()
			s.running:kill(15)
		end)
		s.running = nil
	end

	-- Non-zero exit is the normal case (that's what "there are problems" means),
	-- so the result is parsed regardless of res.code.
	local handle = vim.system(
		{ "sh", "-c", checker.cmd },
		{ cwd = cwd, text = true },
		vim.schedule_wrap(function(res)
			s.running = nil
			notify_state_change()
			-- SIGTERM from the kill above: a superseded run, not a result.
			if res.signal ~= 0 then
				return
			end

			local by_file = parse((res.stdout or "") .. (res.stderr or ""), checker.format, root)
			vim.diagnostic.reset(s.ns)

			local files, total = 0, 0
			for path, diags in pairs(by_file) do
				-- bufadd, not bufload: an unlisted, unloaded buffer is enough to
				-- hold diagnostics, and it keeps a 200-problem run from opening
				-- 200 real buffers. They render as soon as you open the file.
				vim.diagnostic.set(s.ns, vim.fn.bufadd(path), diags)
				files = files + 1
				total = total + #diags
			end

			if opts.quiet then
				return
			end
			if total == 0 then
				vim.notify(
					("%s: clean"):format(checker.name)
						.. (res.code ~= 0 and " (command failed — check the command itself)" or "")
				)
			else
				vim.notify(("%s: %d problem(s) in %d file(s)"):format(checker.name, total, files), vim.log.levels.WARN)
			end
		end)
	)
	s.running = handle
	notify_state_change()
end

-- opts.quiet     suppress notifications (counts still land in the statusline)
-- opts.debounce  ms to wait before starting; a newer call resets the wait
-- opts.clear_buf drop this buffer's results now, before the run
-- opts.name      run only this checker (default: all of them, in parallel)
function M.run(opts)
	opts = opts or {}

	local list = checkers()
	if #list == 0 then
		if not opts.quiet then
			vim.notify("typecheck: set vim.g.typecheck in .nvim.lua", vim.log.levels.WARN)
		end
		return
	end
	if opts.name then
		list = vim.tbl_filter(function(c)
			return c.name == opts.name
		end, list)
	end

	-- Without this, a fixed problem keeps its marker for the whole run (seconds),
	-- unlike LSP diagnostics which vanish the moment the server re-publishes.
	-- Clearing up front makes the edited file feel live; the runs below put back
	-- anything still broken, here or elsewhere.
	if opts.clear_buf and vim.api.nvim_buf_is_valid(opts.clear_buf) then
		for _, c in ipairs(list) do
			vim.diagnostic.set(checker_state(c.name).ns, opts.clear_buf, {})
		end
	end

	for _, checker in ipairs(list) do
		local s = checker_state(checker.name)
		if opts.debounce and opts.debounce > 0 then
			if s.timer then
				s.timer:stop()
				s.timer:close()
			end
			s.timer = vim.uv.new_timer()
			notify_state_change()
			s.timer:start(
				opts.debounce,
				0,
				vim.schedule_wrap(function()
					if s.timer then
						s.timer:stop()
						s.timer:close()
						s.timer = nil
					end
					start(checker, opts)
				end)
			)
		else
			start(checker, opts)
		end
	end
end

-- Once a language server attaches to a file it publishes its own diagnostics,
-- which would sit on top of ours — same problem, twice in the gutter and twice
-- in Trouble. Drop our copy of anything a live server already reports, matched
-- on position + code. Problems the server does NOT report (it resolves a
-- different tsconfig, or doesn't run eslint at all) survive, which is the point.
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
		local mine = {}
		for _, s in pairs(state) do
			if #vim.diagnostic.get(ev.buf, { namespace = s.ns }) > 0 then
				mine[#mine + 1] = s.ns
			end
		end
		if #mine == 0 then
			return
		end

		local ours = {}
		for _, ns in ipairs(mine) do
			ours[ns] = true
		end
		local live = {}
		for _, d in ipairs(vim.diagnostic.get(ev.buf)) do
			if not ours[d.namespace] then
				live[("%d:%d:%s"):format(d.lnum, d.col, normalize_code(d.code))] = true
			end
		end

		for _, ns in ipairs(mine) do
			local diags = vim.diagnostic.get(ev.buf, { namespace = ns })
			local kept = vim.tbl_filter(function(d)
				return not live[("%d:%d:%s"):format(d.lnum, d.col, normalize_code(d.code))]
			end, diags)
			if #kept ~= #diags then
				deduping = true
				vim.diagnostic.set(ns, ev.buf, kept)
				deduping = false
			end
		end
	end,
})

vim.api.nvim_create_user_command("Typecheck", function(opts)
	if opts.bang then
		for _, s in pairs(state) do
			vim.diagnostic.reset(s.ns)
		end
		vim.notify("typecheck: cleared")
		return
	end
	M.run({ name = opts.args ~= "" and opts.args or nil })
end, {
	bang = true,
	nargs = "?",
	complete = function()
		return vim.tbl_map(function(c)
			return c.name
		end, checkers())
	end,
	desc = "Run the project checkers, publish results as diagnostics (! to clear)",
})

return M
