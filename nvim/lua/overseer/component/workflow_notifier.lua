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
		current_step = 0,
		steps = params.steps or {},
		notif_id = nil,
		on_init = function(self, task)
			self.notif_id = "workflow_" .. task.name
			self:update_notification(task, "running")
		end,
		on_pre_start = function(self, task)
			self:update_notification(task, "running")
		end,
		on_status = function(self, task, status)
			if status == "SUCCESS" then
				self:update_notification(task, "success")
			elseif status == "FAILURE" or status == "CANCELED" then
				self:update_notification(task, "error")
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
					icon = icons.running
				else
					icon = icons.pending
				end
				table.insert(lines, string.format("%s %s", icon, step))
			end

			local level = "info"
			local title_icon = icons.running
			if state == "success" then
				level = "info"
				title_icon = icons.success
			elseif state == "error" then
				level = "error"
				title_icon = icons.error
			end

			vim.notify(table.concat(lines, "\n"), level, {
				id = self.notif_id,
				title = title_icon .. " " .. task.name,
				timeout = state == "success" and 5000 or false,
			})
		end,
		on_dependency_complete = function(self, task, dep_task, status)
			-- Increment step when a dependency completes successfully
			if status == "SUCCESS" then
				self.current_step = self.current_step + 1
				self:update_notification(task, "running")
			end
		end,
	}
end

return M
