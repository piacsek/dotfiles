local function get_test_bufnr()
	local buffers = vim.fn.getbufinfo({ buflisted = 1 })

	for _, buf in ipairs(buffers) do
		if buf.variables._test_vim_neovim_sticky == 1 then
			return buf.bufnr
		end
	end

	return nil
end

local function go_to_test_buffer()
	local test_buf = get_test_bufnr()

	if test_buf then
		vim.cmd("buffer " .. test_buf)
		vim.cmd("normal! G")
	else
		vim.notify("No vim-test terminal found", vim.log.levels.WARN)
	end
end
return {
	"vim-test/vim-test",
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
							vim.notify(item)
							-- Get all manually selected items (via Tab/Ctrl-a)
							local sel = picker:get_selected()
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
							end
						end,
					},
				})
			end,
			desc = "Test directories",
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
		vim.g["test#strategy"] = "neovim_sticky"
		vim.g["test#preserve_screen"] = 0
		vim.g["test#echo_command"] = 0
		vim.g["test#neovim#term_position"] = "topleft vsplit"
		vim.g["test#neovim_sticky#kill_previous"] = 1
	end,
}
