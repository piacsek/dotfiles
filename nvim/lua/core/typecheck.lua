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

vim.api.nvim_create_user_command("Typecheck", function(opts)
	if opts.bang then
		vim.diagnostic.reset(ns)
		vim.notify("typecheck: cleared")
		return
	end

	local cfg = vim.g.typecheck
	if not cfg or not cfg.cmd then
		vim.notify("typecheck: set vim.g.typecheck = { cmd = ... } in .nvim.lua", vim.log.levels.WARN)
		return
	end
	local cwd = cfg.cwd or vim.fn.getcwd()
	local root = cfg.root or cwd

	vim.notify("typecheck: running…")
	-- Non-zero exit is the normal case (that's what "there are errors" means),
	-- so the result is parsed regardless of res.code.
	vim.system(
		{ "sh", "-c", cfg.cmd },
		{ cwd = cwd, text = true },
		vim.schedule_wrap(function(res)
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

			if total == 0 then
				vim.notify(
					"typecheck: clean" .. (res.code ~= 0 and " (command failed — check the command itself)" or "")
				)
			else
				vim.notify(("typecheck: %d error(s) in %d file(s)"):format(total, files), vim.log.levels.WARN)
			end
		end)
	)
end, { bang = true, desc = "Run the project typecheck, publish results as diagnostics (! to clear)" })
