return {
	desc = "Notify when compilation output is detected",
	params = {},
	constructor = function()
		local test_result_line = nil
		local compiling_notification = nil
		return {
			on_output_lines = function(self, task, lines)
				for _, line in ipairs(lines) do
					if line:match("Compiling %d+ file") then
						compiling_notification = vim.notify(line, vim.log.levels.INFO, {
							timeout = false,
							hide_from_history = true,
						})
					elseif line:match("Generated %w+ app") then
						if compiling_notification then
							vim.notify("Compilation complete", vim.log.levels.INFO, {
								replace = compiling_notification,
								timeout = 3000,
							})
							compiling_notification = nil
						end
					elseif line:match("== Compilation error") then
						if compiling_notification then
							vim.notify("Compilation error", vim.log.levels.ERROR, {
								replace = compiling_notification,
								timeout = 3000,
							})
							compiling_notification = nil
						end
					elseif line:match("Running ExUnit") then
						vim.notify(line, vim.log.levels.INFO)
					elseif line:match("%d+ tests?, %d+ failures?") then
						test_result_line = line
					end
				end
			end,
			on_complete = function(self, task, status, result)
				-- Dismiss compiling notification if still active
				if compiling_notification then
					require("notify").dismiss({ silent = true, pending = true })
					compiling_notification = nil
				end

				if test_result_line then
					vim.notify(test_result_line, vim.log.levels.INFO)
				end
			end,
		}
	end,
}
