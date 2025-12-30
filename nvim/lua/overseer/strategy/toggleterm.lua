local log = require("overseer.log")

---@class overseer.ToggletermStrategy : overseer.Strategy
---@field term nil|table The toggleterm Terminal instance
---@field task nil|overseer.Task
---@field opts overseer.ToggletrmStrategyOpts
---@field _has_exited boolean Track if terminal job has exited to prevent double-shutdown
local ToggletrmStrategy = {}

---@class (exact) overseer.ToggletrmStrategyOpts
---@field direction? "horizontal"|"vertical"|"tab"|"float" Direction of the terminal window
---@field close_on_exit? boolean Close the terminal window when task exits
---@field open_on_start? boolean Open the terminal when task starts
---@field quit_on_exit? "never"|"success"|"always" When to quit the terminal
---@field hidden? boolean If true, don't render the task in the toggleable window

---Run tasks using toggleterm
---@param opts nil|overseer.ToggletrmStrategyOpts
---@return overseer.Strategy
function ToggletrmStrategy.new(opts)
	opts = vim.tbl_extend("keep", opts or {}, {
		direction = "float",
		close_on_exit = false,
		open_on_start = true,
		quit_on_exit = "never",
		hidden = false,
	})

	local strategy = {
		term = nil,
		task = nil,
		opts = opts,
		_has_exited = false,
	}
	setmetatable(strategy, { __index = ToggletrmStrategy })
	---@type overseer.ToggletrmStrategy
	return strategy
end

function ToggletrmStrategy:reset()
	if self.term then
		self.term:shutdown()
		self.term = nil
	end
	self.task = nil
end

function ToggletrmStrategy:get_bufnr()
	if self.term then
		return self.term.bufnr
	end
	return nil
end

---@param task overseer.Task
function ToggletrmStrategy:start(task)
	local ok, Terminal = pcall(require, "toggleterm.terminal")
	if not ok then
		log.error("toggleterm.nvim is not installed. Cannot use toggleterm strategy.")
		return
	end

	self.task = task

	-- Build the command string
	local cmd = task.cmd
	if type(cmd) == "table" then
		-- Escape and join the command parts
		cmd = table.concat(
			vim.tbl_map(function(part)
				return vim.fn.shellescape(part)
			end, cmd),
			" "
		)
	end

	-- Create the terminal
	self.term = Terminal.Terminal:new({
		cmd = cmd,
		direction = self.opts.direction,
		close_on_exit = self.opts.close_on_exit,
		hidden = self.opts.hidden,
		dir = task.cwd,
		env = task.env,
		on_stdout = function(_, job, data)
			if data then
				task:dispatch("on_output", data)
			end
		end,
		on_stderr = function(_, job, data)
			if data then
				task:dispatch("on_output", data)
			end
		end,
		on_exit = function(term, job, exit_code, name)
			log.debug("Task %s exited with code %s", task.name, exit_code)

			-- Handle quit_on_exit option
			if self.opts.quit_on_exit == "always" then
				term:close()
			elseif self.opts.quit_on_exit == "success" and exit_code == 0 then
				term:close()
			end

			-- Notify the task that it has exited
			if vim.v.exiting == vim.NIL then
				---@diagnostic disable-next-line: invisible
				task:on_exit(exit_code)
			end
		end,
	})

	-- Open the terminal if requested
	if self.opts.open_on_start then
		self.term:open()
	end
end

function ToggletrmStrategy:stop()
	if self.term then
		self.term:shutdown()
	end
end

function ToggletrmStrategy:dispose()
	if self.term then
		self.term:shutdown()
		self.term = nil
	end
	self.task = nil
end

return ToggletrmStrategy
