local constants = require("overseer.constants")
local task_list = require("overseer.task_list")
local STATUS = constants.STATUS

local M = {}

---@type overseer.ComponentFileDefinition
M.desc = "Notify parent task when this task fails"

M.params = {
	parent_id = {
		desc = "ID of the parent task to notify",
		type = "integer",
	},
}

M.constructor = function(params)
	return {
		on_status = function(self, task, status)
			if status == STATUS.FAILURE or status == STATUS.CANCELED then
				local parent = task_list.get(params.parent_id)
				if parent then
					parent:set_status(STATUS.FAILURE)
				end
			end
		end,
	}
end

return M
