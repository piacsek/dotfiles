return {
	desc = "Notify when compilation output is detected",
	params = {},
	constructor = function()
		local test_result_line = nil
		local current_notification = nil
		local has_error = false
		local notification_title = nil
		return {
			on_start = function(self, task)
				notification_title = task.name
				current_notification = vim.notify(
					"Initializing...",
					vim.log.levels.INFO,
					{ title = notification_title, timeout = false, hide_from_history = true }
				)
			end,
			on_output_lines = function(self, task, lines)
				for _, line in ipairs(lines) do
					if line:match("Compiling %d+ file") then
						current_notification = vim.notify(line, vim.log.levels.INFO, {
							timeout = false,
							hide_from_history = true,
						})
					elseif line:match("Generated %w+ app") then
						current_notification =
							vim.notify("Compilation succeeded. Starting ExUnit...", vim.log.levels.INFO, {
								replace = current_notification,
								timeout = false,
								hide_from_history = true,
							})
					elseif line:match("== Compilation error") then
						has_error = true
						current_notification = vim.notify("Compilation error.", vim.log.levels.ERROR, {
							replace = current_notification,
							timeout = 3000,
						})
					elseif line:match("Running ExUnit") then
						current_notification = vim.notify("Running ExUnit...", vim.log.levels.INFO, {
							replace = current_notification,
							timeout = false,
							hide_from_history = true,
						})
					elseif line:match("%d+ tests?, %d+ failures?") then
						test_result_line = line
					end
				end
			end,
			on_complete = function(self, task, status, result)
				if has_error then
					has_error = false
					return
				elseif test_result_line then
					local level = vim.log.levels.INFO
					if status == "FAILURE" then
						level = vim.log.levels.ERROR
					end
					vim.notify(test_result_line, level, {
						replace = current_notification,
						timeout = 3000,
					})
					current_notification = nil
				elseif current_notification then
					-- Dismiss notification if still active and no test results
					require("notify").dismiss({ silent = true, pending = true })
					current_notification = nil
				end
			end,
		}
	end,
}
