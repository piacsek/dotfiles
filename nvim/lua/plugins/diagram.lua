return {
	"3rd/diagram.nvim",
	dependencies = {
		{
			"3rd/image.nvim",
			build = false, -- so that it doesn't build the rock https://github.com/3rd/image.nvim/issues/91#issuecomment-2453430239
			opts = {
				processor = "magick_cli",
			},
		},
	},
	opts = {
		events = {
			render_buffer = {},
			clear_buffer = { "BufLeave" },
		},
	},
	config = function()
		require("diagram").setup({
			integrations = {
				require("diagram.integrations.markdown"),
			},
			renderer_options = {
				mermaid = { theme = "dark", scale = 8 },
			},
		})
	end,
	keys = {
		{
			"H",
			function()
				local diagram = require("diagram")
				local image_nvim = require("image")

				-- Get current buffer and cursor position
				local bufnr = vim.api.nvim_get_current_buf()
				local cursor = vim.api.nvim_win_get_cursor(0)
				local row = cursor[1] - 1

				-- Find diagram at cursor (simplified version)
				local ft = vim.bo[bufnr].filetype
				local integration = require("diagram.integrations." .. ft)
				local diagrams = integration.query_buffer_diagrams(bufnr)

				local found_diagram = nil
				for _, diag in ipairs(diagrams) do
					if row >= diag.range.start_row and row <= diag.range.end_row then
						found_diagram = diag
						break
					end
				end

				if not found_diagram then
					vim.notify("No diagram found at cursor", vim.log.levels.INFO)
					return
				end

				-- Find renderer
				local renderer = nil
				for _, r in ipairs(integration.renderers) do
					if r.id == found_diagram.renderer_id then
						renderer = r
						break
					end
				end

				if not renderer then
					vim.notify("No renderer found", vim.log.levels.ERROR)
					return
				end

				-- Render diagram
				local renderer_options = { mermaid = { theme = "dark", scale = 8 } }
				local options = renderer_options[renderer.id] or {}
				local renderer_result = renderer.render(found_diagram.source, options)

				local function show_in_split()
					if vim.fn.filereadable(renderer_result.file_path) == 0 then
						vim.notify("Diagram file not found", vim.log.levels.ERROR)
						return
					end

					-- Open vertical split
					vim.cmd("vsplit")
					local buf = vim.api.nvim_get_current_buf()
					local win = vim.api.nvim_get_current_win()

					-- Set buffer options
					vim.api.nvim_buf_set_name(buf, found_diagram.renderer_id .. " diagram")
					vim.bo[buf].buftype = "nofile"
					vim.bo[buf].bufhidden = "wipe"
					vim.bo[buf].swapfile = false

					-- Add header
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
						"# " .. found_diagram.renderer_id:upper() .. " Diagram",
						"",
						"Press 'q' to close",
						"",
					})

					-- Render image
					local image = image_nvim.from_file(renderer_result.file_path, {
						buffer = buf,
						window = win,
						with_virtual_padding = true,
						inline = true,
						x = 0,
						y = 4,
					})

					if image then
						image:render()
					end

					-- Keymaps
					vim.keymap.set("n", "q", function()
						if image then
							image:clear()
						end
						vim.cmd("close")
					end, { buffer = buf, desc = "Close diagram split" })

					vim.keymap.set("n", "<Esc>", function()
						if image then
							image:clear()
						end
						vim.cmd("close")
					end, { buffer = buf, desc = "Close diagram split" })
				end

				if renderer_result.job_id then
					local timer = vim.loop.new_timer()
					if not timer then
						return
					end
					timer:start(
						0,
						100,
						vim.schedule_wrap(function()
							local result = vim.fn.jobwait({ renderer_result.job_id }, 0)
							if result[1] ~= -1 then
								if timer:is_active() then
									timer:stop()
								end
								if not timer:is_closing() then
									timer:close()
									show_in_split()
								end
							end
						end)
					)
				else
					show_in_split()
				end
			end,
			mode = "n",
			ft = { "markdown", "norg" },
			desc = "Show diagram in split",
		},
	},
}
