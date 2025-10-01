return {
	desc = "Notify when compilation output is detected",
	params = {},
	constructor = function()
		local test_result_line = nil
		return {
			on_output_lines = function(self, task, lines)
				for _, line in ipairs(lines) do
					if line:match("Compiling %d+ file") then
						vim.notify(line, vim.log.levels.INFO)
					elseif line:match("Running ExUnit") then
						vim.notify(line, vim.log.levels.INFO)
					elseif line:match("%d+ tests?, %d+ failures?") then
						test_result_line = line
					end
				end
			end,
			on_complete = function(self, task, status, result)
				if test_result_line then
					vim.notify(test_result_line, vim.log.levels.INFO)
				else
					-- Default notification for non-test tasks
					vim.notify(string.format("%s: %s", task.name, status), vim.log.levels.INFO)
				end
			end,
		}
	end,
}
