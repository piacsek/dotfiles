return {
	desc = "Notify when compilation output is detected",
	params = {},
	constructor = function()
		local uv = vim.loop
		local notify = require("notify")

		-- SPINNER: frames + state
		local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		local spinner_i = 1
		local spinner_timer = nil

		local test_result_line = nil
		local current_notification = nil
		local current_msg = nil
		local has_error = false
		local notification_title = nil
		local left_pad = "   "
		local start_time = nil

		local function set_current_formatted_msg(message)
			current_msg = left_pad .. message
		end

		local function set_test_result_line(message)
			test_result_line = left_pad .. message
		end

		local function format_elapsed_time()
			if not start_time then
				return "0s"
			end
			local elapsed = os.time() - start_time
			if elapsed < 60 then
				return string.format("%ds", elapsed)
			else
				local minutes = math.floor(elapsed / 60)
				local seconds = elapsed % 60
				return string.format("%dm %ds", minutes, seconds)
			end
		end

		local function get_title_with_timer()
			return notification_title .. string.rep(" ", 20) .. format_elapsed_time()
		end

		-- SPINNER: start/stop helpers
		local function start_spinner()
			if spinner_timer then
				return
			end
			spinner_timer = uv.new_timer()
			spinner_timer:start(0, 80, function()
				vim.schedule(function()
					if not current_notification then
						return
					end
					spinner_i = (spinner_i % #spinner_frames) + 1
					-- re-post same message but only update the icon frame
					current_notification = notify(current_msg or "Working…", vim.log.levels.INFO, {
						render = "default",
						title = get_title_with_timer(),
						icon = spinner_frames[spinner_i],
						replace = current_notification,
						timeout = false,
						hide_from_history = true,
					})
				end)
			end)
		end

		local function stop_spinner()
			if spinner_timer then
				spinner_timer:stop()
				spinner_timer:close()
				spinner_timer = nil
			end
		end

		return {
			on_start = function(self, task)
				notification_title = task.name
				start_time = os.time()
				set_current_formatted_msg("Initializing...")
				current_notification = vim.notify(current_msg, vim.log.levels.INFO, {
					render = "default",
					title = get_title_with_timer(),
					icon = spinner_frames[spinner_i],
					timeout = false,
					hide_from_history = true,
				})
				start_spinner() -- SPINNER: begin
			end,

			on_output_lines = function(self, task, lines)
				for _, line in ipairs(lines) do
					if line:match("Compiling %d+ file") then
						set_current_formatted_msg(line)
						current_notification = vim.notify(current_msg, vim.log.levels.INFO, {
							render = "default",
							title = get_title_with_timer(),
							icon = spinner_frames[spinner_i], -- keep spinner going
							replace = current_notification,
							timeout = false,
							hide_from_history = true,
						})
					elseif line:match("Generated %w+ app") then
						set_current_formatted_msg("Compilation succeeded. Starting ExUnit...")
						current_notification = vim.notify(current_msg, vim.log.levels.INFO, {
							render = "default",
							title = get_title_with_timer(),
							icon = spinner_frames[spinner_i],
							replace = current_notification,
							timeout = false,
							hide_from_history = true,
						})
					elseif line:match("== Compilation error") then
						set_current_formatted_msg("Compilation error!")
						has_error = true
						stop_spinner() -- SPINNER: stop on hard error
						current_notification = vim.notify(current_msg, vim.log.levels.ERROR, {
							render = "default",
							title = get_title_with_timer(),
							replace = current_notification,
							timeout = 3000,
						})
					elseif line:match("Running ExUnit") then
						set_current_formatted_msg("Running ExUnit...")
						current_notification = vim.notify(current_msg, vim.log.levels.INFO, {
							render = "default",
							title = get_title_with_timer(),
							icon = spinner_frames[spinner_i],
							replace = current_notification,
							timeout = false,
							hide_from_history = true,
						})
					elseif line:match("%d+ tests?, %d+ failures?") then
						set_test_result_line(line)
					end
				end
			end,

			on_complete = function(self, task, status, result)
				if has_error then
					stop_spinner()
					has_error = false
					start_time = nil
					return
				elseif test_result_line then
					stop_spinner()
					local level = vim.log.levels.INFO
					local icon = "✓"
					if status == "FAILURE" then
						level = vim.log.levels.ERROR
						icon = "x"
					end
					vim.notify(test_result_line, level, {
						render = "default",
						title = get_title_with_timer(),
						icon = icon,
						replace = current_notification,
						timeout = 3000,
					})
					current_notification = nil
					current_msg = nil
					start_time = nil
				elseif current_notification then
					stop_spinner() -- ensure no stray timer
					-- Dismiss notification if still active and no test results
					require("notify").dismiss({ silent = true, pending = true })
					current_notification = nil
					current_msg = nil
					start_time = nil
				end
			end,
		}
	end,
}
