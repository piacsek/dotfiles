local task_list = require("overseer.task_list")
local constants = require("overseer.constants")
local STATUS = constants.STATUS

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
		steps = params.steps or {},
		notif_id = nil,
		has_shown_final = false,
		initialized = false,
		on_init = function(self, task)
			self.notif_id = "workflow_" .. task.name
			self.initialized = true
			self:update_notification(task)
		end,
		on_start = function(self, task)
			if not self.initialized then
				self.notif_id = "workflow_" .. task.name
				self.initialized = true
			end
			self:update_notification(task)
		end,
		on_status = function(self, task, status)
			if self.has_shown_final then
				return
			end

			if status == STATUS.SUCCESS or status == STATUS.FAILURE or status == STATUS.CANCELED then
				self.has_shown_final = true
				self:update_notification(task)
			end
		end,
		-- Hook into orchestrator's broadcast system
		on_orchestrator_update = function(self, task)
			self:update_notification(task)
		end,
		update_notification = function(self, task)
			local icons = {
				running = "⏳",
				success = "✅",
				error = "✗",
				pending = "○",
			}

			-- Get task list from orchestrator strategy
			local completed_count = 0
			local failed_step = nil

			if task.strategy and task.strategy.tasks then
				-- Orchestrator stores tasks as 2D array (sections)
				-- Flatten it to get sequential task IDs
				for section_idx, section in ipairs(task.strategy.tasks) do
					for _, task_id in ipairs(section) do
						local subtask = task_list.get(task_id)
						if subtask then
							if subtask.status == STATUS.SUCCESS then
								completed_count = completed_count + 1
							elseif subtask.status == STATUS.FAILURE or subtask.status == STATUS.CANCELED then
								-- Map section index to step number
								failed_step = section_idx
								break
							end
						end
					end
					if failed_step then
						break
					end
				end
			end

			-- Build the step status display
			local lines = {}
			local current_step = completed_count + 1
			local all_done = task.status == STATUS.SUCCESS or task.status == STATUS.FAILURE or task.status == STATUS.CANCELED
			local has_failure = failed_step ~= nil or task.status == STATUS.FAILURE or task.status == STATUS.CANCELED

			for i, step in ipairs(self.steps) do
				local icon
				if i < current_step and not failed_step then
					icon = icons.success
				elseif failed_step and i == failed_step then
					icon = icons.error
				elseif i < (failed_step or current_step) then
					icon = icons.success
				elseif all_done and task.status == STATUS.SUCCESS then
					icon = icons.success
				elseif i == current_step and not all_done and not failed_step then
					icon = icons.running
				else
					icon = icons.pending
				end
				table.insert(lines, string.format("%s %s", icon, step))
			end

			-- Determine notification level and timeout
			local level = vim.log.levels.INFO
			local title_icon = icons.running
			local timeout = false

			if task.status == STATUS.SUCCESS or (all_done and not has_failure) then
				title_icon = icons.success
				timeout = 3000
			elseif has_failure then
				level = vim.log.levels.ERROR
				title_icon = icons.error
				timeout = 5000
			end

			vim.notify(table.concat(lines, "\n"), level, {
				id = self.notif_id,
				title = title_icon .. " " .. task.name,
				timeout = timeout,
			})
		end,
		on_dependency_complete = function(self, task)
			self:update_notification(task)

			-- Check if all dependencies are complete
			local deps_component
			for _, comp in ipairs(task.components) do
				if comp.desc and comp.desc:match("dependencies") then
					deps_component = comp
					break
				end
			end

			if deps_component and deps_component.task_lookup then
				local all_done = true
				for _, task_id in ipairs(deps_component.task_lookup) do
					local dep_task = task_list.get(task_id)
					if not dep_task or (dep_task.status ~= STATUS.SUCCESS and dep_task.status ~= STATUS.FAILURE and dep_task.status ~= STATUS.CANCELED) then
						all_done = false
						break
					end
				end

				-- If all dependencies are done, show final notification and mark task as complete
				if all_done and not self.has_shown_final then
					self.has_shown_final = true
					-- Wait a moment then show final status
					vim.defer_fn(function()
						if task.status == STATUS.PENDING then
							-- Check if any dependency failed
							local has_failure = false
							for _, task_id in ipairs(deps_component.task_lookup) do
								local dep_task = task_list.get(task_id)
								if dep_task and (dep_task.status == STATUS.FAILURE or dep_task.status == STATUS.CANCELED) then
									has_failure = true
									break
								end
							end

							-- Set task status
							if has_failure then
								task:set_status(STATUS.FAILURE)
							else
								task:set_status(STATUS.SUCCESS)
								-- Show success notification
								local icons = { success = "✅" }
								vim.notify(table.concat(vim.tbl_map(function(step)
									return string.format("%s %s", icons.success, step)
								end, self.steps), "\n"), vim.log.levels.INFO, {
									id = self.notif_id,
									title = icons.success .. " " .. task.name,
									timeout = 3000,
								})
							end
						end
					end, 100)
				end
			end
		end,
	}
end

return M
