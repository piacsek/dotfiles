local constants = require("overseer.constants")
local STATUS = constants.STATUS

local M = {}

---@type overseer.ComponentFileDefinition
M.desc = "Set task status to FAILURE when any dependency fails"

M.constructor = function()
	return {
		on_dependency_complete = function(self, task, dep_task, status)
			-- If dependency failed or was canceled, mark parent as failed
			if status == STATUS.FAILURE or status == STATUS.CANCELED then
				task:set_status(STATUS.FAILURE)
			end
		end,
	}
end

return M
