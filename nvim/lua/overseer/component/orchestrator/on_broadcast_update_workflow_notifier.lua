local M = {}

---@type overseer.ComponentFileDefinition
M.desc = "Forward orchestrator updates to workflow_notifier"

M.constructor = function()
	return {
		on_other_task_status = function(self, task, other_task)
			-- Only process if this is an orchestrator task and other_task is a subtask
			if task.strategy and task.strategy.name == "orchestrator" then
				-- Find workflow_notifier component and trigger update
				for _, comp in ipairs(task.components) do
					if comp.on_orchestrator_update then
						comp:on_orchestrator_update(task)
					end
				end
			end
		end,
	}
end

return M
