return {
	desc = "Notify on pattern matches in task output",
	params = {
		patterns = {
			desc = "List of patterns to match and notify on",
			type = "list",
			subtype = {
				type = "object",
				fields = {
					pattern = {
						desc = "Lua pattern to match",
						type = "string",
					},
					message = {
						desc = "Message to show (can include %1, %2 for captures). If nil, shows the matched line.",
						type = "string",
						optional = true,
					},
					level = {
						desc = "Log level (INFO, WARN, ERROR)",
						type = "string",
						default = "INFO",
						optional = true,
					},
					once = {
						desc = "Only notify on first match",
						type = "boolean",
						default = false,
						optional = true,
					},
				},
			},
			default = {},
		},
		show_spinner = {
			desc = "Show animated spinner",
			type = "boolean",
			default = true,
		},
	},
	constructor = function(params)
		local uv = vim.loop
		local notify = require("notify")

		local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
		local spinner_i = 1
		local spinner_timer = nil

		local current_notification = nil
		local current_msg = nil
		local notification_title = nil
		local start_time = nil
		local default_initial_message = "   Starting..."
		local default_completion_success_message = "   Finished successfully!"
		local default_completion_failure_message = "   Error!"
		local render_mode = "wrapped-default"
		local matched_patterns = {}

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
			return format_elapsed_time() .. " " .. notification_title
		end

		local function start_spinner()
			if not params.show_spinner or spinner_timer then
				return
			end
			spinner_timer = uv.new_timer()
			spinner_timer:start(0, 80, function()
				vim.schedule(function()
					if not current_notification then
						return
					end
					spinner_i = (spinner_i % #spinner_frames) + 1
					current_notification = notify(current_msg, vim.log.levels.INFO, {
						render = render_mode,
						title = get_title_with_timer(),
						icon = spinner_frames[spinner_i],
						replace = current_notification,
						timeout = false,
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
				current_msg = default_initial_message
				if params.show_spinner then
					current_notification = vim.notify(current_msg, vim.log.levels.INFO, {
						render = render_mode,
						title = get_title_with_timer(),
						icon = spinner_frames[spinner_i],
						timeout = false,
					})
					start_spinner()
				end
			end,

			on_output_lines = function(self, task, lines)
				for _, line in ipairs(lines) do
					for i, pattern_config in ipairs(params.patterns) do
						local pattern = pattern_config.pattern
						local captures = { line:match(pattern) }

						if #captures > 0 then
							-- Check if we should skip (once=true and already matched)
							if pattern_config.once and matched_patterns[i] then
								goto continue
							end
							matched_patterns[i] = true

							-- Format message
							local msg
							if pattern_config.message then
								msg = pattern_config.message:gsub("%%(%d+)", function(n)
									return captures[tonumber(n)] or ""
								end)
							else
								msg = line
							end

							current_msg = "   " .. msg

							-- Determine level
							local level = vim.log.levels.INFO
							if pattern_config.level == "WARN" then
								level = vim.log.levels.WARN
							elseif pattern_config.level == "ERROR" then
								level = vim.log.levels.ERROR
							end

							-- Show notification
							current_notification = notify(current_msg, level, {
								render = render_mode,
								title = get_title_with_timer(),
								icon = params.show_spinner and spinner_frames[spinner_i] or nil,
								replace = current_notification,
								timeout = false,
							})
						end
						::continue::
					end
				end
			end,

			on_complete = function(self, task, status, result)
				stop_spinner()
				if current_notification then
					local level = vim.log.levels.INFO
					local icon = "󰄬"
					local fallback_message = default_completion_success_message

					if status == "FAILURE" then
						level = vim.log.levels.ERROR
						icon = ""
						fallback_message = default_completion_failure_message
					end

					final_message = current_msg
					if final_message == default_initial_message then
						final_message = fallback_message
					end

					vim.notify(final_message, level, {
						render = render_mode,
						title = get_title_with_timer(),
						icon = icon,
						replace = current_notification,
						timeout = 3000,
					})
				end
				current_notification = nil
				current_msg = nil
				start_time = nil
				matched_patterns = {}
			end,
		}
	end,
}
