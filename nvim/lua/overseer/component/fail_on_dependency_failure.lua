local task_list = require("overseer.task_list")
local constants = require("overseer.constants")
local STATUS = constants.STATUS

local M = {}

---@type overseer.ComponentFileDefinition
M.desc = "Set task status to FAILURE when any dependency fails"

M.constructor = function()
	return {
		on_pre_start = function(self, task)
			-- Check if any dependency has failed
			local deps_component
			for _, comp in ipairs(task.components) do
				if comp.desc and comp.desc:match("^Set dependencies") then
					deps_component = comp
					break
				end
			end

			if deps_component and deps_component.task_lookup then
				for _, task_id in ipairs(deps_component.task_lookup) do
					local dep_task = task_list.get(task_id)
					if dep_task and (dep_task.status == STATUS.FAILURE or dep_task.status == STATUS.CANCELED) then
						-- Mark parent as failed and stop
						task:set_status(STATUS.FAILURE)
						return false
					end
				end
			end

			-- Let other components proceed
			return true
		end,
	}
end

return M
