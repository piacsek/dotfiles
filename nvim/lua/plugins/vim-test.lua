return {
	"vim-test/vim-test",
	dependencies = { "preservim/vimux" },
	keys = {
		{ "<leader>tt", "<cmd>TestNearest<cr>", desc = "Test nearest" },
		{ "<leader>tf", "<cmd>TestFile<cr>", desc = "Test file" },
		{
			"<leader>td",
			function()
				local snacks = require("snacks")
				local test_root = vim.g._root_test_dir or "test"
				local test_dirs = vim.fn.globpath(test_root, "*", false, true)
				local items = {}

				for _, path in ipairs(test_dirs) do
					if vim.fn.isdirectory(path) == 1 then
						-- Snacks.picker expects items in a specific format
						table.insert(items, { text = path, file = path })
					end
				end

				if #items == 0 then
					vim.notify("No directories found under " .. test_root .. "/", vim.log.levels.WARN)
					return
				end

				snacks.picker({
					source = "test_dirs",
					items = items,
					layout = "select",
					actions = {
						confirm = function(picker, item)
							picker:close()
							-- Get all manually selected items (via Tab/Ctrl-a)
							local sel = picker:selected()
							local paths = {}

							if #sel > 0 then
								for _, s in ipairs(sel) do
									table.insert(paths, vim.fn.fnameescape(s.text))
								end
							elseif item then
								table.insert(paths, vim.fn.fnameescape(item.text))
							end

							if #paths > 0 then
								vim.cmd("TestSuite " .. table.concat(paths, " "))
							else
								vim.notify("No items selected", vim.log.levels.WARN)
							end
						end,
					},
				})
			end,
			desc = "Test directories",
		},
		{
			"<leader>tm",
			function()
				local test_root = vim.g._root_test_dir or "test"
				local output = vim.fn.systemlist("git diff --name-only main -- " .. test_root)

				if vim.v.shell_error ~= 0 or #output == 0 then
					vim.notify("No modified test files found vs main", vim.log.levels.WARN)
					return
				end

				local paths = {}
				for _, file in ipairs(output) do
					table.insert(paths, vim.fn.fnameescape(file))
				end

				vim.cmd("TestSuite " .. table.concat(paths, " "))
			end,
			desc = "[T]est [M]odified (vs main)",
		},
		{
			"<leader><BS>",
			function()
				if vim.bo.buftype == "" then
					vim.cmd("w")
				end

				vim.cmd("TestLast")
			end,
			desc = "Save and run last test",
		},
	},
	config = function()
		-- vim.g["test#strategy"] = "neovim_sticky"
		vim.g["test#strategy"] = "vimux"
		vim.g["test#preserve_screen"] = 0
		vim.g["test#echo_command"] = 0
		vim.g["test#neovim#term_position"] = "topleft vsplit"
		vim.g["test#neovim_sticky#kill_previous"] = 1
	end,
}
