local M = {}

---@type overseer.ComponentFileDefinition
M.desc = "Forward orchestrator updates to workflow_notifier"

M.constructor = function()
	return {
		on_orchestrator_broadcast = function(self, task)
			-- Find workflow_notifier component and trigger update
			for _, comp in ipairs(task.components) do
				if comp.on_orchestrator_update then
					comp:on_orchestrator_update(task)
				end
			end
		end,
	}
end

return M
