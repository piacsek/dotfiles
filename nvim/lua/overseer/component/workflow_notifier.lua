local M = {}

---@type overseer.ComponentFileDefinition
M.desc = "Show a persistent notification that updates as workflow steps complete"

M.params = {
	steps = {
		desc = "List of step names in the workflow",
		type = "list",
		default = {},
	},
}

M.constructor = function(params)
	return {
		current_step = 1,
		steps = params.steps or {},
		notif_id = nil,
		completed_deps = {},
		has_shown_final = false,
		on_init = function(self, task)
			self.notif_id = "workflow_" .. task.name
			self:update_notification(task, "running")
		end,
		on_pre_start = function(self, task)
			self.current_step = 1
			self.completed_deps = {}
			self.has_shown_final = false
			self:update_notification(task, "running")
		end,
		on_status = function(self, task, status)
			if self.has_shown_final then
				return
			end

			if status == "SUCCESS" then
				-- Mark all steps as complete
				self.current_step = #self.steps + 1
				self:update_notification(task, "success")
				self.has_shown_final = true
			elseif status == "FAILURE" or status == "CANCELED" then
				self:update_notification(task, "error")
				self.has_shown_final = true
			end
		end,
		update_notification = function(self, task, state)
			local icons = {
				running = "⏳",
				success = "✓",
				error = "✗",
				pending = "○",
			}

			-- Build the step status display
			local lines = {}
			for i, step in ipairs(self.steps) do
				local icon
				if i < self.current_step then
					icon = icons.success
				elseif i == self.current_step then
					icon = state == "error" and icons.error or icons.running
				else
					icon = icons.pending
				end
				table.insert(lines, string.format("%s %s", icon, step))
			end

			local level = vim.log.levels.INFO
			local title_icon = icons.running
			local timeout = false -- Keep visible by default

			if state == "success" then
				title_icon = icons.success
				timeout = 3000 -- Auto-dismiss after 3 seconds
			elseif state == "error" then
				level = vim.log.levels.ERROR
				title_icon = icons.error
				timeout = 5000 -- Auto-dismiss errors after 5 seconds
			end

			vim.notify(table.concat(lines, "\n"), level, {
				id = self.notif_id,
				title = title_icon .. " " .. task.name,
				timeout = timeout,
			})
		end,
		on_output = function(self, task, data)
			-- Check if output indicates a dependency completed
			for _, line in ipairs(data) do
				if line:match("^SUCCESS:") or line:match("^FAILURE:") then
					local dep_name = line:match("^%w+:%s*(.+)")
					if dep_name and not self.completed_deps[dep_name] then
						self.completed_deps[dep_name] = true
						if line:match("^SUCCESS:") and self.current_step <= #self.steps then
							self.current_step = self.current_step + 1
							self:update_notification(task, "running")
						end
					end
				end
			end
		end,
	}
end

return M
